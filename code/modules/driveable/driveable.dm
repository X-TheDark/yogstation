/obj/driveable/frame
	name = "frame"
	desc = "Something driveable. You should really use a subtype of this, though!"
	icon = 'icons/driveable/frame.dmi'
	icon_state = "default"
	layer = BELOW_MOB_LAYER

	var/mob/living/carbon/driver

	// Actions that the frames has by default - ejecting, toggling lights
	var/list/basic_actions = list(new /datum/action/innate/driveable/mech_eject, 
		new /datum/action/innate/driveable/toggle_lights)
	// Actions given by the components
	var/list/component_actions
	// Actions given by the equipment
	var/list/equipment_actions