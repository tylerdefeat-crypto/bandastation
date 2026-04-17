
//BANSHEE ABILITY SUITE (FIXED FOR BANDASTATION - NO CLOTHES REQ)

// На этом месте был banshee_frozen. Это ну прям очень костыльный способ реализации, у нас уже реализовано это через трейты.

/*
/mob/living/var/banshee_frozen = FALSE

/mob/living/try_speak(message, ignore_spam, forced, filterproof)
	if(banshee_frozen)
		return TRUE
	return ..()

/proc/banshee_thaw(mob/living/carbon/human/H)
	if(!H || !H.banshee_frozen) return
	H.banshee_frozen = FALSE
	H.remove_traits(list(TRAIT_INCAPACITATED, TRAIT_IMMOBILIZED, TRAIT_FLOORED), "banshee_scream")
	to_chat(H, span_notice("Оцепенение проходит. Вы снова можете двигаться."))
*/

// --- AOE SPELLS ---

// MARK: Banshee Scream

/datum/action/cooldown/spell/aoe/banshee_scream
	name = "Banshee's Stasis Scream"
	button_icon = 'modular_bandastation/banshee_skills/icons/banshee_skills.dmi'
	button_icon_state = "banshee_scream"
	cooldown_time = 30 SECONDS
	invocation_type = INVOCATION_SHOUT
	invocation = "НА  КОЛЕНИ!!!"
	garbled_invocation_prob = 0
	spell_requirements = NONE

/datum/action/cooldown/spell/aoe/banshee_scream/can_cast_spell(feedback = TRUE)
	return TRUE

/datum/action/cooldown/spell/aoe/banshee_scream/cast(list/targets)
	. = ..()
	new /obj/effect/temp_visual/circle_wave/void_conduit(get_turf(owner))
	var/obj/effect/temp_visual/V = new /obj/effect/temp_visual(get_turf(owner))
	if(V)
		V.icon = 'icons/effects/96x96.dmi'
		V.icon_state = "void_blink_out"
		V.pixel_x = -32
		V.pixel_y = -32
		V.duration = 1 SECONDS
	playsound(owner.loc, 'modular_bandastation/banshee_skills/sound/banshee_scream3.ogg', 100, TRUE)

// Нам нужно кастовать только на карбонов
/datum/action/cooldown/spell/aoe/banshee_scream/get_things_to_cast_on(atom/center, radius_override)
	var/list/valid = list()
	var/list/o_range = orange(center, radius_override || aoe_radius) - list(owner, center)
	for(var/mob/living/carbon/human/nearby_mob in o_range)
		if(nearby_mob.stat == DEAD)
			continue
		if(issilicon(nearby_mob))
			continue
		valid += nearby_mob
	return valid

// Вот этот кусок кода должен быть в cast_on_thing_in_aoe. В целом cast в данном случае лучше не трогать, но уже пофиг
/datum/action/cooldown/spell/aoe/banshee_scream/cast_on_thing_in_aoe(atom/victim, atom/caster)
	var/mob/living/carbon/human/H = victim
	if(!istype(H))
		return
	if(H == owner || H.stat == DEAD)
		return
	if(H.client)
		shake_camera(H, 4, 3)
	H.add_traits(list(TRAIT_INCAPACITATED, TRAIT_IMMOBILIZED, TRAIT_FLOORED, TRAIT_MUTE), "banshee_scream")
	to_chat(H, span_userdanger("Леденящий душу крик пронзает ваш разум! Вы парализованы!"))

// MARK: Banshee's Death Wail

/datum/action/cooldown/spell/aoe/banshee_death_wail
	name = "Death Wail (AOE GIB)"
	button_icon = 'modular_bandastation/banshee_skills/icons/banshee_skills.dmi'
	button_icon_state = "death_wail"
	cooldown_time = 60 SECONDS
	invocation_type = INVOCATION_SHOUT
	invocation = "УМРИТЕ!!!"
	spell_requirements = NONE
	aoe_radius = 3

/datum/action/cooldown/spell/aoe/banshee_death_wail/can_cast_spell(feedback = TRUE)
	return TRUE

