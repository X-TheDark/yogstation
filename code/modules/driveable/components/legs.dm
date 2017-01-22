// Legs will be a pair, but internally, we'll consider right/left side as separate, for damage purposes
/obj/item/component/legs
	name = "legs"
	icon = 'icons/driveable/components/legs.dmi'
	icon_state = "thisisabstract"

	// Delay to movement/turning after a turn
	var/turn_delay
	// Delay to movement/turning after a step
	var/move_delay

/obj/item/component/legs/is_compatible(obj/item/component/what)

/obj/item/component/legs/proc/can_move()

// Legpair is, well, a pair of legs
// This is here to change it to track left/right side damage separately down the line, if necessary
/obj/item/components/legs/legpair

// Undercarriage is a complete base
// This is here to differentiate between actual legs (that could be made to track damage separately) and something
// like a wheeled base (that would not have separate sides for damage purposes)
/obj/item/components/legs/undercarriage