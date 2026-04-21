/*
    MODULAR MADNESS SYSTEM v6.1 - COMPILER FIX
*/

// ОБЪЯВЛЕНИЕ ТИПОВ (Чтобы не было ошибок компиляции)
/datum/movespeed_modifier/madness_slowdown
	multiplicative_slowdown = 0

/datum/component/madness_handler
	var/madness_next_check = 0
	var/madness_check_interval = 20
	var/madness_terror_level = 0
	var/heartbeat_active = FALSE

	var/last_scream_time = 0
	var/last_big_msg_time = 0
	var/last_shadow_time = 0
	var/last_whisper_time = 0

/datum/component/madness_handler/Initialize()
	if(!ishuman(parent))
		return COMPONENT_INCOMPATIBLE
	START_PROCESSING(SSfastprocess, src)

/datum/component/madness_handler/process(seconds_per_tick)
	var/mob/living/carbon/human/H = parent
	if(QDELETED(H) || H.stat != CONSCIOUS || world.time < madness_next_check)
		return
	madness_next_check = world.time + madness_check_interval

	// ЖЕСТКИЙ ФИКС ВИДИМОСТИ
	H.alpha = 255
	H.invisibility = 0
	H.color = null
	if(prob(20))
		H.update_appearance()

	if(check_isolation(H))
		madness_terror_level = min(madness_terror_level + 20, 1000)
		process_madness_logic(H)
	else
		madness_terror_level = max(madness_terror_level - 35, 0)
		if(madness_terror_level < 100)
			cleanup_madness_effects(H)

/datum/component/madness_handler/proc/check_isolation(mob/living/carbon/human/H)
	var/turf/T = H.loc
	if(!istype(T) || T.get_lumcount() > SHADOW_SPECIES_LIGHT_THRESHOLD)
		return FALSE
	for(var/mob/living/carbon/human/Other in oview(7, H))
		if(Other.stat == CONSCIOUS && !HAS_TRAIT(Other, "mechanical"))
			return FALSE
	return TRUE

/datum/component/madness_handler/proc/process_madness_logic(mob/living/carbon/human/H)
	// --- 1. ПЛАВНОЕ ЗАМЕДЛЕНИЕ ---
	if(madness_terror_level > 250)
		var/slow_val = (madness_terror_level - 250) / 500
		H.add_movespeed_modifier(/datum/movespeed_modifier/madness_slowdown, TRUE, 0, slow_val)
	else
		H.remove_movespeed_modifier(/datum/movespeed_modifier/madness_slowdown)

	// --- 2. УРОВНИ БЕЗУМИЯ ---

	// НИЗКИЙ (100-400)
	if(madness_terror_level >= 100)
		if(prob(madness_terror_level / 15))
			H.playsound_local(H, pick('sound/effects/creak/creak1.ogg', 'sound/effects/footstep/plating1.ogg'), 25)

		if(madness_terror_level >= 200 && world.time > last_whisper_time + 300)
			if(prob(15))
				to_chat(H, "<span class='warning' style='font-style: italic;'>[pick("Слышишь скрежет?", "В стенах кто-то есть.", "Не оборачивайся.")]</span>")
				H.apply_status_effect(/datum/status_effect/terrified)
				last_whisper_time = world.time

	// СРЕДНИЙ (400-700)
	if(madness_terror_level >= 400)
		start_heartbeat(H)
		if(prob(10))
			H.manual_emote("дрожит в страхе.")
			H.apply_status_effect(/datum/status_effect/jitter, 50)

		if(prob(8))
			var/speaker = pick("Радист", "Инженер", "Николай")
			var/msg = pick("Помоги мне...", "Оно уже здесь.", "Почему ты не бежишь?")
			to_chat(H, "<span class='game say'><span class='name'>[speaker]</span> шепчет: \"[msg]\"</span>")

	// ВЫСОКИЙ (700-1000)
	if(madness_terror_level >= 700)
		H.overlay_fullscreen("crit_shadow", /atom/movable/screen/fullscreen/crit)

		// Галлюцинации (Безопасный вызов через общие типы)
		if(prob(12) && world.time > last_shadow_time + 200)
			H.cause_hallucination(/datum/hallucination/delusion, "Shadow Person", 50)
			last_shadow_time = world.time

		if(prob(4))
			to_chat(H, span_userdanger("Ноги подкашиваются!"))
			H.Paralyze(30)

		if(prob(20) && world.time > last_big_msg_time + 150)
			to_chat(H, "<span class='userdanger' style='font-size: 20px;'>[pick("ОНО ТУТ", "БЕГИ", "УМРИ")]</span>")
			last_big_msg_time = world.time

		if(prob(25) && world.time > last_scream_time + 180)
			playsound(H, 'sound/effects/magic/cowhead_curse.ogg', 65, TRUE)
			addtimer(CALLBACK(src, .proc/forced_scream, H), 8)
			last_scream_time = world.time

/datum/component/madness_handler/proc/forced_scream(mob/living/carbon/human/H)
	if(QDELETED(H) || H.stat != CONSCIOUS) return
	H.emote("scream")
	var/scream_sound = (H.gender == FEMALE) ? 'sound/mobs/humanoids/human/scream/femalescream_1.ogg' : 'sound/mobs/humanoids/human/scream/malescream_1.ogg'
	playsound(H, scream_sound, 80, TRUE)

/datum/component/madness_handler/proc/start_heartbeat(mob/living/carbon/human/H)
	if(heartbeat_active) return
	var/wait_val = (madness_terror_level > 700) ? 0.5 : 1
	H.playsound_local(H, sound('sound/effects/health/slowbeat.ogg', repeat = TRUE, wait = wait_val), 50, 0, channel = CHANNEL_HEARTBEAT)
	heartbeat_active = TRUE

/datum/component/madness_handler/proc/cleanup_madness_effects(mob/living/carbon/human/H)
	stop_heartbeat(H)
	H.remove_movespeed_modifier(/datum/movespeed_modifier/madness_slowdown)
	H.clear_fullscreen("crit_shadow")
	H.remove_status_effect(/datum/status_effect/terrified)

/datum/component/madness_handler/proc/stop_heartbeat(mob/living/carbon/human/H)
	if(!heartbeat_active) return
	H.stop_sound_channel(CHANNEL_HEARTBEAT)
	heartbeat_active = FALSE

/datum/component/madness_handler/Destroy()
	var/mob/living/carbon/human/H = parent
	cleanup_madness_effects(H)
	STOP_PROCESSING(SSfastprocess, src)
	return ..()

// АДМИН-ВЕРБЫ
ADMIN_VERB(activate_madness_system_all, R_ADMIN, "Activate Madness System (ALL)", "Включить безумие всем.", ADMIN_CATEGORY_FUN)
	for(var/mob/living/carbon/human/H in world)
		if(!QDELETED(H) && H.stat != DEAD && !H.GetComponent(/datum/component/madness_handler))
			H.AddComponent(/datum/component/madness_handler)
	message_admins("Безумие активировано.")

ADMIN_VERB(remove_madness_system_all, R_ADMIN, "Remove Madness System (ALL)", "Выключить безумие.", ADMIN_CATEGORY_FUN)
	for(var/mob/living/carbon/human/H in world)
		var/datum/component/madness_handler/MH = H.GetComponent(/datum/component/madness_handler)
		if(MH) qdel(MH)
	message_admins("Безумие отключено.")
