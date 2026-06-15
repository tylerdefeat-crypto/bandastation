// ============================================================
// Rust-Forged Labyrinth — Floor Spikes (Phase F2)
//
// Sits flush in the floor (non-dense). On cycle, iron spikes shoot
// up from this tile and impale whoever stands on it, then retract.
// Telegraphed: a rumble + warning state precedes the strike.
// ============================================================

/obj/structure/labyrinth_hazard/floor_spikes
	name = "floor spikes"
	desc = "A grille of rusted iron teeth set flush into the floor. Old blood crusts the seams."
	icon_state = "grille"           // placeholder — swap for retracted-spikes sprite
	density = FALSE

	/// TRUE while the spikes are raised.
	var/spikes_up = FALSE

/obj/structure/labyrinth_hazard/floor_spikes/run_cycle()
	if(spikes_up)
		return
	_warn()
	SLEEP_NOT_DEL(SPIKES_WARN_TIME)
	_raise()
	SLEEP_NOT_DEL(SPIKES_UP_TIME)
	_impale()
	SLEEP_NOT_DEL(SPIKES_HOLD_TIME)
	_lower()
	SLEEP_NOT_DEL(SPIKES_DOWN_TIME)

/obj/structure/labyrinth_hazard/floor_spikes/proc/_warn()
	playsound(src, 'sound/effects/clang.ogg', 60, TRUE, 8)
	visible_message(span_warning("The floor beneath [src] shudders with a metallic grinding..."))

/obj/structure/labyrinth_hazard/floor_spikes/proc/_raise()
	spikes_up = TRUE
	icon_state = "grille_broken"     // placeholder: raised-spikes state
	playsound(src, 'sound/effects/gravhit.ogg', 80, TRUE, 10)

/// Damage whoever stands on this exact tile at the moment of the strike.
/obj/structure/labyrinth_hazard/floor_spikes/proc/_impale()
	var/turf/T = get_turf(src)
	for(var/mob/living/victim in T)
		victim.visible_message(
			span_danger("Iron spikes erupt through [victim]!"),
			span_userdanger("Spikes tear up through your body from below!"),
		)
		victim.apply_damage(SPIKES_DAMAGE, BRUTE, pick(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG, BODY_ZONE_CHEST), wound_bonus = 20, sharpness = SHARP_POINTY, attacking_item = src)
		victim.Paralyze(2 SECONDS)
		victim.add_splatter_floor(T)
		log_combat(src, victim, "spike-impaled")

/obj/structure/labyrinth_hazard/floor_spikes/proc/_lower()
	spikes_up = FALSE
	icon_state = "grille"            // placeholder: retracted state
	playsound(src, 'sound/effects/clang.ogg', 50, TRUE, 8)
