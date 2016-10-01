/obj/item/module
	name = "generic module"
	desc = "A module that can be inserted into equipment that supports modules...although this one is just a dummy that is not functional."
	var/verbose_desc //description to show in the module modification menu
	var/id = "module" //this should be thought of as a slot rather than id, you can only place 1 module with the same id into the holder
	var/can_be_applied = TRUE //Does this module apply anything to anything or is it something passive that isn't checked
	var/mode //Does this module have any specific modes (See 'repulsor module' for an example)
	var/removable = TRUE
	var/active = FALSE // on/off, only modules that are on will be considered for application
	var/obj/module_holder/holder
	//Power cost of each mode, instantiated so people understand the format
	var/power_cost = list("active" = 0, "passive" = 0)
	var/charges //do we have a limited amount of times we can activate?
	var/min_range = 1
	var/max_range = 1
	var/list/applicable_atoms //typecache of things we can be applied to
	var/list/applicable_atom_types //which atom types (and subtypes) the module effects can be applied to will be applied to anything if not defined
	var/list/insertable_atom_types //what this can be inserted into. Requires definition, otherwise module cannot be inserted into anything (this is for safety, you'll have to be explicit in what equipment effects you are going to process in your code)
	var/list/insertable_atoms //typecache of things we can be inserted into

/obj/item/module/New()
	if(max_range < min_range)
		max_range = min_range
	if(insertable_atom_types && insertable_atom_types.len)
		insertable_atoms = typecacheof(insertable_atom_types)
	if(applicable_atom_types && applicable_atom_types.len)
		applicable_atoms = typecacheof(applicable_atom_types)

//All of these procs are designed to be called before in your overriden ones, so call ..() first, then do your custom code
/obj/item/module/proc/apply(atom/target, mob/user)
	if(!target || !user || !holder)
		return
	if(!active)
		return FALSE
	if(power_cost["active"] > 0 && (!holder.power_source || holder.power_source.charge < power_cost["active"]))
		return FALSE

/obj/item/module/proc/can_be_applied(atom/target)
	if(!target || !holder)
		return
	if(!can_be_applied)
		return FALSE
	if(power_cost["active"] > 0 && (!holder.power_source || holder.power_source.charge < power_cost["active"]))
		return FALSE
	if(charges && charges == 0)
		return FALSE
	var/distance = get_dist(src, target)
	if(distance > max_range || distance > min_range)
		return FALSE
	if(applicable_atoms && applicable_atoms.len > 0)
		if(!is_type_in_typecache(target, applicable_atoms))
			return FALSE
	return TRUE

/obj/item/module/proc/on_install(obj/module_holder/holder)
	if(!holder)
		return
	src.holder = holder

//Toggle off before removing, just in case
/obj/item/module/proc/on_remove(obj/module_holder/holder)
	if(!holder)
		return
	if(active)
		toggle()
	holder = null

/obj/item/module/proc/toggle()
	if(!holder)
		return
	if(!active)
		active = TRUE
		on_toggle_on()
	else
		active = FALSE
		on_toggle_off()

/obj/item/module/proc/on_toggle_on()
	if(!holder)
		return

/obj/item/module/proc/on_toggle_off()
	if(!holder)
		return

//This is so hacky, because I have no idea how to standardize something this custom
//The actual code that allows this will be spread over container code/strip code and not actually here...
/obj/item/module/pickpocket
	name = "pickpocket module"
	id = "pickpocket"
	desc = "A module that can be inserted into gloves. Increases aptitude at interacting with target's inventory \
	(faster stripping/new functions) as well as silences any messages caused by container interaction."
	verbose_desc = "This module increases pickpocket speed by 33%, in addition, you are now able to see contents of the target's \
	pockets, belt and backpack in the strip menu. This will also silence your interactions with containers, so people \
	around you won't see any messages of you inserting/taking things out of backpacks/boxes/etc."
	can_be_applied = FALSE //this is checked for existance/activity, but never applies anything to anyone
	insertable_atom_types = list(/obj/item/clothing/gloves/modular)

/obj/item/module/fingerprint_forger
	name = "fingerprint forging module"
	id = "fingerprint_forger"
	desc = "Module that allows you to hack a Security Console to retrieve a random fingerprint from a person (other than yourself). This can only be done once.\n\
	After stealing a fingerprint, you can use this module up to 3 times to erase all fingerprints from an item/structure and replace it with the forgery."
	charges = 3
	insertable_atom_types = list(/obj/item/clothing/gloves)
	applicable_atom_types = list(/obj/machinery/computer/secure_data)