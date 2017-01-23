// Legs will be a pair, but internally, we'll consider right/left side as separate, for damage purposes
/obj/item/component/legs
	name = "legs"
	icon = 'icons/driveable/components/legs.dmi'
	icon_state = "default"
	component_type = COMPONENT_LEGS

	// Delay to movement/turning after a turn
	var/turn_delay
	// Delay to movement/turning after a step
	var/move_delay

/obj/item/component/legs/is_compatible(obj/item/component/what)
	return TRUE

/obj/item/component/legs/proc/can_move()
	return TRUE

// Legpair is, well, a pair of legs
// This is here to change it to track left/right side damage separately down the line, if necessary
/obj/item/component/legs/legpair

// Undercarriage is a complete base upon which the torso "drives", things like wheels/tracks/hoverstuff
/obj/item/component/legs/undercarriage