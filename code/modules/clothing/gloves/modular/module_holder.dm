/datum/module_holder
	var/module_limit = 0
	var/list/installed_modules
	var/obj/item/weapon/stock_parts/cell/power_source
	var/list/default_modules
	var/default_removable = TRUE //can the default modules be removed
	var/obj/item/owner //which object is our owner

/datum/module_holder/New(obj/item/owner, obj/item/weapon/stock_parts/cell/power_source)
	..()
	src.owner = owner
	if(default_modules)
		module_limit += default_modules.len
		for(var/type in default_modules)
			var/obj/item/module/newmod = new type()
			newmod.removable = default_removable
			install(newmod)
	//if we are given a cell to use (such as the case with anything that has it's own cell), we'll use that
	if(power_source && power_source.loc == owner) //don't get any big ideas, you cheat
		src.power_source = power_source

/datum/module_holder/proc/get_module(id)
	if(installed_modules && installed_modules[id])
		return installed_modules[id]

/datum/module_holder/proc/get_installed_module_list()
	. = list()
	for(var/key in installed_modules)
		. += installed_modules[key]
	return .

/datum/module_holder/proc/module_exists(id)
	if(installed_modules && installed_modules[id])
		return TRUE
	return FALSE

/datum/module_holder/proc/is_active(id)
	if(installed_modules && installed_modules[id])
		var/obj/item/module/module = installed_modules[id]
		if(module.active)
			return TRUE
	return FALSE

/datum/module_holder/proc/get_applicable_modules(range, atom/target, mob/user)
	. = list()
	for(var/key in installed_modules)
		var/obj/item/module/module = installed_modules[key]
		if(module.active && module.range >= range && module.can_be_applied(target))
			. += module
	return .

/datum/module_holder/proc/install(obj/item/module/module, mob/user)
	if(!istype(module) || !owner)
		return
	if(!installed_modules)
		installed_modules = list()
	if(installed_modules.len >= module_limit)
		return "No more slots to install extra modules."
	if(installed_modules[module.id]) //don't install duplicates in the same item
		return "A module of this type is already installed."

	user.drop_item()
	module.forceMove(owner)
	module.on_install(src)
	installed_modules[module.id] = module
	return 1

/datum/module_holder/proc/detach(obj/item/module/module, force = 0)
	if(!module || !installed_modules || !owner)
		return
	if(!installed_modules[module.id])
		return FALSE
	if(module.removable == FALSE && !force)
		return FALSE

	module.on_remove(src)
	installed_modules -= module.id
	module.forceMove(get_turf(owner))
	return TRUE

/datum/module_holder/proc/detach_all(force = 0)
	. = FALSE
	for(var/key in installed_modules)
		var/obj/item/module/module_check = installed_modules[key]
		if(detach(module_check, force))
			. = TRUE
	return .

/datum/module_holder/proc/apply_all_modules(atom/target, mob/user)
	if(!target || !user)
		return

	for(var/m in get_applicable_modules(get_dist(target, user), target, user))
		var/obj/item/module/module = m
		module.apply(target, user)

/datum/module_holder/proc/apply_module(id, atom/target, mob/user)
	if(!installed_modules[id] || !target || !user)
		return

	var/obj/item/module/module = installed_modules[id]
	if(get_dist(target, user) > module.range)
		return 0
	return module.apply(target, user)