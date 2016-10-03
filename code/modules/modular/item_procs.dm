/obj/item/proc/get_m_holder()
	if(!module_holder)
		return
	var/obj/module_holder/holder = module_holder
	if(!istype(holder))
		return
	return holder

/obj/item/proc/unarmed_attack(atom/A, mob/user, proximity)
	var/obj/module_holder/holder = get_m_holder()
	if(holder && holder.on_unarmed_attack(A, user, proximity))
		return 1

/obj/item/proc/ranged_attack(atom/A, mob/user, proximity)
	var/obj/module_holder/holder = get_m_holder()
	if(holder && holder.on_ranged_attack(A, user, proximity))
		return 1

/obj/item/proc/melee_attack(atom/A, mob/user, proximity)
	var/obj/module_holder/holder = get_m_holder()
	if(holder && holder.on_melee_attack(A, user, proximity))
		return 1