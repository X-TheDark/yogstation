/obj/item/module
	name = "generic module"
	desc = "A module that can be inserted into equipment that supports modules...although this one is just a dummy that is not functional."
	var/verbose_desc //description to show in the module modification menu
	var/id = "abstract" //this should either be unique or be the same for modules of the same type
	var/removable = TRUE
	var/active = FALSE // on/off, only modules that are on will be considered for application
	var/datum/module_holder/holder
	//Power cost of each mode, instantiated so people understand the format
	var/power_cost = list("active" = 0, "passive" = 0)
	var/range = 1 //range at which these modules are applicable to targets
	var/list/applicable_atom_types //which atom types (and subtypes) the module effects can be applied to

//All of these procs are designed to be called before in your overriden ones, so call ..() first, then do your custom code
/obj/item/module/proc/apply(atom/target, mob/user)
	if(!target || !user)
		return
	if(power_cost["active"] > 0 && (!holder.power_source || holder.power_source.charge < power_cost["active"]))
		return FALSE

/obj/item/module/proc/can_be_applied(atom/target)
	if(!target)
		return
	if(power_cost["active"] > 0 && (!holder.power_source || holder.power_source.charge < power_cost["active"]))
		return FALSE
	for(var/type in applicable_atom_types)
		if(istype(target, type))
			return TRUE

/obj/item/module/proc/on_install(datum/module_holder/holder)
	if(!holder)
		return
	src.holder = holder

//Toggle off before removing, just in case
/obj/item/module/proc/on_remove(datum/module_holder/holder)
	if(active)
		toggle()
	holder = null

/obj/item/module/proc/toggle()
	if(!active)
		active = TRUE
		on_toggle_on()
	else
		active = FALSE
		on_toggle_off()

/obj/item/module/proc/on_toggle_on()

/obj/item/module/proc/on_toggle_off()