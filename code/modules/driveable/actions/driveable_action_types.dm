// Action classes that are used by the drivables

// Innate action type
/datum/action/innate/driveable
	check_flags = AB_CHECK_RESTRAINED | AB_CHECK_STUNNED | AB_CHECK_CONSCIOUS
	var/obj/driveable/frame/basic/chassis

/datum/action/innate/driveable/Grant(mob/living/L, obj/driveable/frame/basic/D)
	chassis = D
	..()

/datum/action/innate/driveable/Destroy()
	chassis = null
	return ..()

/datum/action/innate/driveable/component
	var/obj/item/component/component

/datum/action/innate/driveable/component/Grant(mob/living/L, obj/driveable/frame/basic/D, obj/item/component/C)
	component = C
	..()

/datum/action/innate/driveable/component/Destroy()
	component = null
	return ..()

/datum/action/innate/driveable/equipment
	var/obj/item/equipment/equipment

/datum/action/innate/driveable/equipment/Grant(mob/living/L, obj/driveable/frame/basic/D, obj/item/equipment/E)
	equipment = E
	..()

/datum/action/innate/driveable/equipment/Destroy()
	equipment = null
	return ..()

// Base class for driveable actions based on items
/datum/action/item_action/driveable
	check_flags = AB_CHECK_RESTRAINED | AB_CHECK_STUNNED | AB_CHECK_CONSCIOUS
	var/obj/driveable/frame/basic/chassis

/datum/action/item_action/driveable/Grant(mob/living/L, obj/driveable/frame/basic/D)
	chassis = D
	..()

// Equipment action type
/datum/action/item_action/driveable/equipment
	var/obj/item/equipment/equipment

/datum/action/item_action/driveable/equipment/Grant(mob/living/L, obj/driveable/frame/basic/D, obj/item/equipment/E)
	equipment = E
	..()

// Component action type
/datum/action/item_action/driveable/component
	var/obj/item/component/component

/datum/action/item_action/driveable/component/Grant(mob/living/L, obj/driveable/frame/basic/D, obj/item/component/C)
	component = C
	..()