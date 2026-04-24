/datum/action/cooldown/spell/aoe/ability_stomp
	name = "Топот"
	button_icon = 'modular_bandastation/banshee_skills/icons/banshee_skills.dmi'
	button_icon_state = "destructive_wail"
	cooldown_time = 3 SECONDS
	spell_requirements = NONE

/datum/action/cooldown/spell/aoe/ability_stomp/can_cast_spell(feedback = TRUE)
	return TRUE

/datum/action/cooldown/spell/aoe/ability_stomp/cast(list/targets)
	..()
	var/obj/effect/temp_visual/V = new /obj/effect/temp_visual(get_turf(owner))
	if(V)
		V.icon = 'icons/effects/96x96.dmi'
		V.icon_state = "mech_attack_aoe_attack"
		V.color = "#ff0000"
		V.pixel_x = -32
		V.pixel_y = -32
		V.duration = 1 SECONDS
	playsound(owner.loc, 'sound/effects/magic/repulse.ogg', 80, TRUE)

/datum/action/cooldown/spell/aoe/ability_stomp/cast_on_thing_in_aoe(atom/victim, atom/caster)
	if(QDELETED(victim))
		return
	if(victim == owner)
		return
	if(isliving(victim))
		var/mob/living/L = victim
		L.take_overall_damage(40, 0)
		L.throw_at(get_edge_target_turf(L, get_dir(owner, L)), 3, 2)

	else if(isstructure(victim))
		var/obj/structure/O = victim
		O.take_damage(60, BRUTE, "bomb", 0)

	else if(iswallturf(victim))
		var/turf/closed/wall/W = victim
		if(prob(40))
			W.dismantle_wall(TRUE)
