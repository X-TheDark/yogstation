/obj/driveable/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/component))
		attempt_construction(W, user)
	else
		. = ..()

/obj/driveable/proc/attempt_construction(obj/item/component/component, mob/user)

/obj/driveable/proc/attempt_installation(obj/item/component/component, mob/user)

/obj/driveable/proc/attempt_upgrade(obj/item/component/component, mob/user)

/obj/driveable/attacked_by(obj/item/I, mob/living/user)

/obj/driveable/bullet_act(obj/item/projectile/P, def_zone)

/obj/driveable/hitby(atom/movable/A)

/obj/driveable/ex_act(severity, target)

/obj/driveable/blob_act(obj/effect/blob/B)

/obj/driveable/emp_act(severity)

/obj/driveable/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)

/obj/driveable/attack_tk()

/obj/driveable/attack_hulk(mob/living/carbon/human/user)

/obj/driveable/attack_hand(mob/living/user)

/obj/driveable/attack_paw(mob/user)

/obj/driveable/attack_alien(mob/living/user)

/obj/driveable/attack_animal(mob/living/simple_animal/user)