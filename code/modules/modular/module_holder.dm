/obj/module_holder
	var/module_limit = 0
	var/list/installed_modules
	var/obj/item/weapon/stock_parts/cell/power_source
	var/list/default_modules
	var/default_removable = TRUE //can the default modules be removed
	var/obj/item/owner //which object is our owner

/obj/module_holder/New(obj/item/owner, obj_name)
	if(!owner)
		return
	src.owner = owner
	if(default_modules)
		module_limit += default_modules.len
		for(var/type in default_modules)
			var/obj/item/module/newmod = new type()
			newmod.can_be_removed = default_removable
			install(newmod)
	if(obj_name)
		verbs -= /obj/module_holder/verb/modify_modules
		verbs += new /obj/module_holder/verb/modify_modules(src, "Modify Modules([obj_name])")
	owner.verbs += verbs

/obj/module_holder/Destroy()
	if(owner)
		var/obj/module_holder/module_holder = owner.module_holder
		if(istype(module_holder))
			owner.verbs -= verbs
		owner = null

/obj/module_holder/proc/get_module(id)
	if(installed_modules && installed_modules[id])
		return installed_modules[id]

/obj/module_holder/proc/get_installed_module_list()
	. = list()
	for(var/key in installed_modules)
		. += installed_modules[key]

/obj/module_holder/proc/module_exists(id)
	if(installed_modules && installed_modules[id])
		return TRUE
	return FALSE

/obj/module_holder/proc/is_active(id)
	if(installed_modules && installed_modules[id])
		var/obj/item/module/module = installed_modules[id]
		if(module.active)
			return TRUE
	return FALSE

/obj/module_holder/proc/get_applicable_modules(range, atom/target, mob/user)
	. = list()
	for(var/key in installed_modules)
		var/obj/item/module/module = installed_modules[key]
		if(module.active && module.can_be_applied(target))
			. += module

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

	user.drop_item() //This is here because inventory code
	module.forceMove(owner)
	module.on_install(src, owner)
	installed_modules[module.id] = module
	return TRUE

/obj/module_holder/proc/remove(obj/item/module/module, force = 0)
	if(!module || !installed_modules || !owner)
		return
	if(!installed_modules[module.id])
		return FALSE
	if(!module.can_be_removed && !force)
		return FALSE

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

/obj/module_holder/proc/apply_all_modules(atom/target, mob/user)
	if(!target || !user)
		return

	for(var/m in get_applicable_modules(target, user))
		var/obj/item/module/module = m
		module.apply(target, user)

/obj/module_holder/proc/apply_module(id, atom/target, mob/user)
	if(!id || !installed_modules[id] || !target || !user)
		return

	var/obj/item/module/module = installed_modules[id]

	if(module.can_be_applied(target))
		return module.apply(target, user)

/*
	Reason these are not just bullet_act/hit_reaction/etc is that if someone ever makes these buildable, I don't want anything
	weird happening and I don't want modules to try to react to anything on their own.

	Modules also have these exact proc hooks in them, which this calls for ALL active modules
	Hooks are:
	- on_Hit : hooks to hit_reaction for weapons/clothing in item_procs.dm
	- on_RangedAttack : hooks to RangedAttack proc in code/_onclick/other_mobs.dm
	- on_UnarmedAttack: hooks to UnarmedAttack proc in code/_onclick/other_mobs.dm
	- on_MeleeAttack  : hooks to mob ClickOn proc in code/_onclick/click.dm
*/
/obj/module_holder/proc/on_hit(mob/living/carbon/human/owner, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK, atom/movable/AT)
/obj/module_holder/proc/on_ranged_attack(atom/A, mob/user, proximity)
/obj/module_holder/proc/on_unarmed_attack(atom/A, mob/user, proximity)
/obj/module_holder/proc/on_melee_attack(atom/A, mob/user, proximity)

//This verb is added to the owner item
/obj/module_holder/verb/modify_modules()
	set name = "Modify Modules"
	set category = "Modules"

	var/obj/module_holder/module_holder = locate() in contents //we are actually inside of owner item now
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