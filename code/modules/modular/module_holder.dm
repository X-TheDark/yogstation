/obj/module_holder
	var/module_limit = 0
	var/list/defense_modules
	var/list/assault_modules
	var/list/installed_modules
	var/obj/item/weapon/stock_parts/cell/power_source
	var/list/default_modules
	var/default_removable = TRUE //can the default modules be removed
	var/obj/item/owner //which object is our owner

/obj/module_holder/New(obj/item/owner, obj_name)
	if(!owner)
		return
	..()
	src.owner = owner
	if(default_modules && default_modules.len)
		module_limit += default_modules.len
		for(var/type in default_modules)
			var/obj/item/module/newmod = new type()
			newmod.can_be_removed = default_removable
			install(newmod)
	var/name_string = "Modify Modules"
	if(obj_name)
		name_string += "([obj_name])"
	owner.verbs += new /obj/module_holder/verb/modify_modules(src, name_string)

/obj/module_holder/Destroy()
	if(owner)
		owner.module_holder = null
		owner.verbs -= /obj/module_holder/verb/modify_modules
		owner = null
	return ..()

/obj/module_holder/proc/get_module(id)
	if(installed_modules && installed_modules[id])
		return installed_modules[id]

/obj/module_holder/proc/get_installed_module_list()
	. = list()
	for(var/key in installed_modules)
		. += installed_modules[key]

/obj/module_holder/proc/has_active_module(id)
	if(installed_modules && installed_modules[id])
		var/obj/item/module/module = installed_modules[id]
		if(module.active)
			return TRUE
	return FALSE

/obj/module_holder/proc/install(obj/item/module/module, mob/user)
	if(!istype(module) || !owner)
		return
	if(!installed_modules)
		installed_modules = list()
	if(installed_modules.len >= module_limit)
		return "No more slots to install extra modules."
	if(installed_modules[module.id]) //don't install duplicates in the same item
		return "A module of this type is already installed."
	if(!module.insertable_atoms || !module.insertable_atoms.len)
		return "Tell the coders that insertable_atoms is not defined for this module."
	for(!is_type_in_typecache(owner, module.insertable_atoms))
		return "[owner] does not support this type of module."

	if(module.module_type & MODULE_DEFENSE)
		if(!defense_modules)
			defense_modules = list("global" = list(), "local" = list())
		var/list/def_mod_list
		switch(module.onhit_type)
			if(ONHIT_LOCAL)
				def_mod_list = defense_modules["local"]
				def_mod_list[module.id] = module
			if(ONHIT_GLOBAL)
				def_mod_list = defense_modules["global"]
				def_mod_list[module.id] = module

	if(module.module_type & MODULE_ASSAULT)
		if(!assault_modules)
			assault_modules = list()
		assault_modules[module.id] = module

	user.drop_item() //This is here because inventory code
	module.forceMove(owner)
	installed_modules[module.id] = module
	module.on_install(src, owner)
	return TRUE

/obj/module_holder/proc/remove(obj/item/module/module, force = 0)
	if(!module || (!installed_modules || !installed_modules.len) || !owner)
		return
	if(!installed_modules[module.id])
		return FALSE
	if(!module.can_be_removed && !force)
		return FALSE

	if(module.module_type & MODULE_DEFENSE)
		var/list/def_mod_list
		switch(module.onhit_type)
			if(ONHIT_LOCAL)
				def_mod_list = defense_modules["local"]
				def_mod_list -= module.id
			if(ONHIT_GLOBAL)
				def_mod_list = defense_modules["global"]
				def_mod_list -= module.id

	if(module.module_type & MODULE_ASSAULT)
		assault_modules -= module.id

	module.on_remove(src, owner)
	installed_modules -= module.id
	module.forceMove(get_turf(owner))
	return TRUE

/obj/module_holder/proc/remove_all(force = 0)
	. = FALSE
	for(var/key in installed_modules)
		var/obj/item/module/module_check = installed_modules[key]
		if(remove(module_check, force))
			. = TRUE


/*
    BEWARE OF THE HOOKS

	Reason these are not just bullet_act/hit_reaction/etc is that if someone ever makes these buildable, I don't want anything
	weird happening and I don't want modules to try to react to anything on their own.

	Modules also have these exact proc hooks in them, which these call for ALL active modules
	Hooks are (hook via resolve_modules proc):
	- hooks into UnarmedAttack proc in code/_onclick/other_mobs.dm
	- hooks into RangedAttack proc in code/_onclick/other_mobs.dm
	- hooks into mob ClickOn proc in code/_onclick/click.dm
*/
/obj/module_holder/proc/resolve_assault_modules(atom/A, mob/user, resolve_proc)
	if(!assault_modules || !assault_modules.len)
		return

	var/resolved = FALSE //we will resolve all modules on the item before stopping

	for(var/key in assault_modules)
		var/obj/item/module/module = assault_modules[key]

		switch(resolve_proc)
			if(UNARMED_MELEE_CLICK)
				resolved = module.on_unarmed_attack(A, user)
			if(UNARMED_RANGE_CLICK)
				resolved = module.on_ranged_attack(A, user)
			if(ARMED_MELEE_CLICK)
				resolved = module.on_obj_melee_attack(A, user)
			if(ARMED_RANGE_CLICK)
				resolved = module.on_obj_ranged_attack(A, user)
		
		if(resolved)
			. = TRUE

