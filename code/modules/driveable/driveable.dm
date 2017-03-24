/obj/driveable/frame
	name = "frame"
	desc = "Something driveable. You should really use a subtype of this, though!"
	icon = 'icons/driveable/frame.dmi'
	icon_state = "default"
	layer = BELOW_MOB_LAYER

	var/mob/living/carbon/driver

	// Actions that the frames has by default - ejecting, toggling lights
	var/list/basic_actions
	// Actions given by the components
	var/list/component_actions
	// Actions given by the equipment
	var/list/equipment_actions

	var/next_move = 0
	var/next_click = 0

/obj/driveable/frame/New()
	..()
	LAZYINITLIST(basic_actions)
	basic_actions += new /datum/action/innate/driveable/mech_eject 
	basic_actions += new /datum/action/innate/driveable/toggle_lights

/obj/driveable/frame/proc/change_dir(direction)