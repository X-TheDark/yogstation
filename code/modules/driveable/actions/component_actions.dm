// These actions are tied to a specific component and are given innately to that component
/datum/action/innate/driveable/component/mech_toggle_internals
	name = "Toggle Internal Airtank Usage"
	button_icon_state = "mech_internals_off"

/datum/action/innate/driveable/component/mech_toggle_internals/Activate()
	if(!owner || !chassis || chassis.driver != owner)
		return
	var/obj/item/component/body/body = component
	body.using_internal_tank = !body.using_internal_tank
	button_icon_state = "mech_internals_[body.using_internal_tank ? "on" : "off"]"
	UpdateButtonIcon()