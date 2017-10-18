// Various things that will actually make the mech do stuff
/obj/item/equipment
	var/obj/driveable/chassis		// Chassis
	var/obj/item/component/housing	// The component in which we are housed
	var/equipment_class
	var/type_check = CHECK_ANY

	var/list/equipment_actions