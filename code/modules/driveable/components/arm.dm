// Each arm is individually damaged/attached. Can also be used for some abstract hardpoints, I suppose
/obj/item/component/arm
	name = "arm"
	icon = 'icons/driveable/components/arms.dmi'
	icon_state = "default_r"
	component_type = COMPONENT_ARM
	
	var/icon_left = "default_l"
	var/icon_right = "default_r"

/obj/item/component/arm/is_compatible(obj/item/component/what)
	return TRUE