/obj/driveable/frame/proc/GrantActions(mob/living/user)
	if(basic_actions && basic_actions.len)
		for(var/v in basic_actions)
			var/datum/action/innate/mecha/action = v
			action.Grant(user, src) // Innate action
	if(component_actions && component_actions.len)
		for(var/component_ref in component_actions)
			var/datum/action/innate/mecha/action = component_ref
			action.Grant(user, component_ref) // Component action, so use the component reference
	if(equipment_actions && equipment_actions.len)
		for(var/equipment_ref in equipment_actions)
			var/datum/action/innate/mecha/action = equipment_ref
			action.Grant(user, equipment_ref)	// Equipment action, so use the equipment reference

/obj/driveable/frame/proc/RemoveActions(mob/living/user, human_occupant = 0)
	if(basic_actions && basic_actions.len)
		for(var/v in basic_actions)
			var/datum/action/innate/mecha/action = v
			action.Remove(user)
	if(component_actions && component_actions.len)
		for(var/component_ref in component_actions)
			var/datum/action/innate/mecha/action = component_ref
			action.Remove(user)
	if(equipment_actions && equipment_actions.len)
		for(var/equipment_ref in equipment_actions)
			var/datum/action/innate/mecha/action = equipment_ref
			action.Remove(user)

/datum/action/innate/driveable
	check_flags = AB_CHECK_RESTRAINED | AB_CHECK_STUNNED | AB_CHECK_CONSCIOUS
	var/obj/driveable/frame/basic/chassis

/datum/action/innate/driveable/Grant(mob/living/L, obj/driveable/frame/basic/D)
	chassis = D
	..()

/datum/action/innate/driveable/Destroy()
	chassis = null
	return ..()

/datum/action/innate/driveable/mech_eject
	name = "Eject From Mech"
	button_icon_state = "mech_eject"

/datum/action/innate/driveable/mech_eject/Activate()
	if(!owner || !iscarbon(owner))
		return
	if(!chassis || chassis.driver != owner)
		return
	if(!chassis.can_eject(owner))
		return
	chassis.eject(owner)

/datum/action/innate/driveable/toggle_lights
	name = "Toggle Lights"
	button_icon_state = "mech_lights_off"

/datum/action/innate/driveable/toggle_lights/Activate()
	if(!owner || !chassis || chassis.driver != owner)
		return
	chassis.lights_on = !chassis.lights_on
	if(chassis.lights_on)
		chassis.AddLuminosity(chassis.lights_power)
		button_icon_state = "mech_lights_on"
	else
		chassis.AddLuminosity(-chassis.lights_power)
		button_icon_state = "mech_lights_off"
	//chassis.occupant_message("Toggled lights [chassis.lights_on ? "on" : "off"].")
	//chassis.log_message("Toggled lights [chassis.lights_on ? "on" : "off"].")
	UpdateButtonIcon()