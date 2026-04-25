/mob/living/basic/boss/crooked_man
	name = "Скрюченный человек"
	desc = "Его движения неестественны, а каждый сустав будто вывернут наизнанку."
	icon = 'modular_bandastation/k13_crooked_man/icons/crooked_man.dmi'
	icon_state = "crookedman"
	icon_dead = "dead"

	maxHealth = 1000000
	health = 1000000

	armour_penetration = 40
	melee_damage_lower = 40
	melee_damage_upper = 40
	melee_attack_cooldown = 1 SECONDS

	speed = 2
	attack_sound = 'modular_bandastation/k13_crooked_man/sounds/impact_1.ogg'

	pixel_x = -32
	base_pixel_x = -32

	faction = list("faithless")
	obj_damage = 1000

	damage_coeff = list(BRUTE = 0.1, BURN = 0.1, TOX = 0, STAMINA = 0, OXY = 0)
	ai_controller = null

/mob/living/basic/boss/crooked_man/Initialize(mapload)
	. = ..()

	add_traits(list(
		TRAIT_GODMODE,
		TRAIT_NODEATH,
		TRAIT_NOGUNS,
		TRAIT_NOBLOOD,
		TRAIT_NODISMEMBER,
		TRAIT_NEVER_WOUNDED,
		TRAIT_NOBREATH,
		TRAIT_STUNIMMUNE,
		TRAIT_SLEEPIMMUNE
	), "crooked_man_innate")

	AddElement(/datum/element/wall_tearer, tear_time = 0.5 SECONDS)

	INVOKE_ASYNC(src, PROC_REF(radio_static_loop))
	INVOKE_ASYNC(src, PROC_REF(breathing_loop))
	AddComponent(/datum/component/blood_walk, \
		blood_type = /obj/effect/decal/cleanable/blood)
	AddElement(/datum/element/footstep, FOOTSTEP_MOB_HEAVY)
	RemoveElement(/datum/element/simple_flying)

	// ИСПОЛЬЗУЕМ РАЗНЫЕ ПЕРЕМЕННЫЕ ДЛЯ СПОСОБНОСТЕЙ
	var/datum/action/cooldown/spell/crooked_phase/phase_ability = new(src)
	phase_ability.Grant(src)

	// Теперь используем stomp_ability вместо P, чтобы не было дубликата
	var/datum/action/cooldown/spell/aoe/ability_stomp/stomp_ability = new(src)
	stomp_ability.Grant(src)

	var/datum/action/cooldown/spell/cone/staggered/crooked_vomit_cone/vomit_ability = new(src)
	vomit_ability.Grant(src)

/mob/living/basic/boss/crooked_man/proc/breathing_loop()
	while(src && !QDELETED(src) && stat != DEAD)
		playsound(src, 'modular_bandastation/k13_crooked_man/sounds/Breathing.ogg', 70, FALSE, 8, 0.7)
		sleep(40)

/mob/living/basic/boss/crooked_man/proc/radio_static_loop()
	while(src && !QDELETED(src) && stat != DEAD)
		for(var/mob/M in get_hearers_in_view(7, src))
			if(M == src || !M.client)
				continue
			M.playsound_local(src, 'modular_bandastation/k13_crooked_man/sounds/static.ogg', 20, FALSE, 7, 0.2, falloff_distance = 1)
		sleep(10)

/*
// Absolute crutch. Never do it like this, I beg you.
/datum/element/footstep/Attach(datum/target, footstep_type, volume, e_range, sound_vary)
	. = ..()
	if(footstep_type == "crooked_man")
		footstep_sounds = 'modular_bandastation/k13_crooked_man/sounds/Step_1.ogg'
*/