/datum/action/cooldown/spell/aoe/banshee_death_wail/get_things_to_cast_on(atom/center, radius_override)
	var/list/valid = list()
	var/list/o_range = orange(center, radius_override || aoe_radius) - list(owner, center)
	for(var/mob/living/nearby_mob in o_range)
		if(nearby_mob.stat == DEAD)
			continue
		valid += nearby_mob
	return valid

/datum/action/cooldown/spell/aoe/banshee_death_wail/cast(list/targets)
    . = ..()
    playsound(owner.loc, 'modular_bandastation/banshee_skills/sound/banshee_scream.ogg', 100, TRUE)

/datum/action/cooldown/spell/aoe/banshee_death_wail/cast_on_thing_in_aoe(atom/victim, atom/caster)
	var/mob/living/H = victim
	if(!istype(H))
		return
	H.gib()

// --- Banshee's Destructive Wail ---

/datum/action/cooldown/spell/aoe/banshee_destructive_wail
	name = "Destructive Wail"
	button_icon = 'modular_bandastation/banshee_skills/icons/banshee_skills.dmi'
	button_icon_state = "destructive_wail"
	cooldown_time = 45 SECONDS
	invocation = "НАЗАД!!!"
	spell_requirements = NONE

/datum/action/cooldown/spell/aoe/banshee_destructive_wail/can_cast_spell(feedback = TRUE)
	return TRUE

/datum/action/cooldown/spell/aoe/banshee_destructive_wail/cast(list/targets)
	. = ..()
	playsound(owner.loc, 'modular_bandastation/banshee_skills/sound/explosionfar.ogg', 100, TRUE)

/datum/action/cooldown/spell/aoe/banshee_destructive_wail/cast_on_thing_in_aoe(atom/victim, atom/caster)
	if(QDELETED(victim))
		return
	if(victim == owner)
		return
	if(isliving(victim))
		var/mob/living/L = victim
		L.take_overall_damage(40, 0)
		L.throw_at(get_edge_target_turf(L, get_dir(owner, L)), 3, 2)
	// Здесь были объекты. Их лучше не дамажить, т.к. ты дамажишь даже системные абстрактные объекты или органы. Структуры норм.
	else if(isstructure(victim))
		var/obj/structure/O = victim
		O.take_damage(60, BRUTE, "bomb", 0)
	// Не каждый турф - стена. Тут только со стенами работаем.
	else if(iswallturf(victim))
		var/turf/closed/wall/W = victim
		if(prob(40))
			W.dismantle_wall(TRUE)

// --- POINTED SPELLS ---

// --- Focused Wail ---

/datum/action/cooldown/spell/pointed/banshee_focused_wail
	name = "Focused Wail"
	invocation = "НЕНАВИЖУ!!!"
	invocation_type = INVOCATION_SHOUT
	button_icon = 'modular_bandastation/banshee_skills/icons/banshee_skills.dmi'
	button_icon_state = "focused_wail"
	cooldown_time = 45 SECONDS
	spell_requirements = NONE
	cast_range = 7
	ranged_mousepointer = 'icons/effects/mouse_pointers/throw_target.dmi'

/datum/action/cooldown/spell/pointed/banshee_focused_wail/cast(mob/living/cast_on)
    . = ..()
    playsound(cast_on.loc, 'modular_bandastation/banshee_skills/sound/banshee_wail.ogg', 100, TRUE)
    // Просто вызываем gib() для любой живой цели
    if(isliving(cast_on))
        cast_on.gib(TRUE, TRUE, TRUE)

// --- Banshee's Grip ---

/datum/action/cooldown/spell/pointed/banshee_grip
	name = "Banshee's Grip"
	invocation = "ОТОЙДИ!!!"
	invocation_type = INVOCATION_SHOUT
	button_icon = 'modular_bandastation/banshee_skills/icons/banshee_skills.dmi'
	button_icon_state = "banshee_grip"
	cooldown_time = 15 SECONDS
	spell_requirements = NONE
	cast_range = 7
	ranged_mousepointer = 'icons/effects/mouse_pointers/throw_target.dmi'

