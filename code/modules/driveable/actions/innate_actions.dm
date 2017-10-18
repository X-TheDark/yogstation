// These actions are attached to the frame that you're driving. They are the basic actions, such as switching lights/ejecting (available to driveable frames by default)

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