// Sensor arrays, turrets, special hardpoints for interesting things
/obj/item/component/head
	name = "head"
	icon = 'icons/driveable/components/heads.dmi'
	icon_state = "default"
	component_type = COMPONENT_HEAD

/obj/item/component/head/is_compatible(obj/item/component/what)
	return TRUE