/datum/action/cooldown/spell/pointed/banshee_grip/cast(mob/living/cast_on)
	. = ..()
	playsound(owner, 'modular_bandastation/banshee_skills/sound/banshee_pull.ogg', 50, TRUE)
	var/turf/T = get_ranged_target_turf(owner, owner.dir, 5)
	cast_on.throw_at(T, 10, 3, owner)

// -- Banshee's Butcher ---

/datum/action/cooldown/spell/pointed/banshee_butcher
	name = "Banshee's Butcher"
	invocation = "МНЕ  ТАК  БОЛЬНО!!!  ТЫ  ТОЖЕ  ПОЧУВСТВУЙ!!!"
	invocation_type = INVOCATION_SHOUT
	button_icon = 'modular_bandastation/banshee_skills/icons/banshee_skills.dmi'
	button_icon_state = "butcher"
	cooldown_time = 50 SECONDS
	spell_requirements = NONE
	cast_range = 5
	ranged_mousepointer = 'icons/effects/mouse_pointers/throw_target.dmi'

/datum/action/cooldown/spell/pointed/banshee_butcher/cast(mob/living/L)
    if(!isliving(L))
        return FALSE
    . = ..()
    playsound(L.loc, 'modular_bandastation/banshee_skills/sound/banshee_butcher.ogg', 100, TRUE)

    // Если это человек/карбон — отрываем конечности
    if(iscarbon(L))
        var/mob/living/carbon/C = L
        for(var/obj/item/bodypart/part in C.bodyparts)
            if(part.body_zone == BODY_ZONE_CHEST || part.body_zone == BODY_ZONE_HEAD)
                continue
            part.drop_limb()
        C.visible_message(span_danger("[owner.name] срывается на крик, и плоть [C.declent_ru(GENITIVE)] отделяется от костей!"))
    else
        // Если это простой моб (собака, мышь) — наносим огромный урон, имитирующий разделку
        L.adjust_brute_loss(80)
        L.visible_message(span_danger("От крика [owner.name] [L.declent_ru(NOMINATIVE)] буквально разваливается на куски!"))

// --- Banshee's Flay ---

/datum/action/cooldown/spell/pointed/banshee_flay
	name = "Banshee's Flay"
	invocation = "УМРИ!!!"
	invocation_type = INVOCATION_SHOUT
	button_icon = 'modular_bandastation/banshee_skills/icons/banshee_skills.dmi'
	button_icon_state = "flay"
	cooldown_time = 25 SECONDS
	spell_requirements = NONE
	cast_range = 7
	ranged_mousepointer = 'icons/effects/mouse_pointers/throw_target.dmi'

/datum/action/cooldown/spell/pointed/banshee_flay/cast(mob/living/L)
	if(!isliving(L))
		return FALSE
	. = ..()
	playsound(owner, 'modular_bandastation/banshee_skills/sound/banshee_flay.ogg', 80, TRUE)
	if(iscarbon(L))
		var/mob/living/carbon/C = L
		for(var/i in 1 to 3)
			if(!C.bodyparts || !C.bodyparts.len)
				break
			var/obj/item/bodypart/part = pick(C.bodyparts)
			if(part)
				part.take_damage(35, 0)
				C.bleed(45)
		if(prob(50))
			var/datum/brain_trauma/trauma_type = pick(subtypesof(/datum/brain_trauma/mild) + subtypesof(/datum/brain_trauma/severe))
			if(trauma_type)
				C.gain_trauma(trauma_type, TRAUMA_RESILIENCE_LOBOTOMY)
		C.flash_act()
		C.Paralyze(200)
		if(ishuman(C))
			var/mob/living/carbon/human/H = C
			H.adjust_stamina_loss(60)
		C.visible_message(span_danger("От истерического вопля [owner.name] кожа на [C.declent_ru(PREPOSITIONAL)] лопается, обнажая мышцы!"))

// --- Banshee's Choke ---

/datum/action/cooldown/spell/pointed/banshee_choke
	name = "Choke"
	invocation = "Пожалуйста... просто замолчи..."
	invocation_type = INVOCATION_SHOUT
	button_icon = 'modular_bandastation/banshee_skills/icons/banshee_skills.dmi'
	button_icon_state = "choke"
	cooldown_time = 30 SECONDS
	spell_requirements = NONE
	cast_range = 7
	ranged_mousepointer = 'icons/effects/mouse_pointers/throw_target.dmi'

