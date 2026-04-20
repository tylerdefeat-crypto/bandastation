/*
    MODULAR MADNESS SYSTEM
    Использует проверенные методы из magic.txt и mood.txt
*/

/datum/component/madness_handler
	var/madness_next_check = 0
	var/madness_check_interval = 2 SECONDS
	var/madness_isolation_range = 7
	var/madness_terror_level = 0

/datum/component/madness_handler/Initialize()
	if(!ishuman(parent))
		return COMPONENT_INCOMPATIBLE
	START_PROCESSING(SSfastprocess, src)

/datum/component/madness_handler/process(seconds_per_tick)
	var/mob/living/carbon/human/H = parent

	if(QDELETED(H) || H.stat != CONSCIOUS || world.time < madness_next_check)
		return
	madness_next_check = world.time + madness_check_interval

	var/is_alone = TRUE

	// Метод проверки света, взятый из /datum/brain_trauma/magic/lumiphobia
	var/turf/T = H.loc
	if(istype(T) && T.get_lumcount() <= SHADOW_SPECIES_LIGHT_THRESHOLD)
		for(var/mob/living/carbon/human/Other in oview(madness_isolation_range, H))
			// Проверка на механических существ через строку (безопасный метод)
			if(Other.stat == CONSCIOUS && !HAS_TRAIT(Other, "mechanical"))
				is_alone = FALSE
				break
	else
		is_alone = FALSE

	// Логика страха
	if(is_alone)
		madness_terror_level = min(madness_terror_level + 20, 600)
		handle_madness_effects(H)
	else
		madness_terror_level = max(madness_terror_level - 15, 0)
		if(madness_terror_level <= 0)
			H.mob_mood?.clear_mood_event("isolation")

/datum/component/madness_handler/proc/handle_madness_effects(mob/living/carbon/human/H)
	// Эффект 1: Шепот (Hear)
	if(madness_terror_level >= 100 && prob(10))
		var/whisper = pick("Ты слышишь это?", "Они идут за тобой...", "Не оборачивайся.")
		H.Hear(H, null, span_hypnophrase(whisper))

	// Эффект 2: Настроение и Рассудок (из mood.txt)
	if(madness_terror_level >= 300)
		H.mob_mood?.add_mood_event("isolation", /datum/mood_event/isolation_panic)
		// Снижение рассудка (sanity), как в PTSD из mood.txt
		H.mob_mood?.adjust_sanity(-2)

		if(prob(5))
			H.apply_status_effect(/datum/status_effect/jitter)
			H.say(pick("КТО ЗДЕСЬ?!", "МНЕ НУЖЕН СВЕТ!"))
	else
		H.mob_mood?.add_mood_event("isolation", /datum/mood_event/isolation_fear)

	// Эффект 3: Галлюцинации (как в PTSD)
	if(madness_terror_level >= 450 && prob(5))
		H.cause_hallucination(/datum/hallucination/fake_sound/normal/boom, "Madness")

/datum/component/madness_handler/Destroy()
	var/mob/living/carbon/human/H = parent
	H?.mob_mood?.clear_mood_event("isolation")
	STOP_PROCESSING(SSfastprocess, src)
	return ..()

// --- СОБЫТИЯ НАСТРОЕНИЯ ---

/datum/mood_event/isolation_fear
	description = "<span class='notice'>Тут слишком темно...</span>\n"
	mood_change = -5

/datum/mood_event/isolation_panic
	description = "<span class='boldwarning'>ОНИ В ТЕМНОТЕ!</span>\n"
	mood_change = -20


// --- РЕГИСТРАЦИЯ КНОПОК (Исправленная версия) ---

ADMIN_VERB(activate_madness_system_all, R_ADMIN, "Activate Madness System (ALL)", "Включить систему страха для всех живых людей.", ADMIN_CATEGORY_FUN)
	var/activated_count = 0
	for(var/mob/living/carbon/human/H in world)
		if(QDELETED(H) || H.stat == DEAD)
			continue

		// Проверяем наличие компонента перед добавлением
		if(!H.GetComponent(/datum/component/madness_handler))
			// Используем AddComponent вместо _AddComponent для стабильности
			H.AddComponent(/datum/component/madness_handler)
			activated_count++

	log_admin("[key_name(user)] активировал Madness System для [activated_count] игроков.")
	message_admins("[key_name_admin(user)] активировал Madness System для [activated_count] игроков.")

ADMIN_VERB(remove_madness_all, R_ADMIN, "Remove Madness System (ALL)", "Отключить систему страха для всех.", ADMIN_CATEGORY_FUN)
	var/removed_count = 0
	for(var/mob/living/carbon/human/H in world)
		var/datum/component/madness_handler/MH = H.GetComponent(/datum/component/madness_handler)
		if(MH)
			qdel(MH)
			removed_count++

	log_admin("[key_name(user)] отключил Madness System у [removed_count] игроков.")
	message_admins("[key_name_admin(user)] отключил Madness System у [removed_count] игроков.")
