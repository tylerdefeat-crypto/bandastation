/datum/action/cooldown/spell/cone/staggered/crooked_vomit_cone
	name = "Извержение желчи"
	desc = "Босс изрыгает массивный конус кислоты, заливающий всё впереди."
	button_icon = 'icons/mob/actions/actions_xeno.dmi'
	button_icon_state = "alien_neurotoxin"
	cooldown_time = 5 SECONDS
	spell_requirements = NONE

	cone_levels = 4 // Дистанция плевка
	respect_density = TRUE
	delay_between_level = 0.1 SECONDS

/datum/action/cooldown/spell/cone/staggered/crooked_vomit_cone/cast(atom/cast_on)
	// Эффект брызг ПЕРЕД мобом
	var/turf/spawn_turf = get_step(owner, owner.dir)
	if(spawn_turf)
		var/obj/effect/temp_visual/dir_setting/bloodsplatter/S = new(spawn_turf)
		S.icon = 'icons/effects/blood.dmi'
		S.icon_state = "hitsplatter3"
		S.color = "#4cff00"
		S.setDir(owner.dir)

	playsound(owner, 'sound/effects/refill.ogg', 80, TRUE)
	return ..()

/datum/action/cooldown/spell/cone/staggered/crooked_vomit_cone/do_turf_cone_effect(turf/target_turf, mob/living/caster, level)
	if(!target_turf)
		return

	// Проверяем, нет ли уже лужи на этом турфе
	if(locate(/obj/effect/decal/cleanable/vomit/toxic/crooked) in target_turf)
		return

	// Создаем лужу с большей вероятностью на ближних уровнях
	var/spawn_chance = 100 - (level * 15) // 85% на уровне 1, 70% на уровне 2, и т.д.
	if(prob(spawn_chance))
		new /obj/effect/decal/cleanable/vomit/toxic/crooked(target_turf)

/datum/action/cooldown/spell/cone/staggered/crooked_vomit_cone/do_mob_cone_effect(mob/living/victim, atom/caster, level)
	if(victim == caster)
		return

	// Урон уменьшается с расстоянием
	var/damage = max(15, 35 - (level * 5)) // 30 на уровне 1, 25 на уровне 2, и т.д.
	victim.apply_damage(damage, TOX)
	victim.adjust_disgust(50)

	// Визуальный эффект
	new /obj/effect/temp_visual/dir_setting/bloodsplatter(get_turf(victim), turn(caster.dir, 180))

	to_chat(victim, span_danger("Вас окатило зловонной желудочной кислотой!"))

// Сама лужа (остается без изменений, используется из Crossed для урона под ногами)
/obj/effect/decal/cleanable/vomit/toxic/crooked
	name = "желудочный сок"
	desc = "Шипящая и вонючая лужа. Она разъедает даже металл."
	color = "#4cff00"

/obj/effect/decal/cleanable/vomit/toxic/crooked/proc/on_entered(datum/source, atom/movable/AM)
	SIGNAL_HANDLER

	if(!isliving(AM))
		return

	var/mob/living/victim = AM

	// Летающие существа не получают урон
	if(victim.movement_type & MOVETYPES_NOT_TOUCHING_GROUND)
		return

	// Урон с высокой вероятностью
	if(prob(85))
		if(ishuman(victim))
			var/mob/living/carbon/human/H = victim
			var/picked_def_zone = pick(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
			var/obj/item/bodypart/leg = H.get_bodypart(picked_def_zone)
			if(leg)
				H.apply_damage(15, BURN, leg)
			else
				H.apply_damage(15, BURN)
		else
			victim.apply_damage(15, BURN)

		playsound(victim, 'sound/effects/wounds/splatter.ogg', 50, TRUE)
		to_chat(victim, span_danger("Кислота обжигает ваши ноги!"))

/obj/effect/decal/cleanable/vomit/toxic/crooked/proc/delete_vomit()
	Destroy()

/obj/effect/decal/cleanable/vomit/toxic/crooked/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	addtimer(CALLBACK(src, PROC_REF(delete_vomit)), 15 SECONDS)
