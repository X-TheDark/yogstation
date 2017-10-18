// The things which will hold equipment, be damaged and stuff
/obj/item/component
	name = "component of a driveable"
	desc = "SAMPLE TEXT"
	icon_state = "default"

	// Bulky as hell, only bluespace backpack can fit this, can't even be thrown properly
	w_class = 6
	throw_range = 0
	throw_speed = 0
	throwforce = 0
	
	var/component_image
	var/is_overlay_immutable = TRUE // Does this always appear as an overlay?
	
	var/component_type
	var/component_weight
	var/component_class

	var/obj/driveable/frame/chassis
	var/list/component_actions

	var/list/compatible_types
	var/list/incompatible_types

	// Used internally
	var/list/compatible_typecache
	var/list/incompatible_typecache

/obj/item/component/New()
	..()
	if(compatible_types && compatible_types.len)
		compatible_typecache = typecacheof(compatible_types)
	if(incompatible_types && incompatible_types.len)
		incompatible_typecache = typecacheof(incompatible_types)

/obj/item/component/proc/on_install(obj/driveable/where, mob/user)
	chassis = where

/obj/item/component/proc/on_remove(mob/user)
	chassis = null

// First check typecache compatibility, if that gives us some sort of result, we check it further via custom rules
/obj/item/component/proc/is_compatible(obj/item/component/what)
	var/result = typecache_compatibility(what)
	. = custom_compatibility(what, result)

// Override this if you want to check for something specific in the component, by default returns typecache check result
/obj/item/component/proc/custom_compatibility(obj/item/component/what, typecache_check_result)
	. = TRUE //typecache_check_result

/obj/item/component/proc/typecache_compatibility(obj/item/component/what)
	if(compatible_types && compatible_types.len)
		. = is_type_in_typecache(what, compatible_typecache)
	if(incompatible_types && incompatible_types.len)
		. = !is_type_in_typecache(what, incompatible_typecache)

/obj/item/component/proc/GrantComponentActions(mob/user, human_occupant = 0)
	if(component_actions && component_actions.len)
		for(var/v in component_actions)
			var/datum/action/innate/driveable/action = v
			action.Grant(user, chassis, src)

/obj/item/component/proc/RemoveComponentActions(mob/user)
	if(component_actions && component_actions.len)
		for(var/v in component_actions)
			var/datum/action/innate/driveable/action = v
			action.Remove(user)