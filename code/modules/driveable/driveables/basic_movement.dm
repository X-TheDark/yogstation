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

// Movement is taken care of at leg component
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