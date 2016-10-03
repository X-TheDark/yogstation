/*
	The resolution rules for attacks are as follows:
	1. UnarmedAttack calls m_resolve_UnarmedAttack and resolves the module interactions BEFORE
	   calling attack_hand, so you will try to apply module effects to items on the ground when you click on them, and also
	   modules will be tried to be applied to anything like doors/computers before you interact with it.
	2. Same rules for RangedAttack, really. But it's only called if the thing you clicked is > 1 tile away.
	3. Both of these are resolved after the glove Touch proc that I'm not touching just yet.
	4. The switch on which proc to use reuses attack_type defines (Currently UNARMED_ATTACK, PROJECTILE_ATTACK).

	By default, the equipment module resolution sequence is as thus (these are attack procs for when you click on something with empty hand) - see resolve_order.dm for more info:
	1. Head->Mask->Suit->Jumpsuit->Gloves (no boots)
	2. Modules have a unique_resolution variable in them, which means that only one of the same module can be resolved.
	   We use a list that we pass around to the module holder procs on all items.
	3. UnarmedAttack is going to be called if the target is adjecent
	4. RangedAttack is only going to be called if you are not adjecent to the clicked thing

	Oh, right, there's also no checks for src == clicked_thing
	These are called in code/_onclick/other_mobs.dm UnarmedAttack/RangedAttack procs.

	Everything is handled using the 'resolve_order' datum that controls the order in which items are resolved
	This proc uses clothing slot defines from code/_DEFINES/clothing.dm to compare them to the datum's order list
*/
/mob/proc/resolve_modules(atom/A, proximity, resolve_proc, datum/resolve_order/order)
	return

/mob/living/carbon/human/resolve_modules(atom/A, proximity, resolve_proc, datum/resolve_order/order)

	var/datum/resolve_order/resolve_order

	if(!istype(order))
		resolve_order = get_order_datum(resolve_proc)
	else
		resolve_order = order

	if(islist(order))
		resolve_order.Append(order)

	if(!resolve_order || !resolve_order.order || !resolve_order.order.len)
		return FALSE

	//this will be used for uniquely resolving modules so we don't resolve more than one of those
	var/list/resolved_module_ids
	var/obj/item/item_to_resolve 

	for(var/v in resolve_order.order)
		item_to_resolve = get_item_by_slot(v)

		if(item_to_resolve && istype(item_to_resolve))
			switch(resolve_proc)
				if(UNARMED_ATTACK)
					if(item_to_resolve.unarmed_attack(A, src, proximity))
						return TRUE
				if(PROJECTILE_ATTACK)
					if(item_to_resolve.ranged_attack(A, src, proximity))
						return TRUE
				if(MELEE_ATTACK)
					if(item_to_resolve.melee_attack(A, src, proximity))
						return TRUE
	return FALSE

/*
	Order datum helpers
	get_order_datum() - returns the datum which describes which slots are allowed to be processed/added for that type of mob
		attack_type is used to determine the default order of resolution, mobs/carbons don't use this by default
*/
/mob/proc/get_order_datum(attack_type)
	var/datum/resolve_order/mob/order = new()
	return order

/mob/living/carbon/get_order_datum(attack_type)
	var/datum/resolve_order/carbon/order = new()
	return order

/mob/living/carbon/human/get_order_datum(attack_type)
	var/datum/resolve_order/human/order
	if(attack_type)
		switch(attack_type)
			if(UNARMED_ATTACK, PROJECTILE_ATTACK) //resolve all default (see comment block at the top) equipment
				order = new /datum/resolve_order/human/default()
			if(MELEE_ATTACK) //only resolve the item we are attacking with
				order = new()
				if(hand)
					order.Append(slot_l_hand)
				else
					order.Append(slot_r_hand)
	else
		order = new()
	return order