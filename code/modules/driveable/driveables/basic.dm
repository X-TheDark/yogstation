// The binding glue to which all sticks together
// Also the thing that processes movement/damage/etc
/obj/driveable/frame/basic
	name = "chassis"
	desc = "Mech/Vehicle chassis. Examine to see what is needed to finish construction."
	icon_state = "basic"

	// These will be manipulated as the mech/vehicle get finished
	density = 1
	opacity = 0
	anchored = 0
	unacidable = 0

	var/obj/item/component/body/body
	var/obj/item/component/head/head
	var/obj/item/component/legs/legs
	var/obj/item/component/arm/l_arm
	var/obj/item/component/arm/r_arm

	var/next_move = 0
	var/next_click = 0

	var/lights_on = FALSE
	var/lights_power = 5

/obj/driveable/frame/basic/relaymove(mob/user, direction)
	if(dir == direction && can_move())
		frame_step(direction)
	else if(dir != direction && can_turn())
		frame_turn(direction)

/obj/driveable/frame/basic/MouseDrop_T(atom/dropping, mob/user)
	if(!user.canUseTopic(src, TRUE) || (user != dropping))
		return
	if(!ishuman(user))
		return
	if(!body || !legs)
		user << "<span class='notice'>This vehicle must have both a body and legs before it can be driven.</span>"
		return
	
	var/passenger = FALSE
	if(body.supports_passengers())
		switch(alert(user, "Which seat?", "Which seat?", "Driver", "Passenger", "Cancel"))
			if("Passenger")
				passenger = TRUE
			if("Cancel")
				return

	if(can_enter(user, passenger))
		visible_message("[user] starts to climb into [name].")
		if(do_after(user, 40, target = src))
			if(can_enter(user, passenger))
				enter(user, passenger)

/obj/driveable/frame/basic/remove_air(amount)
	if(body && body.is_sealed)
		return body.remove_air(amount)
	. = ..()

/obj/driveable/frame/basic/return_air()
	if(body && body.is_sealed)
		return body.return_air()
	. = ..()

/obj/driveable/frame/basic/proc/frame_turn(direction)
	dir = direction
	next_move = world.time + 20
	if(body)
		body.dir = dir
	if(legs)
		legs.dir = dir
	if(head)
		head.dir = dir
	if(l_arm)
		l_arm.dir = dir
	if(r_arm)
		r_arm.dir = dir
	update_visuals()

/obj/driveable/frame/basic/proc/frame_step(direction)
	. = step(src, direction)
	if(.)
		next_move = world.time + 10

/obj/driveable/frame/basic/proc/can_enter(mob/user, passenger = FALSE)
	return TRUE
	// body is where we are, conceptually speaking, even if our loc is actually the frame
	// So if there's no body, we can't enter
	if(!body)
		user << "<span class='warning'>The [name] doesn't have a body to occupy.</span>"
		return FALSE
	if(user.buckled)
		user << "<span class='warning'>You are currently buckled and cannot move.</span>"
		return FALSE
	if(user.has_buckled_mobs())
		user << "<span class='warning'>You can't enter the [name] with other creatures attached to you!</span>"
		return FALSE
	if(driver && !passenger)
		user << "<span class='warning'>There's already someone in the [name]!</span>"
		return FALSE
	. = body.can_enter(user, passenger)

// Unsafe, use can_enter(mob, is_passenger) before this
/obj/driveable/frame/basic/proc/enter(mob/M, passenger = FALSE)
	// If we are going for the driver seat, handle it here
	if(!driver && !passenger)
		M.forceMove(src)
		driver = M
		GrantActions(M)
	body.on_enter(M, passenger)

/obj/driveable/frame/basic/proc/can_eject(mob/user)
	return TRUE

// Unsafe, use can_eject(mob) before this
/obj/driveable/frame/basic/proc/eject(mob/M)
	var/passenger = TRUE
	// For drivers/passengers
	if(M == driver)
		M.forceMove(get_turf(src))
		driver = null
		passenger = FALSE
		RemoveActions(M)
	body.on_eject(M, passenger)

