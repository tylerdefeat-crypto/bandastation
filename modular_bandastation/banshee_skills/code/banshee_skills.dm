
//BANSHEE ABILITY SUITE (FIXED FOR BANDASTATION - NO CLOTHES REQ)


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

// --- AOE SPELLS ---

// --- Banshee's Stasis Scream ---

/datum/action/cooldown/spell/aoe/banshee_scream
	name = "Banshee's Stasis Scream"
	button_icon_state = "horror_scream"
	cooldown_time = 30 SECONDS
	invocation_type = INVOCATION_SHOUT
	invocation = "НА КОЛЕНИ!!!"
	spell_requirements = NONE
	var/scream_range = 7

/datum/action/cooldown/spell/aoe/banshee_scream/can_cast_spell(feedback = TRUE)
	return TRUE

/datum/action/cooldown/spell/aoe/banshee_scream/cast(list/targets)
	. = ..()
	playsound(owner.loc, 'modular_bandastation/banshee_skills/sound/banshee_scream3.ogg', 100, TRUE)
	for(var/mob/living/carbon/human/H in range(scream_range, owner))
		if(H == owner || H.stat == DEAD || H.banshee_frozen) continue
		H.banshee_frozen = TRUE
		H.add_traits(list(TRAIT_INCAPACITATED, TRAIT_IMMOBILIZED, TRAIT_FLOORED), "banshee_scream")
		to_chat(H, span_userdanger("Леденящий душу крик пронзает ваш разум! Вы парализованы!"))

// --- Banshee's Death Wail ---

/datum/action/cooldown/spell/aoe/banshee_death_wail
	name = "Death Wail (AOE GIB)"
	button_icon_state = "gib"
	cooldown_time = 60 SECONDS
	invocation_type = INVOCATION_SHOUT
	invocation = "УМРИТЕ!!!"
	spell_requirements = NONE

/datum/action/cooldown/spell/aoe/banshee_death_wail/can_cast_spell(feedback = TRUE)
	return TRUE

/datum/action/cooldown/spell/aoe/banshee_death_wail/cast(list/targets)
	. = ..()
	playsound(owner.loc, 'modular_bandastation/banshee_skills/sound/banshee_scream.ogg', 100, TRUE)
	for(var/mob/living/carbon/human/H in range(3, owner))
		if(H == owner || H.stat == DEAD) continue
		H.gib(TRUE, TRUE, TRUE)

// --- Banshee's Destructive Wail ---

/datum/action/cooldown/spell/aoe/banshee_destructive_wail
	name = "Destructive Wail"
	button_icon_state = "earthquake"
	cooldown_time = 45 SECONDS
	invocation = "НАЗАД!!!"
	spell_requirements = NONE

/datum/action/cooldown/spell/aoe/banshee_destructive_wail/can_cast_spell(feedback = TRUE)
	return TRUE

/datum/action/cooldown/spell/aoe/banshee_destructive_wail/cast(list/targets)
	. = ..()
	playsound(owner.loc, 'modular_bandastation/banshee_skills/sound/explosionfar.ogg', 100, TRUE)
	for(var/atom/A in range(4, owner))
		if(A == owner) continue
		if(isliving(A))
			var/mob/living/L = A
			L.take_overall_damage(40, 0)
			L.throw_at(get_edge_target_turf(L, get_dir(owner, L)), 3, 2)
		else if(isobj(A))
			var/obj/O = A
			O.take_damage(60, BRUTE, "bomb", 0)
		else if(isturf(A))
			var/turf/closed/wall/W = A
			if(istype(W) && prob(40)) W.dismantle_wall(TRUE)

// --- POINT SPELLS (FIXED VARS & NO REQUIREMENTS) ---

/datum/action/cooldown/spell/banshee_focused_wail
	name = "Focused Wail (Point GIB)"
	button_icon_state = "skull"
	cooldown_time = 45 SECONDS
	spell_requirements = NONE
	var/active = FALSE

/datum/action/cooldown/spell/banshee_focused_wail/Activate()
	active = !active
	to_chat(owner, active ? span_warning("Focused Wail активен. Кликните по цели...") : span_notice("Отменено."))

/datum/action/cooldown/spell/banshee_focused_wail/proc/intercept_click(mob/living/caller, atom/target)
	if(!active || caller != owner || !istype(target, /mob/living/carbon/human)) return FALSE
	cast(list(target))
	active = FALSE
	return TRUE

/datum/action/cooldown/spell/banshee_focused_wail/cast(list/targets)
	var/mob/living/carbon/human/H = targets[1]
	. = ..()
	playsound(H.loc, 'sound/effects/splat.ogg', 100, TRUE)
	H.gib(TRUE, TRUE, TRUE)

/datum/action/cooldown/spell/banshee_grip
	name = "Banshee's Grip"
	button_icon_state = "telekinesis"
	cooldown_time = 15 SECONDS
	spell_requirements = NONE
	var/active = FALSE
	var/mob/living/victim = null

