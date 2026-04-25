/datum/action/cooldown/spell/crooked_phase
	name = "Фаза Искажения"
	desc = "Позволяет перемещаться сквозь стены. Повторное нажатие вернет вас в реальность."
	button_icon = 'icons/mob/actions/actions_ecult.dmi'
	button_icon_state = "space_crawl"
	cooldown_time = 2 SECONDS
	spell_requirements = IGNORE_INCAPACITATED
	check_flags = AB_CHECK_CONSCIOUS // Игнорируем фазирование

/datum/action/cooldown/spell/crooked_phase/cast(mob/living/cast_on)
	// Проверяем: либо мы внутри кокона, либо на нас висит трейт фазы
	. = ..()
	var/obj/effect/dummy/phased_mob/spell_jaunt/k13/holder
	if(istype(cast_on.loc, /obj/effect/dummy/phased_mob/spell_jaunt/k13))
		holder = cast_on.loc

	if(holder)
		qdel(holder)
		return TRUE

	// ВХОД
	var/turf/T = get_turf(cast_on)
	if(!T) return FALSE

	cast_on.visible_message(span_danger("[cast_on] издает жуткий хруст и рассыпается!"))
	new /obj/effect/gibspawner/generic(T)
	playsound(T, 'sound/effects/splat.ogg', 100, TRUE)
	playsound(T, 'modular_bandastation/k13_crooked_man/sounds/Sinkhole_exit.ogg', 100, TRUE)

	var/obj/effect/dummy/phased_mob/spell_jaunt/k13/H = new(T)
	H.jaunter = cast_on

	cast_on.forceMove(H)
	cast_on.alpha = 0

	// Используем REF(src), чтобы трейт был привязан к этому спеллу
	ADD_TRAIT(cast_on, TRAIT_MAGICALLY_PHASED, REF(src))

	cast_on.update_mob_action_buttons()
	return TRUE

/datum/action/cooldown/spell/crooked_phase/get_caster_from_target(atom/target)
	return target

/obj/effect/dummy/phased_mob/spell_jaunt/k13
	name = "искажение"
	icon = 'icons/effects/effects.dmi'
	icon_state = "nothing"
	color = "#ff0000"
	alpha = 150

/obj/effect/dummy/phased_mob/spell_jaunt/k13/relaymove(mob/living/user, direction)
	var/turf/next_step = get_step(src, direction)
	if(next_step)
		forceMove(next_step)
	return TRUE

/obj/effect/dummy/phased_mob/spell_jaunt/k13/Destroy()
	var/turf/T = get_turf(src)
	if(!T)
		T = get_turf(jaunter)

	if(jaunter)
		var/mob/living/L = jaunter
		// 1. Сначала возвращаем в мир
		L.forceMove(T)
		L.alpha = 255

		// 2. Снимаем трейт (используем цикл или REF, чтобы наверняка)
		REMOVE_TRAIT(L, TRAIT_MAGICALLY_PHASED, null)

		// 3. Эффекты
		playsound(T, 'sound/effects/magic/cosmic_energy.ogg', 50, TRUE)
		new /obj/effect/temp_visual/space_explosion(T)

		L.update_mob_action_buttons()
		jaunter = null

	return ..()
