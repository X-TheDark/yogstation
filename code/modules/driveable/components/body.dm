// The body, either a cabin or an actual torso on to which arms can be stuck
// Pilot & Co are here for the purposes of damage calculations/armour penetration/etc
/obj/item/component/body
	name = "body"
	icon = 'icons/driveable/components/bodies.dmi'
	icon_state = "default"

	component_type = COMPONENT_BODY

	// Vision overlay for when the bodies armor is closed or lifted
	// If we have a head, these don't apply, as head gives 360 vision as long as it works
	var/can_lift_armor = FALSE //Can't lift/open armor, just enter/exit
	var/vision_overlay_closed
	var/vision_overlay_open

	var/is_sealed = TRUE
	var/using_internal_tank = TRUE //So we don't start to suffocate once we enter
	var/obj/item/weapon/tank/internals/internal_tank
	var/internal_tank_type = /obj/item/weapon/tank/internals/air
	var/datum/gas_mixture/cabin_air

	var/max_armslots = 2
	var/list/installed_arms = list()

	var/passenger_seats = 0 //there's always a driver, these folk are separate
	var/list/passengers

/obj/item/component/body/New()
	if(is_sealed && ispath(internal_tank_type, /obj/item/weapon/tank/internals))
		internal_tank = new internal_tank_type(src)
		LAZYINITLIST(component_actions)
		component_actions += new /datum/action/innate/driveable/component/mech_toggle_internals
		add_cabin_air()

// On creation, copy contents of the air tank and remove a portion, based on cabin volume
// Allows non-standard tank types for bodies
/obj/item/component/body/proc/add_cabin_air()
	var/cabin_volume = 35
	var/datum/gas_mixture/tank_mix = internal_tank.return_air()
	var/tank_volume = tank_mix.return_volume()
	cabin_air = tank_mix.copy()
	cabin_air.remove_ratio(cabin_volume/tank_volume)
	cabin_air.volume = cabin_volume

// Try to remove from tank first in all cases, leave cabin air untouched for as long as possible
// Not realistic, but why bother with more complicated solutions?
/obj/item/component/body/remove_air(amount)
	if(amount && internal_tank)
		var/datum/gas_mixture/tank_mix = internal_tank.return_air()
		var/amount_in_tank = tank_mix.total_moles()
		if(amount_in_tank > 0)
			if(amount > amount_in_tank)
				cabin_air.merge(tank_mix)
				. = cabin_air.remove(amount)
			else
				. = internal_tank.remove_air(amount)
		else
			. = cabin_air.remove(amount)

// Return cabin air for pressure/etc things
/obj/item/component/body/return_air()
	if(internal_tank)
		return cabin_air

/obj/item/component/body/proc/supports_arms()
	if(max_armslots > 0)
		return TRUE
	else
		return FALSE

/obj/item/component/body/proc/supports_head()

/obj/item/component/body/proc/has_free_arm_slots()
	. = max_armslots - installed_arms.len

// Driver is taken care of in /obj/driveable
/obj/item/component/body/proc/can_enter(mob/user, passenger = FALSE)
	. = TRUE
	if(passenger)
		if(!passenger_seats)
			. = FALSE
		if(passengers && (passengers.len == passenger_seats))
			. = FALSE

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
		. = TRUE
	else
		. = FALSE