/datum/action/cooldown/spell/banshee_grip/Activate()
	active = !active
	victim = null // Сбрасываем жертву при переключении
	to_chat(owner, active ? span_warning("Выберите цель для захвата...") : span_notice("Отменено."))

/datum/action/cooldown/spell/banshee_grip/proc/intercept_click(mob/living/caller, atom/target)
	if(!active || caller != owner) return FALSE
	if(!victim)
		if(istype(target, /mob/living))
			victim = target
			to_chat(owner, span_notice("Цель захвачена! Теперь кликните в сторону броска."))
			return TRUE
		return FALSE
	cast(list(target))
	active = FALSE
	return TRUE

/datum/action/cooldown/spell/banshee_grip/cast(list/targets)
	var/atom/target = targets[1]
	if(!victim) return FALSE
	. = ..()
	victim.throw_at(get_turf(target), 10, 3, owner)
	victim = null

/datum/action/cooldown/spell/banshee_butcher
	name = "Banshee's Butcher"
	button_icon_state = "skeleton"
	cooldown_time = 50 SECONDS
	spell_requirements = NONE
	var/active = FALSE

/datum/action/cooldown/spell/banshee_butcher/Activate()
	active = !active
	to_chat(owner, active ? span_warning("Выберите жертву для Butcher...") : span_notice("Отменено."))

/datum/action/cooldown/spell/banshee_butcher/proc/intercept_click(mob/living/caller, atom/target)
	if(!active || caller != owner || !istype(target, /mob/living/carbon/human)) return FALSE
	cast(list(target))
	active = FALSE
	return TRUE

/datum/action/cooldown/spell/banshee_butcher/cast(list/targets)
	var/mob/living/carbon/human/H = targets[1]
	. = ..()
	playsound(H.loc, 'sound/effects/splat.ogg', 100, TRUE)
	for(var/limb_name in list("arm_l", "arm_r", "leg_l", "leg_r"))
		var/obj/item/bodypart/L = H.get_bodypart(limb_name)
		if(L) L.dismember()

/datum/action/cooldown/spell/banshee_flay
	name = "Banshee's Flay"
	button_icon_state = "flay"
	cooldown_time = 25 SECONDS
	spell_requirements = NONE
	var/active = FALSE

/datum/action/cooldown/spell/banshee_flay/Activate()
	active = !active
	to_chat(owner, active ? span_warning("Выберите жертву для Flay...") : span_notice("Отменено."))

/datum/action/cooldown/spell/banshee_flay/proc/intercept_click(mob/living/caller, atom/target)
	if(!active || caller != owner || !istype(target, /mob/living/carbon/human)) return FALSE
	cast(list(target))
	active = FALSE
	return TRUE

/datum/action/cooldown/spell/banshee_flay/cast(list/targets)
	var/mob/living/carbon/human/H = targets[1]
	. = ..()
	for(var/i in 1 to 3)
		var/obj/item/bodypart/L = H.get_bodypart(pick("chest", "arm_l", "arm_r"))
		if(L)
			L.take_damage(25, 0)
			H.bleed(10)

/datum/action/cooldown/spell/banshee_choke
	name = "Banshee's Asphyxiation"
	button_icon_state = "suffocate"
	cooldown_time = 30 SECONDS
	spell_requirements = NONE
	var/active = FALSE

/datum/action/cooldown/spell/banshee_choke/Activate()
	active = !active
	to_chat(owner, active ? span_warning("Выберите жертву для удушения...") : span_notice("Отменено."))

/datum/action/cooldown/spell/banshee_choke/proc/intercept_click(mob/living/caller, atom/target)
	if(!active || caller != owner || !istype(target, /mob/living/carbon/human)) return FALSE
	cast(list(target))
	active = FALSE
	return TRUE

/datum/action/cooldown/spell/banshee_choke/cast(list/targets)
	var/mob/living/carbon/human/H = targets[1]
	. = ..()
	to_chat(H, span_userdanger("Вы задыхаетесь!"))
	for(var/i in 1 to 10)
		addtimer(CALLBACK(src, .proc/apply_choke_tick, H), i * 1 SECONDS)

/datum/action/cooldown/spell/banshee_choke/proc/apply_choke_tick(mob/living/carbon/human/H)
	if(H && H.stat != DEAD)
		H.apply_damage(20, OXY)

// --- Banshee's Lullaby ---

/datum/action/cooldown/spell/banshee_whisper
	name = "Banshee Lullaby"
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
		/datum/action/cooldown/spell/banshee_focused_wail,
		/datum/action/cooldown/spell/banshee_grip,
		/datum/action/cooldown/spell/banshee_butcher,
		/datum/action/cooldown/spell/banshee_flay,
		/datum/action/cooldown/spell/banshee_choke,
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
		if(H.banshee_frozen)
			banshee_thaw(H)
			thawed_count++

	message_admins("[key_name_admin(user)] разморозил [thawed_count] чел. в радиусе [range].")
