// ============================================================
// Rust-Forged Labyrinth — Content Module: Horror Ambience (D3)
//
// Фоновый loop, рассылающий жуткие to_chat сообщения всем живым
// мобам в zone_area сектора. Интервал 30–60 секунд.
// apply() запускает loop; clear() останавливает через флаг running.
// ============================================================

/datum/labyrinth_content_module/horror_ambience
	module_name = "horror_ambience"

	var/running = FALSE

	var/static/list/ambient_messages = list(
		"Где-то вдали что-то тяжёлое ударяет по металлу. Ритмично. Неустанно.",
		"Стены дышат. Ты можешь это слышать, если замрёшь.",
		"Запах горячего железа становится сильнее. Источник не виден.",
		"Из-за угла слышится протяжный скрип цепей. Потом — тишина.",
		"На секунду кажется, что кто-то стоит прямо за тобой.",
		"Твоё дыхание звучит слишком громко здесь.",
		"Пол под ногами слегка вибрирует. Что-то движется глубоко внизу.",
		"Тьма здесь не просто темнота. Она наблюдает.",
		"Ты слышишь чей-то кашель — и понимаешь, что ты был один.",
		"Что-то капает. Ты предпочитаешь не проверять что именно.",
		"Звук механизмов приближается. Потом исчезает.",
		"Стены покрыты ржавчиной, но царапины на ней — свежие.",
		"Кто-то здесь уже был до тебя. Они не ушли сами.",
		"На мгновение тебе кажется, что ты видишь силуэт. Он не двигается.",
		"Воздух становится горячим, как от раскалённого металла.",
		"Ты слышишь своё имя — но некому его произнести.",
		"Здесь когда-то работали. Потом перестали. Потом появилось это место.",
		"Механизмы никогда не останавливаются. Никогда.",
	)

	var/static/list/loud_messages = list(
		"ГРОМ МЕТАЛЛА РАЗНОСИТСЯ ПО ВСЕМУ КОРИДОРУ.",
		"ЧТО-ТО БОЛЬШОЕ ДВИЖЕТСЯ ГДЕ-ТО РЯДОМ.",
		"МЕТАЛЛИЧЕСКИЙ СКРЕЖЕТ ЗАГЛУШАЕТ ВСЕ ОСТАЛЬНЫЕ ЗВУКИ.",
	)

/datum/labyrinth_content_module/horror_ambience/apply(datum/rust_sector/S)
	. = ..()
	running = TRUE
	_loop()

/datum/labyrinth_content_module/horror_ambience/clear()
	running = FALSE
	. = ..()

/datum/labyrinth_content_module/horror_ambience/proc/_loop()
	set waitfor = FALSE
	while(running && !QDELETED(src))
		SLEEP_NOT_DEL(rand(300, 600))
		if(QDELETED(src) || !running)
			return
		_broadcast()

/datum/labyrinth_content_module/horror_ambience/proc/_broadcast()
	if(!owner_sector?.zone_area)
		return

	var/list/recipients = list()
	for(var/mob/living/L in owner_sector.zone_area)
		if(L.stat != DEAD)
			recipients += L

	if(!length(recipients))
		return

	// Редко (10%) — громкое событие для всех
	if(prob(10))
		var/msg = pick(loud_messages)
		for(var/mob/living/L as anything in recipients)
			to_chat(L, span_userdanger(msg))
		playsound(owner_sector.anchor_turf, 'sound/effects/meteorimpact.ogg', 60, TRUE, 30)
		return

	// Обычно — тихое сообщение каждому индивидуально (случайное из списка)
	for(var/mob/living/L as anything in recipients)
		if(prob(70))
			to_chat(L, span_warning(pick(ambient_messages)))