/datum/action/cooldown/spell/pointed/banshee_choke/cast(mob/living/cast_on)
	. = ..()
	playsound(cast_on.loc, 'modular_bandastation/banshee_skills/sound/banshee_choke.ogg', 50, TRUE)
	to_chat(cast_on, span_userdanger("Вы слышите всхлипывающий шепот [owner.name], и ваши легкие будто каменеют!"))
	for(var/i in 1 to 10)
		addtimer(CALLBACK(src, .proc/apply_choke_tick, cast_on), i * 1 SECONDS)

/datum/action/cooldown/spell/pointed/banshee_choke/proc/apply_choke_tick(mob/living/H)
	if(H && H.stat != DEAD)
		H.apply_damage(20, OXY)

// --- Banshee's Lullaby ---

/datum/action/cooldown/spell/banshee_whisper
	name = "Banshee Lullaby"
	button_icon = 'modular_bandastation/banshee_skills/icons/banshee_skills.dmi'
	button_icon_state = "sleep"
	cooldown_time = 20 SECONDS
	spell_requirements = NONE

/datum/action/cooldown/spell/banshee_whisper/can_cast_spell(feedback = TRUE)
	return TRUE

/datum/action/cooldown/spell/banshee_whisper/cast(list/targets)
	var/mob/living/carbon/human/victim = null

	for(var/mob/living/carbon/human/H in range(1, owner))
		if(H == owner)
			continue
		victim = H
		break

	if(!victim)
		to_chat(owner, span_warning("Цель должна быть вплотную!"))
		return FALSE

	owner.whisper("Спи...", forced = "banshee_whisper")

	. = ..()
	victim.Sleeping(2000)
	to_chat(victim, span_danger("Спи... вечным сном..."))
	to_chat(owner, span_notice("Вы погружаете [victim] в сон."))

// --- РЕГИСТРАЦИЯ КНОПОК ---

ADMIN_VERB(give_banshee_kit_full, R_ADMIN, "Give Banshee KIT", "Выдает персонажу полный набор способностей Банши.", ADMIN_CATEGORY_FUN, mob/living/target in world)
	if(QDELETED(target))
		return

	var/list/spells = list(
		/datum/action/cooldown/spell/aoe/banshee_scream,
		/datum/action/cooldown/spell/aoe/banshee_death_wail,
		/datum/action/cooldown/spell/aoe/banshee_destructive_wail,
		/datum/action/cooldown/spell/pointed/banshee_focused_wail,
		/datum/action/cooldown/spell/pointed/banshee_grip,
		/datum/action/cooldown/spell/pointed/banshee_butcher,
		/datum/action/cooldown/spell/pointed/banshee_flay,
		/datum/action/cooldown/spell/pointed/banshee_choke,
		/datum/action/cooldown/spell/banshee_whisper
	)

	for(var/S in spells)
		var/datum/action/cooldown/spell/spell_inst = new S(target)
		spell_inst.Grant(target)

	log_admin("[key_name(user)] выдал способности Банши для [key_name(target)].")
	message_admins("[key_name_admin(user)] выдал способности Банши для [key_name(target)].")

ADMIN_VERB(banshee_unfreeze_radius_verb, R_ADMIN, "Banshee Un-Paralyze Radius", "Снимает стазис банши в радиусе.", ADMIN_CATEGORY_FUN)
	var/range = tgui_input_number(user, "Радиус разморозки?", "Banshee System", 7, 30, 1)
	if(isnull(range))
		return

	var/thawed_count = 0
	for(var/mob/living/carbon/human/H in range(range, user.mob))
		H.remove_traits(list(TRAIT_INCAPACITATED, TRAIT_IMMOBILIZED, TRAIT_FLOORED, TRAIT_MUTE), "banshee_scream")
		to_chat(H, span_notice("Оцепенение проходит. Вы снова можете двигаться."))

	message_admins("[key_name_admin(user)] разморозил [thawed_count] чел. в радиусе [range].")
