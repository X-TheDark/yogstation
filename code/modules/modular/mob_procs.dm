/*
	The resolution rules for attacks are as follows:
	1. UnarmedAttack calls m_resolve_UnarmedAttack and resolves the module interactions BEFORE
	   calling attack_hand, so you will try to apply module effects to items on the ground when you click on them, and also
	   modules will be tried to be applied to anything like doors/computers before you interact with it.
	2. Same rules for RangedAttack, really. But it's only called if the thing you clicked is > 1 tile away.
	3. Both of these are resolved after the glove Touch proc that I'm not touching just yet.

	The equipment module resolution sequence is as thus (these are attack procs for when you click on something with empty hand):
	1. Head->Mask->Suit->Jumpsuit->Gloves (no boots)
	2. Modules have a unique_resolution variable in them, which means that only one of the same module can be resolved.
	   This allows a more flexible resolution schedule. We use a list that we pass around to the module holder proc.
	3. UnarmedAttack is going to be called if the target is adjecent
	4. RangedAttack is only going to be called if you are not adjecent to the clicked thing

	Oh, right, there's also no checks for user == clicked_thing, so your modules could do something...nasty.
	These are called in code/_onclick/other_mobs.dm UnarmedAttack/RangedAttack procs.
*/
/mob/living/carbon/human/proc/m_resolve_UnarmedAttack(atom/A, mob/user, proximity)
	world << "WE HAVE m_resolve_UnarmedAttack INTERCEPTION!"

	var/list/resolved_module_ids
	var/obj/item/clothing/item_to_resolve

	if(head && istype(head, /obj/item))
		item_to_resolve = head
		if(item_to_resolve.module_holder)
			var/obj/module_holder/holder = item_to_resolve.module_holder
			if(istype(holder))
				if(holder.on_UnarmedAttack(A, user, proximity))
					return 1

	if(wear_mask && istype(wear_mask, /obj/item))
		item_to_resolve = wear_mask
		if(item_to_resolve.module_holder)
			var/obj/module_holder/holder = item_to_resolve.module_holder
			if(istype(holder))
				if(holder.on_UnarmedAttack(A, user, proximity))
					return 1

	if(wear_suit && istype(wear_suit, /obj/item))
		item_to_resolve = wear_suit
		if(item_to_resolve.module_holder)
			var/obj/module_holder/holder = item_to_resolve.module_holder
			if(istype(holder))
				if(holder.on_UnarmedAttack(A, user, proximity))
					return 1

	if(w_uniform && istype(w_uniform, /obj/item))
		item_to_resolve = w_uniform
		if(item_to_resolve.module_holder)
			var/obj/module_holder/holder = item_to_resolve.module_holder
			if(istype(holder))
				if(holder.on_UnarmedAttack(A, user, proximity))
					return 1

	if(gloves && istype(gloves, /obj/item))
		item_to_resolve = gloves
		if(item_to_resolve.module_holder)
			var/obj/module_holder/holder = item_to_resolve.module_holder
			if(istype(holder))
				if(holder.on_UnarmedAttack(A, user, proximity))
					return 1


//Copy paste of the above but different attack that gets resolved
//This is inelegant, but easier to manage than switch()-ing the above proc
/mob/living/carbon/human/proc/m_resolve_RangedAttack(atom/A, mob/user, proximity)
	world << "WE HAVE m_resolve_RangedAttack INTERCEPTION!"

	var/list/resolved_module_ids
	var/obj/item/clothing/item_to_resolve

	if(head && istype(head, /obj/item))
		item_to_resolve = head
		if(item_to_resolve.module_holder)
			var/obj/module_holder/holder = item_to_resolve.module_holder
			if(istype(holder))
				if(holder.on_RangedAttack(A, user, proximity))
					return 1

	if(wear_mask && istype(wear_mask, /obj/item))
		item_to_resolve = wear_mask
		if(item_to_resolve.module_holder)
			var/obj/module_holder/holder = item_to_resolve.module_holder
			if(istype(holder))
				if(holder.on_RangedAttack(A, user, proximity))
					return 1

	if(wear_suit && istype(wear_suit, /obj/item))
		item_to_resolve = wear_suit
		if(item_to_resolve.module_holder)
			var/obj/module_holder/holder = item_to_resolve.module_holder
			if(istype(holder))
				if(holder.on_RangedAttack(A, user, proximity))
					return 1

	if(w_uniform && istype(w_uniform, /obj/item))
		item_to_resolve = w_uniform
		if(item_to_resolve.module_holder)
			var/obj/module_holder/holder = item_to_resolve.module_holder
			if(istype(holder))
				if(holder.on_RangedAttack(A, user, proximity))
					return 1

	if(gloves && istype(gloves, /obj/item))
		item_to_resolve = gloves
		if(item_to_resolve.module_holder)
			var/obj/module_holder/holder = item_to_resolve.module_holder
			if(istype(holder))
				if(holder.on_RangedAttack(A, user, proximity))
					return 1