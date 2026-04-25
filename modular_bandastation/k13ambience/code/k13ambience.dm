/*
    СИСТЕМА ЭМБИЕНТА ДЛЯ КАТОРГИ-13
*/

// 1. Глобальная переменная для доступа к менеджеру
GLOBAL_DATUM(K13_SOUNDS, /datum/k13_sounds)

/datum/k13_sounds
	var/list/bg_loop = list(
		'modular_bandastation/k13ambience/sounds/ambient/spaceambient1.ogg',
		'modular_bandastation/k13ambience/sounds/ambient/spaceambient2.ogg',
		'modular_bandastation/k13ambience/sounds/ambient/spaceambient3.ogg',
		'modular_bandastation/k13ambience/sounds/ambient/spaceambient4.ogg',
		'modular_bandastation/k13ambience/sounds/ambient/spaceambient5.ogg',
		'modular_bandastation/k13ambience/sounds/ambient/spaceambient6.ogg',
		'modular_bandastation/k13ambience/sounds/ambient/spaceambient7.ogg',
		'modular_bandastation/k13ambience/sounds/ambient/spaceambient8.ogg',
		'modular_bandastation/k13ambience/sounds/ambient/spaceambient9.ogg',
		'modular_bandastation/k13ambience/sounds/ambient/spaceambient11.ogg',
		'modular_bandastation/k13ambience/sounds/ambient/spaceambient12.ogg',
		'modular_bandastation/k13ambience/sounds/ambient/spaceambient13.ogg',
		'modular_bandastation/k13ambience/sounds/ambient/spaceambient14.ogg',
		'modular_bandastation/k13ambience/sounds/ambient/spaceambient15.ogg',
		'modular_bandastation/k13ambience/sounds/ambient/spaceambient16.ogg',
		'modular_bandastation/k13ambience/sounds/ambient/spaceambient17.ogg'
	)

	var/list/metal_creaks = list(
		'modular_bandastation/k13ambience/sounds/creaks/creak_1.ogg',
		'modular_bandastation/k13ambience/sounds/creaks/creak_2.ogg',
		'modular_bandastation/k13ambience/sounds/creaks/creak_3.ogg',
		'modular_bandastation/k13ambience/sounds/creaks/creak_4.ogg',
		'modular_bandastation/k13ambience/sounds/creaks/creak_5.ogg',
		'modular_bandastation/k13ambience/sounds/creaks/creak_6.ogg',
		'sound/effects/creak/creak1.ogg',
		'sound/effects/creak/creak2.ogg',
		'sound/effects/creak/creak3.ogg',
		'modular_bandastation/k13ambience/sounds/whispers/whisper_1.ogg',
		'modular_bandastation/k13ambience/sounds/whispers/whisper_2.ogg',
		'modular_bandastation/k13ambience/sounds/whispers/whisper_3.ogg',
		'modular_bandastation/k13ambience/sounds/whispers/whisper_4.ogg',
		'modular_bandastation/k13ambience/sounds/whispers/whisper_5.ogg',
		'modular_bandastation/k13ambience/sounds/whispers/whisper_6.ogg',
		'modular_bandastation/k13ambience/sounds/whispers/whisper_7.ogg',
		'modular_bandastation/k13ambience/sounds/whispers/whisper_8.ogg',
		'modular_bandastation/k13ambience/sounds/whispers/whisper_9.ogg'
	)

/datum/k13_sounds/proc/start_ambience(mob/living/L)
	if(!L || !L.client)
		return

	L << "<b>[L.name]</b>, система эмбиента Катарги запущена."

	spawn(0)
		handle_background(L)
	spawn(0)
		handle_creaks(L)

/datum/k13_sounds/proc/handle_background(mob/living/L)
	while(L && L.client && L.stat != DEAD)
		var/track = pick(bg_loop)

		var/sound/S = sound(track)
		S.channel = 70
		S.volume = 30
		S.wait = 1    // Ждем окончания трека
		S.repeat = 0
		// Строки fadein/fadeout удалены, так как они не поддерживаются версией

		L << S

		// Ждем 2 секунды после того, как звук "прогрузился",
		// и висим на wait=1 до конца аудиофайла.
		sleep(20)

/datum/k13_sounds/proc/handle_creaks(mob/living/L)
	while(L && L.client && L.stat != DEAD)
		sleep(rand(300, 700))
		if(prob(40))
			var/creak_file = pick(metal_creaks)
			var/sound/S = sound(creak_file)
			S.channel = 71
			S.volume = rand(15, 25)
			S.pitch = rand(8, 12) * 0.1
			S.environment = 21
			S.echo = 1
			L << S

// --- ПОДКЛЮЧЕНИЕ ---

/mob/living/carbon/human/Initialize(mapload)
	. = ..()
	spawn(10)
		if(!GLOB.K13_SOUNDS)
			GLOB.K13_SOUNDS = new /datum/k13_sounds()
		GLOB.K13_SOUNDS.start_ambience(src)

/mob/living/carbon/human/death(gibbed)
	..()
	src << sound(null, channel = 70)
	src << sound(null, channel = 71)

/area/awaymission/katorga
	ambience_index = null

/area/space/nearstation
	ambience_index = null

/area/awaymission/katorga/asteroid
	ambience_index = null
