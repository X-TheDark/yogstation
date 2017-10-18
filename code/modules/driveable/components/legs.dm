// Legs will be a pair, but internally, we'll consider right/left side as separate, for damage purposes
/obj/item/component/legs
	name = "legs"
	icon = 'icons/driveable/components/legs.dmi'
	icon_state = "default"

	component_type = COMPONENT_LEGS

	// Bitflag for various leg properties, check _DEFINES/driveable.dm for those
	var/properties

	// Delay to movement/turning after a turn
	var/turn_delay = 5
	// Delay to movement/turning after a step
	var/move_delay = 3

/obj/item/component/legs/proc/can_move(mob/user)
	. = TRUE
	if(!chassis)
		. = FALSE

/obj/item/component/legs/proc/handle_movement(mob/user, direction)
	if(can_move(user))
		if(chassis.dir != direction)
			. = handle_turn(direction)
		else
			. = handle_step(direction)
		// if we have moved, set the move delay and do whatever you want to do when you exit the turf
		if(.)
			chassis.delay_next_move(move_delay)

/obj/item/component/legs/proc/handle_turn(direction)
	if(properties & LEGS_NO_TURN)
		. = handle_step(direction)
	else
		chassis.change_dir(direction)
		chassis.delay_next_move(turn_delay)


/obj/item/component/legs/proc/handle_step(direction)
	. = step(chassis, direction)

// Legpair is, well, a pair of legs
// This is here to change it to track left/right side damage separately down the line, if necessary
/obj/item/component/legs/legpair

// Undercarriage is a complete base upon which the torso "drives", things like wheels/tracks/hoverstuff
/obj/item/component/legs/undercarriage