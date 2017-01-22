// The body, either a cabin or an actual torso on to which arms can be stuck
// Pilot & Co are here for the purposes of damage calculations/armour penetration/etc
/obj/item/component/body
	name = "body"
	max_health = 100
	icon = 'icons/driveable/components/bodies.dmi'
	icon_state = "thisisabstract"

	var/is_sealed = FALSE
	var/using_internal_tank = FALSE
	
	var/rotary = FALSE //can body rotate independently of legs?

	var/passenger_seats = 0 //there's always a driver, these folk are separate
	var/list/passengers

/obj/item/component/body/is_compatible(obj/item/component/what)

/obj/item/component/body/proc/supports_arms()
	return FALSE

/obj/item/component/body/proc/supports_head()
	return FALSE

/obj/item/component/body/proc/has_free_arm_slots()
	return FALSE

/obj/item/component/body/proc/install(obj/item/component/component, mob/user, install_type)

// Driver is taken care of in /obj/driveable
/obj/item/component/body/proc/can_enter(mob/user, passenger = FALSE)
	. = TRUE
	if(passenger)
		if(!passenger_seats)
			. = FALSE
		if(passengers && (passengers.len == passenger_seats))
			. = FALSE

/obj/item/component/body/remove_air(amount)

/obj/item/component/body/return_air()

// Driver handled in /obj/driveable, here we only handle passengers here
/obj/item/component/body/proc/on_enter(mob/M, passenger = FALSE)
	if(passenger)
		if(!passengers)
			passengers = list()
		passengers += M
		M.forceMove(src)

/obj/item/component/body/proc/on_eject(mob/M, passenger = FALSE)
	if(passenger)
		passengers -= M
		M.forceMove(get_turf(src))
		if(passengers.len == 0)
			passengers = null

/obj/item/component/body/proc/supports_passengers()
	if(passenger_seats > 0)
		return TRUE
	else
		return FALSE