/obj/module_holder/proc/resolve_defense_modules(atom/I, mob/user, mob/victim, attack_type, which = ONHIT_LOCAL)
	if(!defense_modules)
		return

	var/list/def_mod_list
	
	switch(which)
		if(ONHIT_LOCAL)
			def_mod_list = defense_modules["local"]
		if(ONHIT_GLOBAL)
			def_mod_list = defense_modules["global"]

	if(!def_mod_list || !def_mod_list.len)
		return FALSE

	switch(attack_type)
		if(MELEE_ATTACK)
			. = resolve_melee_defense(I, user, victim, def_mod_list)
		if(UNARMED_ATTACK)
			. = resolve_unarmed_defense(user, victim, def_mod_list)
		if(PROJECTILE_ATTACK)
			. = resolve_projectile_defense(I, null, victim, def_mod_list)
		if(THROWN_PROJECTILE_ATTACK)
			. = resolve_thrown_defense(I, null, victim, def_mod_list)

/obj/module_holder/proc/resolve_projectile_defense(obj/item/projectile/I, mob/user, mob/victim, list/mod_list)
	if(istype(I))
		user = I.firer
	for(var/key in mod_list)
		var/obj/item/module/module = mod_list[key]
		if(module.on_bullet_act(I, user, victim))
			. = TRUE

/obj/module_holder/proc/resolve_melee_defense(obj/item/I, mob/user, mob/victim, list/mod_list)
	for(var/key in mod_list)
		var/obj/item/module/module = mod_list[key]
		if(module.on_attacked_by(I, user, victim))
			. = TRUE

/obj/module_holder/proc/resolve_unarmed_defense(mob/user, mob/victim, list/mod_list)
	for(var/key in mod_list)
		var/obj/item/module/module = mod_list[key]
		if(module.on_attack_hand(user, victim))
			. = TRUE

/obj/module_holder/proc/resolve_thrown_defense(atom/movable/AM, mob/user, mob/victim, list/mod_list)
	if(isobj(AM))
		var/obj/item/thing = AM
		user = thing.thrownby
	for(var/key in mod_list)
		var/obj/item/module/module = mod_list[key]
		if(module.on_hitby(AM, user, victim))
			. = TRUE

//This verb is added to the owner item
/obj/module_holder/verb/modify_modules()
	set name = "Modify Modules"
	set category = "Modules"

	//we are inside of the owner item, but obviously, neither compiler nor runtime can resolve this
	var/obj/item/current_holder = src 

	var/obj/module_holder/module_holder = current_holder.get_m_holder()

	if(!module_holder)
		usr << "<span class='notice'>This is an error : Please notify coders that the verb didn't find the module holder, despite you being able to use it!</span>"
		return
	if(!ishuman(usr))
		usr << "<span class='warning'>You don't have the slightest clue on how to do that.</span>"
		return
	if(!module_holder.installed_modules || !module_holder.installed_modules.len)
		usr << "<span class='warning'>There are no modules to modify.</span>"
		return

	var/dat = module_holder.get_content()
	var/datum/browser/popup = new(usr, "modular", "Modify Modules", 600, 600)
	popup.set_content(dat)
	popup.open()

/obj/module_holder/proc/get_content()
	var/dat = ""

	dat += "<table>"
	for(var/key in installed_modules)
		var/obj/item/module/module = installed_modules[key]
		dat += "<tr><th style='text-align:left'>[module.name]</th><th>State</th>"
		if(!isnull(module.charges))
			dat += "<th>Charges</th>"
		dat += "</tr>"
		dat += "<tr>"
		dat += "<td style='font-size:10px; line-height:1'>[module.verbose_desc]</td><td style='color:[module.active ? "green" : "red"]'><b>[module.active ? "On" : "Off"]</b></td>"
		if(!isnull(module.charges))
			dat += "<td>[module.charges]</td>"
		dat += "<td>"
		dat += "<div>"
		dat += "<A href='?src=\ref[src];target=[module.id];action=\"toggle\"'>Toggle</A>"
		if(module.can_be_removed)
			dat += "<A href='?src=\ref[src];target=[module.id];action=\"eject\"'>Eject</A>"
		dat += "</div>"
		dat += "</td>"
		dat += "</tr>"
		dat += "<br>"
	dat += "</table>"
	return dat

/obj/module_holder/Topic(href, href_list)
	if(href_list["target"])
		var/obj/item/module/module = get_module(href_list["target"])
		if(!istype(module))
			return
		if(href_list["action"])
			var/action = href_list["action"]
			switch(action)
				if("toggle")
					module.toggle()
					updateUsrDialog()
				if("eject")
					if(remove(module))
						updateUsrDialog()