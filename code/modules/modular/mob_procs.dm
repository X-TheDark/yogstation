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
/mob/living/carbon/human/proc/m_resolve_modules(atom/A, proximity, resolve_proc, datum/resolve_order/human/order_datum)
	world << "WE HAVE m_resolve_modules INTERCEPTION!"

	if(!order_datum || !istype(order_datum))
		order_datum = new /datum/resolve_order/human/default()
	if(islist(order_datum))
		order_datum = new(order_datum)

	//if the module effects can't be stacked across more than 1 piece of clothing, item, we compare it to this
	var/list/resolved_module_ids
	var/obj/item/clothing/item_to_resolve 

	for(var/v in order_datum.order)
		item_to_resolve = null

		switch(v)
			if(slot_head)
				if(head && isitem(head))
					item_to_resolve = head
			if(slot_wear_mask)
				if(wear_mask && isitem(wear_mask))
					item_to_resolve = wear_mask
			if(slot_wear_suit)
				if(wear_suit && isitem(wear_suit))
					item_to_resolve = wear_suit
			if(slot_w_uniform)
				if(w_uniform && isitem(w_uniform))
					item_to_resolve = w_uniform
			if(slot_gloves)
				if(gloves && isitem(gloves))
					item_to_resolve = gloves
			if(slot_shoes)
				if(shoes && isitem(shoes))
					item_to_resolve = shoes
			if(slot_l_store)
				if(l_store && isitem(l_store))
					item_to_resolve = l_store
			if(slot_r_store)
				if(r_store && isitem(r_store))
					item_to_resolve = r_store
			if(slot_belt)
				if(belt && isitem(belt))
					item_to_resolve = belt
			if(slot_back)
				if(back && isitem(back))
					item_to_resolve = back
			if(slot_s_store)
				if(s_store && isitem(s_store))
					item_to_resolve = s_store
			if(slot_wear_id)
				if(wear_id && isitem(wear_id))
					item_to_resolve = wear_id

		if(item_to_resolve)
			switch(resolve_proc)
				if(UNARMED_ATTACK)
					if(item_to_resolve.m_resolve_UnarmedAttack(A, src, proximity))
						return TRUE
				if(PROJECTILE_ATTACK)
					if(item_to_resolve.m_resolve_RangedAttack(A, src, proximity))
						return TRUE
	return FALSE