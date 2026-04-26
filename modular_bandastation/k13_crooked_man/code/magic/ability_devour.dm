/datum/action/cooldown/spell/crooked_devour
	name = "Поглощение"
	desc = "Поглощает цель перед собой. Повторное использование выплюнет жертву."
	button_icon = 'icons/mob/actions/actions_xeno.dmi'
	button_icon_state = "gut"
	cooldown_time = 10 SECONDS
	spell_requirements = NONE

	/// Список поглощенных жертв
	var/list/devoured_victims = list()
	/// Урон от токсинов за тик
	var/digestion_damage = 5
	/// Интервал урона
	var/digestion_interval = 2 SECONDS

/datum/action/cooldown/spell/crooked_devour/cast(atom/cast_on)
	. = ..()

	var/mob/living/caster = owner
	if(!caster)
		return FALSE

	// Проверяем, есть ли уже поглощенные жертвы - если да, выплевываем первую
	if(length(devoured_victims))
		var/mob/living/stored_victim = devoured_victims[1]
		if(stored_victim && !QDELETED(stored_victim))
			// Находим желудок с этой жертвой
			for(var/obj/item/storage/devour_stomach/stomach in caster)
				if(stomach.victim == stored_victim)
					stomach.release_victim(forced = TRUE)
					return TRUE
		// Если жертва уже удалена, очищаем список
		devoured_victims -= stored_victim
		return FALSE

	// Ищем цель перед собой
	var/turf/target_turf = get_step(caster, caster.dir)
	if(!target_turf)
		return FALSE

	var/mob/living/victim = null
	for(var/mob/living/L in target_turf)
		if(L != caster && L.stat != DEAD)
			victim = L
			break

	if(!victim)
		to_chat(caster, span_warning("Перед вами нет подходящей цели!"))
		return FALSE

	// Визуальные и звуковые эффекты
	caster.visible_message(
		span_danger("[caster] хватает [victim] и затягивает внутрь себя!"),
		span_notice("Вы поглощаете [victim].")
	)

	victim.visible_message(
		span_danger("[victim] исчезает внутри [caster]!"),
		span_userdanger("Вас затягивает в искаженное пространство!")
	)

	playsound(get_turf(caster), 'sound/effects/goresplat.ogg', 75, TRUE)
	playsound(get_turf(victim), 'sound/effects/blob/blobattack.ogg', 50, TRUE)

	// Создаем контейнер для жертвы (как bluespace мешок)
	var/obj/item/storage/devour_stomach/stomach = new(caster)
	stomach.stomach_master = caster
	stomach.victim = victim

	// Помещаем жертву в "желудок"
	victim.forceMove(stomach)
	devoured_victims += victim

	// Запускаем процесс переваривания
	START_PROCESSING(SSobj, stomach)

	to_chat(victim, span_danger("Вы окружены едкой кислотой! Она медленно разъедает вас изнутри!"))

	return TRUE

// Специальный "желудок" - контейнер для поглощенных жертв
/obj/item/storage/devour_stomach
	name = "искаженное пространство"
	desc = "Вы не должны этого видеть."
	icon = 'icons/effects/effects.dmi'
	icon_state = "nothing"

	/// Владелец (босс)
	var/mob/living/stomach_master
	/// Жертва внутри
	var/mob/living/victim
	/// Урон за тик
	var/damage_per_tick = 3
	/// Интервал между тиками
	var/tick_interval = 2 SECONDS
	/// Время последнего тика
	var/last_tick = 0

/obj/item/storage/devour_stomach/Initialize(mapload)
	. = ..()
	last_tick = world.time

/obj/item/storage/devour_stomach/process(seconds_per_tick)
	if(!victim || QDELETED(victim) || !stomach_master || QDELETED(stomach_master))
		release_victim()
		return PROCESS_KILL

	// Проверяем интервал
	if(world.time < last_tick + tick_interval)
		return

	last_tick = world.time

	// Наносим токсичный урон
	if(victim.stat != DEAD)
		victim.apply_damage(damage_per_tick, TOX)
		to_chat(victim, span_danger("Желудочный сок разъедает ваше тело!"))

		// Звук переваривания
		victim.playsound_local(get_turf(victim), 'sound/effects/wounds/splatter.ogg', 30, TRUE)

		// Проверяем, жива ли еще жертва
		if(victim.stat == DEAD)
			to_chat(victim, span_deadsay("Вы растворились в желудочном соке..."))
			stomach_master.visible_message(span_danger("[stomach_master] издает звук, похожий на смех."))
			playsound(get_turf(stomach_master), 'modular_bandastation/k13_crooked_man/sounds/Lauth.ogg', 80, TRUE)
	else
		// Если жертва мертва, держим её еще немного, потом выплевываем
		addtimer(CALLBACK(src, PROC_REF(release_victim)), 10 SECONDS)
		return PROCESS_KILL

/obj/item/storage/devour_stomach/proc/release_victim(forced = FALSE)
	if(!victim || QDELETED(victim))
		qdel(src)
		return

	var/turf/release_turf = get_turf(stomach_master)
	if(!release_turf)
		release_turf = get_turf(src)

	victim.forceMove(release_turf)

	if(stomach_master)
		stomach_master.visible_message(
			span_danger("[stomach_master] изрыгает [victim]!"),
			span_notice("Вы выплевываете [victim].")
		)

		// Удаляем из списка поглощенных
		var/datum/action/cooldown/spell/crooked_devour/devour_spell = locate() in stomach_master.actions
		if(devour_spell)
			devour_spell.devoured_victims -= victim

	playsound(release_turf, 'sound/effects/goresplat.ogg', 75, TRUE)

	// Эффект слизи
	new /obj/effect/decal/cleanable/vomit(release_turf)

	to_chat(victim, span_notice("Вас выплюнули наружу!"))

	qdel(src)

/obj/item/storage/devour_stomach/Destroy()
	if(victim && !QDELETED(victim))
		var/turf/T = get_turf(stomach_master) || get_turf(src)
		if(T)
			victim.forceMove(T)

	victim = null
	stomach_master = null
	return ..()
