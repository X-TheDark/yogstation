//This allows us to control what gets resolved and in which order
// list/allowed - which slots are allowed to be inserted
// list/order   - the actual order of slots

// Datum uses clothing slot defines from code/_DEFINES/clothing.dm to define allowed slots/their order
/datum/resolve_order
	var/list/allowed
	var/list/order
	var/allow_repeat_slots = FALSE

/datum/resolve_order/human
	allowed = list(slot_head, slot_wear_mask, slot_wear_suit, slot_w_uniform, slot_gloves, slot_shoes, slot_l_store, slot_r_store, slot_belt, slot_back, slot_s_store, slot_wear_id)

/datum/resolve_order/New(list/order)
	Append(order)

/datum/resolve_order/proc/Append(list/order)
	if(!islist(order))
		return
	for(var/v in order)
		if(v in allowed && (!(v in order) || allow_repeat_slots))
			src.order += v

/datum/resolve_order/human/default
	order = list(slot_head, slot_wear_mask, slot_wear_suit, slot_w_uniform, slot_gloves)