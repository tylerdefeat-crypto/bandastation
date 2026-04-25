/datum/action/cooldown/spell/cone/staggered/crooked_vomit_cone
	name = "Извержение желчи"
	desc = "Босс изрыгает массивный конус кислоты, заливающий всё впереди."
	button_icon = 'icons/mob/actions/actions_xeno.dmi'
	button_icon_state = "alien_neurotoxin"
	cooldown_time = 3 SECONDS
	spell_requirements = NONE

	cone_levels = 4 // Дистанция плевка
	respect_density = TRUE

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
	if(!target_turf || prob(15))
		return

	// Явное создание именно твоего типа кислоты
	new /obj/effect/decal/cleanable/vomit/toxic/crooked(target_turf)

/datum/action/cooldown/spell/cone/staggered/crooked_vomit_cone/do_mob_cone_effect(mob/living/victim, atom/caster, level)
	if(victim == caster)
		return

	// Урон тем, кто попал под прямую струю
	victim.apply_damage(15, TOX)
	victim.adjust_disgust(50) // Эффект тошноты
	to_chat(victim, span_danger("Вас окатило зловонной желудочной кислотой!"))

// Сама лужа (остается без изменений, используется из Crossed для урона под ногами)
/obj/effect/decal/cleanable/vomit/toxic/crooked
	name = "желудочный сок"
	desc = "Шипящая и вонючая лужа. Она разъедает даже металл."
	color = "#4cff00"

/obj/effect/decal/cleanable/vomit/toxic/crooked/proc/on_entered(datum/source, atom/movable/AM)
	SIGNAL_HANDLER
	if(ishuman(AM))
		var/mob/living/carbon/human/L = AM
		if(prob(50))
			var/picked_def_zone = pick(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
			var/obj/item/bodypart/leg = L.get_bodypart(picked_def_zone)
			if(leg)
				L.apply_damage(10, BURN, leg)
			else
				L.apply_damage(10, BURN)
			to_chat(L, span_danger("Кислота обжигает ваши ноги!"))

/obj/effect/decal/cleanable/vomit/toxic/crooked/proc/delete_vomit()
	Destroy()

/obj/effect/decal/cleanable/vomit/toxic/crooked/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	addtimer(CALLBACK(src, PROC_REF(delete_vomit)), 15 SECONDS)
/obj/item/shard