/obj/driveable/frame/basic/proc/can_move()
	return TRUE
	//
	//
	if(!driver)
		return FALSE
	if(next_move > world.time)
		return FALSE
	if(driver.incapacitated())
		driver << "<span class='warning'>Cannot drive while incapacitated.</span>"
		return FALSE
	if(!legs)
		driver << "<span class='warning'>The [name] does not have any means of locomotion!</span>"
		return FALSE
	if(!legs.can_move())
		driver << "<span class='warning'>The [name] cannot move due to damaged means of locomotion.</span>"
		return FALSE

/obj/driveable/frame/basic/proc/can_turn()
	return TRUE

// body and legs can be installed without having the other. Arms/head requires body to be installed.
/obj/driveable/frame/basic/attempt_construction(obj/item/component/component, mob/user)
	switch(component.component_type)
		if(COMPONENT_HEAD)
			if(!body)
				user << "<span class='notice'>Install a body first.</span>"
				return FALSE
			if(head)
				user << "<span class='notice'>There's already a head installed on [name].</span>"
				return FALSE
			if(!component.is_compatible(body))
				user << "<span class='notice'>Cannot install [component.name] onto [body.name], incompatible type.</span>"
				return FALSE
		if(COMPONENT_ARM)
			if(!body)
				user << "<span class='notice'>Install a body first.</span>"
				return FALSE
			if(!body.supports_arms())
				user << "<span class='notice'>Cannot install arms onto [body.name].</span>"
				return FALSE
			if(!body.has_free_arm_slots())
				user << "<span class='notice'>No more arms can be installed onto [body.name].</span>"
				return FALSE
			if(!component.is_compatible(body))
				user << "<span class='notice'>Cannot install [component.name] onto [body.name], incompatible type.</span>"
				return FALSE
		if(COMPONENT_BODY)
			if(body)
				user << "<span class='notice'>There's already a body installed on [name].</span>"
				return FALSE
			if(legs)
				if(!component.is_compatible(legs))
					user << "<span class='notice'>Cannot install [component.name] onto [legs.name], incompatible type.</span>"
					return FALSE
		if(COMPONENT_LEGS)
			if(legs)
				user << "<span class='notice'>There's already a set of locomotive implements installed on [name].</span>"
				return FALSE
			if(body)
				if(!component.is_compatible(body))
					user << "<span class='notice'>Cannot install [component.name] onto [body.name], incompatible type.</span>"
					return FALSE
		else
			user << "<span class='notice'>[name] does not support this type of component.</span>"
			return FALSE

	if(user.unEquip(component))
		install_component(component, user)
	else
		user << "<span class='warning'>The [component.name] seems to be stuck to your hand!</span>"


/obj/driveable/frame/basic/attempt_installation(obj/item/component/component, mob/user)

/obj/driveable/frame/basic/attempt_upgrade(obj/item/component/component, mob/user)

/obj/driveable/frame/basic/proc/install_component(obj/item/component/component, mob/user)
	switch(component.component_type)
		if(COMPONENT_BODY)
			body = component
		if(COMPONENT_LEGS)
			legs = component
		if(COMPONENT_ARM)
			if(l_arm)
				r_arm = component
			else
				l_arm = component
		if(COMPONENT_HEAD)
			head = component
	component.forceMove(src)
	component.on_install(src, user)
	update_visuals()

/obj/driveable/frame/basic/proc/update_visuals()
	overlays.Cut()
	underlays.Cut()
	if(head)
		overlays += image(head.icon, head.icon_state)
	if(legs)
		overlays += image(legs.icon, legs.icon_state)
	if(body)
		overlays += image(body.icon, body.icon_state)
	switch(dir)
		if(EAST)
			if(r_arm)
				overlays += image(r_arm.icon, r_arm.icon_right)
			if(l_arm)
				underlays += image(l_arm.icon, l_arm.icon_left)
		if(WEST)
			if(r_arm)
				underlays += image(r_arm.icon, r_arm.icon_right)
			if(l_arm)
				overlays += image(l_arm.icon, l_arm.icon_left)
		else
			if(r_arm)
				overlays += image(r_arm.icon, r_arm.icon_right)
			if(l_arm)
				overlays += image(l_arm.icon, l_arm.icon_left)