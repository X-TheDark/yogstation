// Action granting/removal

/obj/driveable/frame/proc/GrantActions(mob/living/user)
	if(basic_actions && basic_actions.len)
		for(var/v in basic_actions)
			var/datum/action/innate/driveable/action = v
			action.Grant(user, src)
	if(component_actions && component_actions.len)
		for(var/component_ref in component_actions)
			var/list/action_list = component_actions[component_ref]
			for(var/v in action_list)
				var/datum/action/innate/driveable/action = v
				action.Grant(user, src)
	if(equipment_actions && equipment_actions.len)
		for(var/equipment_ref in equipment_actions)
			var/list/action_list = equipment_actions[equipment_ref]
			for(var/v in action_list)
				var/datum/action/innate/driveable/action = v
				action.Grant(user, src)

/obj/driveable/frame/proc/RemoveActions(mob/living/user, human_occupant = 0)
	if(basic_actions && basic_actions.len)
		for(var/v in basic_actions)
			var/datum/action/innate/driveable/action = v
			action.Remove(user)
	if(component_actions && component_actions.len)
		for(var/component_ref in component_actions)
			var/list/action_list = component_actions[component_ref]
			for(var/v in action_list)
				var/datum/action/innate/driveable/action = v
				action.Remove(user)
	if(equipment_actions && equipment_actions.len)
		for(var/equipment_ref in equipment_actions)
			var/list/action_list = equipment_actions[equipment_ref]
			for(var/v in action_list)
				var/datum/action/innate/driveable/action = v
				action.Remove(user)