/obj/item/clothing/gloves/modular/
	desc = "Highly tecnhnological gloves that can accept module cartridges expanding their functionality. These ones are merely a prototype and do not accept any modules. Spawn a subtype of these instead."
	name = "prototype modular gloves"
	icon_state = "black"
	item_state = "bgloves"
	item_color = "brown"
	burn_state = FIRE_PROOF

	//Module stuff
	var/datum/module_holder/module_holder
	var/holder_type = /datum/module_holder


/obj/item/clothing/gloves/modular/New()
	..()
	module_holder = new holder_type(src)

/obj/item/clothing/gloves/modular/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/module))
		if(!module_holder) //something is seriously wrong
			user << "<span class='warning'>This equipment doesn't support modules.</span>"
			return
		var/return_value = module_holder.install(I, user)
		if(return_value != 1) //1 if success, otherwise message
			user << "<span class='warning'>[return_value]</span>"
			return
	if(istype(I, /obj/item/weapon/screwdriver))
		if(!module_holder)
			user << "<span class='warning'>There doesn't seem to be anything to remove...</span>"
			return
		if(module_holder.detach_all())
			user << "<span class='notice'>You remove all modules from the gloves.</span>"
		else
			user << "<span class='warning'>There are no removable modules in these gloves.</span>"
	..()

//Modification menu, made a verb, so you can access it even if gloves are equipped
/obj/item/clothing/gloves/modular/verb/modify()
	set category = "Gloves"
	set name = "Modify Modules"

	if(!ishuman(usr))
		usr << "<span class='warning'>You don't have the slightest clue on how to do that.</span>"
		return
	if(!module_holder || !module_holder.installed_modules || !module_holder.installed_modules.len)
		usr << "<span class='warning'>There are no modules to modify.</span>"
		return

	var/datum/browser/menu = new(usr, "modular_gloves", "Modify Modules", 600, 600)
	menu.open()

/obj/item/clothing/gloves/modular/Topic(href, href_list)