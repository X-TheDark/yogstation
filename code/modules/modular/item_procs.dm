/obj/item/proc/m_resolve_UnarmedAttack(atom/A, mob/user, proximity)
	if(!module_holder)
		return FALSE
	var/obj/module_holder/holder = module_holder
	if(!istype(holder))
		return FALSE
	if(holder.on_UnarmedAttack(A, user, proximity))
		return 1

/obj/item/proc/m_resolve_RangedAttack(atom/A, mob/user, proximity)
	if(!module_holder)
		return FALSE
	var/obj/module_holder/holder = module_holder
	if(!istype(holder))
		return FALSE
	if(holder.on_RangedAttack(A, user, proximity))
		return 1