/obj/item/clothing/gloves/modular
	desc = "Highly tecnhnological gloves that can accept module cartridges expanding their functionality. These ones are merely a prototype and do not accept any modules. Spawn a subtype of these instead."
	name = "prototype modular gloves"
	icon_state = "black"
	item_state = "bgloves"
	item_color = "brown"
	burn_state = FIRE_PROOF

	//Module stuff
	var/obj/module_holder/module_holder

/obj/item/clothing/gloves/modular/New()
	..()
	module_holder = new /obj/module_holder(src, null, "Gloves")

/obj/item/clothing/gloves/modular/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/module))
		if(!module_holder) //something is seriously wrong
			user << "<span class='warning'>This equipment doesn't support modules.</span>"
			return
		var/return_value = module_holder.install(I, user)
		if(return_value != 1) //1 if success, otherwise message
			user << "<span class='warning'>[return_value]</span>"
		else
			user << "<span class='notice'>You successfully install \the [I.name] into [src]."
	if(istype(I, /obj/item/weapon/screwdriver))
		if(!module_holder)
			user << "<span class='warning'>There doesn't seem to be anything to remove...</span>"
			return
		if(module_holder.remove_all())
			user << "<span class='notice'>You remove all removable modules from the gloves.</span>"
		else
			user << "<span class='warning'>There are no removable modules in these gloves.</span>"
	..()