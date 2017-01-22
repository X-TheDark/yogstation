// The things which will hold equipment, be damaged and stuff
/obj/item/component
	name = "component of a driveable"
	desc = "SAMPLE TEXT"
	icon_state = "thisisabstract"
	
	var/obj/driveable/chassis
	var/max_health
	var/damage

/obj/item/component/proc/get_available_slots()

/obj/item/component/proc/on_install(obj/driveable/where, mob/user)
	chassis = where

/obj/item/component/proc/is_compatible(obj/item/component/what)