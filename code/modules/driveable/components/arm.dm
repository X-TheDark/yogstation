// Each arm is individually damaged/attached. Can also be used for some abstract hardpoints, I suppose
/obj/item/component/arm
	name = "arm"
	icon = 'icons/driveable/components/arms.dmi'
	icon_state = "thisisabstract"
	var/icon_left = "thisisabstract"
	var/icon_right = "thisisabstract"

/obj/item/component/arm/is_compatible(obj/item/component/what)