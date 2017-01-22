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

	var/obj/item/component/body/torso
	var/obj/item/component/head/head
	var/obj/item/component/legs/legs
	var/obj/item/component/arm/l_arm
	var/obj/item/component/arm/r_arm

	var/next_move = 0
	var/next_click = 0

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

	var/passenger = FALSE
	if(torso && torso.supports_passengers())
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
	world << "Trying to remove air"
	if(torso)
		return torso.remove_air(amount)
	. = ..()

/obj/driveable/frame/basic/return_air()
	world << "Trying to return air"
	if(torso)
		return torso.return_air()
	. = ..()

/obj/driveable/frame/basic/proc/frame_turn(direction)
	dir = direction
	next_move = world.time + 20
	if(torso)
		torso.dir = dir
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
	// Torso is where we are, conceptually speaking, even if our loc is actually the frame
	// So if there's no torso, we can't enter
	if(!torso)
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
	. = torso.can_enter(user, passenger)

// Unsafe, use can_enter(mob, is_passenger) before this
/obj/driveable/frame/basic/proc/enter(mob/M, passenger = FALSE)
	// If we are going for the driver seat, handle it here
	if(!driver && !passenger)
		M.forceMove(src)
		driver = M
	torso.on_enter(M, passenger)

/obj/driveable/frame/basic/proc/can_eject(mob/user)
	return TRUE

// Unsafe, use can_eject(mob) before this
/obj/driveable/frame/basic/proc/eject(mob/M)
	if(can_eject(M))
		var/passenger = TRUE
		// For drivers/passengers
		if(M == driver)
			M.forceMove(get_turf(src))
			driver = null
			passenger = FALSE
		torso.on_eject(M, passenger)

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

// Torso and legs can be installed without having the other. Arms/head requires torso to be installed.
/obj/driveable/frame/basic/attempt_construction(obj/item/component/component, mob/user)
	. = TRUE
	var/install_type
	if(istype(component, /obj/item/component/body))
		if(torso)
			user << "<span class='notice'>There's already a body installed on [name].</span>"
			. = FALSE
		if(legs)
			if(!component.is_compatible(legs))
				user << "<span class='notice'>Cannot install [component.name] onto [legs.name], incompatible type.</span>"
				. = FALSE
			install_type = "body"
	else if(istype(component, /obj/item/component/legs))
		if(legs)
			user << "<span class='notice'>There's already a set of locomotive implements installed on [name].</span>"
			. = FALSE
		if(torso)
			if(!component.is_compatible(torso))
				user << "<span class='notice'>Cannot install [component.name] onto [torso.name], incompatible type.</span>"
				. = FALSE
			install_type = "legs"
	else if(istype(component, /obj/item/component/head))
		if(!torso)
			user << "<span class='notice'>Install a body first.</span>"
			. = FALSE
		if(head)
			user << "<span class='notice'>There's already a head installed on [name].</span>"
			. = FALSE
		if(!component.is_compatible(torso))
			user << "<span class='notice'>Cannot install [component.name] onto [torso.name], incompatible type.</span>"
			. = FALSE
			install_type = "head"
	else if(istype(component, /obj/item/component/arm))
		if(!torso)
			user << "<span class='notice'>Install a body first.</span>"
			. = FALSE
		if(!torso.supports_arms())
			user << "<span class='notice'>Cannot install arms onto [torso.name].</span>"
			. = FALSE
		if(!torso.has_free_arm_slots())
			user << "<span class='notice'>No more arms can be installed onto [torso.name].</span>"
			. = FALSE
		if(!component.is_compatible(torso))
			user << "<span class='notice'>Cannot install [component.name] onto [torso.name], incompatible type.</span>"
			. = FALSE
			install_type = "arm"
	if(!.)
		return

	install(component, user, install_type)

/obj/driveable/frame/basic/attempt_installation(obj/item/component/component, mob/user)

/obj/driveable/frame/basic/attempt_upgrade(obj/item/component/component, mob/user)

/obj/driveable/frame/basic/proc/install(obj/item/component/component, mob/user, install_type)
	switch(install_type)
		if("body")
			torso = component
		if("legs")
			legs = component
		if("arm")
			if(l_arm)
				r_arm = component
			else
				l_arm = component
		if("head")
			head = component
	component.forceMove(src)
	component.on_install(src, user)
	update_visuals()

/obj/driveable/frame/basic/proc/update_visuals()
	overlays.Cut()
	underlays.Cut()
	switch(dir)
		if(EAST)
			if(r_arm)
				overlays += r_arm.icon_right
			if(l_arm)
				underlays += l_arm.icon_left
		if(WEST)
			if(r_arm)
				underlays += r_arm.icon_right
			if(l_arm)
				overlays += l_arm.icon_left
		else
			if(r_arm)
				overlays += r_arm.icon_right
			if(l_arm)
				overlays += l_arm.icon_left
	if(head)
		overlays += head.icon_state
	if(legs)
		overlays += legs.icon_state
	if(torso)
		overlays += torso.icon_state