// The binding glue to which all sticks together
// Also the thing that processes movement/damage/etc
/obj/driveable/frame/basic
	name = "chassis"
	desc = "Mech/Vehicle chassis. Examine to see what is needed to finish construction."
	icon_state = "basic"

	// Internal use
	var/driveable_complete = FALSE

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

	var/lights_on = FALSE
	var/lights_power = 5

	var/next_air_warning = 0
	var/air_warning_delay = 40 //Warn user if the cabin is sealed but no air in it once every this deciseconds


/obj/driveable/frame/basic/change_dir(direction)
	if(dir != direction)
		dir = direction
		if(body)
			body.dir = direction
		if(legs)
			legs.dir = direction
		if(head)
			head.dir = direction
		if(l_arm)
			l_arm.dir = direction
		if(r_arm)
			r_arm.dir = direction
		// Arms swap their position between being overlay and being underlay for super-coolness factor
		update_mutable_overlays()

/obj/driveable/frame/basic/relaymove(mob/user, direction)
	if((user == driver) && can_move() && isturf(loc))
		// this is successful only if we actually make a step, if it's a turn, legs will call change_dir proc of the frame
		. = legs.handle_movement(user, direction)

/obj/driveable/frame/Bump(atom/obstacle, custom_bump)
	// Copy paste from mech code
	if(custom_bump)
		if(..()) //mech was thrown
			return
		if(istype(obstacle, /obj))
			var/obj/O = obstacle
			if(!O.anchored)
				step(obstacle, dir)
		else if(istype(obstacle, /mob))
			step(obstacle, dir)

// By this point, our loc is the turf we moved onto, oldloc is the turf we came from
// Could be useful for on move stuff, like trampling, leaving a trail of fire.
/obj/driveable/frame/Moved(atom/oldloc, direction)
	. = ..()

/obj/driveable/frame/proc/delay_next_move(delay)
	if(delay)
		next_move = world.time + delay

/obj/driveable/frame/basic/MouseDrop_T(atom/dropping, mob/user)
	if((user != dropping) || !user.canUseTopic(src, TRUE))
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
		. = body.remove_air(amount)
		if(!. && driver && (world.time > next_air_warning))
			driver << "<span class='userdanger'>Your cabin's air tank has no more air! You will suffocate if you don't do something!</span>"
			next_air_warning = world.time + air_warning_delay
	else
		. = ..()

/obj/driveable/frame/basic/return_air()
	if(body && body.is_sealed)
		. = body.return_air()
		if(!. && driver && (world.time > next_air_warning))
			driver << "<span class='userdanger'>There's no air tank to breathe from! You will suffocate if you don't do something!</span>"
			next_air_warning = world.time + air_warning_delay
	else
		. = ..()

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
		user << "<span class='warning'>There's already someone driving the [name]!</span>"
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

// Driveable frame-level can_move checks
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
		return FALSE

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
	on_component_install(component, user)
	add_component_overlay(component)

/obj/driveable/frame/basic/proc/remove_component(obj/item/component/component, mob/user)

/obj/driveable/frame/basic/proc/add_component_overlay(obj/item/component/component)
	if(component.is_overlay_immutable)
		if(!component.component_image) // immutables need only to be constructed once
			component.component_image = image(component.icon, component.icon_state)
		overlays += component.component_image
	else
		if((component == r_arm) || (component == l_arm))
			var/obj/item/component/arm/arm_obj = component
			if(component == r_arm)
				arm_obj.component_image = image(arm_obj.icon, arm_obj.icon_right)
			else
				arm_obj.component_image = image(arm_obj.icon, arm_obj.icon_left)
			update_mutable_overlays()

/obj/driveable/frame/basic/proc/update_mutable_overlays()
	switch(dir)
		if(EAST)
			if(r_arm)
				overlays -= r_arm.component_image
				underlays -= r_arm.component_image
				overlays += r_arm.component_image
			if(l_arm)
				underlays -= l_arm.component_image
				overlays -= l_arm.component_image
				underlays += l_arm.component_image
		if(WEST)
			if(r_arm)
				underlays -= r_arm.component_image
				overlays -= r_arm.component_image
				underlays += r_arm.component_image
			if(l_arm)
				overlays -= l_arm.component_image
				underlays -= l_arm.component_image
				overlays += l_arm.component_image

// Make frame invisible if we have both body and legs
/obj/driveable/frame/basic/proc/on_component_install(obj/item/component/component, mob/user)
	if(component.component_actions && component.component_actions.len)
		LAZYINITLIST(component_actions)
		component_actions[component] = component.component_actions
		if(driver)
			component.GrantComponentActions(driver)
	if(!driveable_complete && body && legs)
		icon_state = null	//turn the frame invisible, using alpha = 0 messes with overlays/underlays
		anchored = 1
		driveable_complete = TRUE

/obj/driveable/frame/basic/proc/on_component_remove(obj/item/component/component, mob/user)
	if(component_actions && component_actions[component])
		LAZYREMOVE(component_actions, component)
		if(driver)
			component.RemoveComponentActions(driver)
	if(driveable_complete && (!body || !legs))
		icon_state = initial(icon_state)
		anchored = 0
		driveable_complete = FALSE