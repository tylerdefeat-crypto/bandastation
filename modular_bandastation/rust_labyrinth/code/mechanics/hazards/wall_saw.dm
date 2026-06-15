// ============================================================
// Rust-Forged Labyrinth — Wall Saw (Phase F2)
//
// Mounted on a wall. On cycle, a circular saw slides out along `dir`
// across `reach` tiles, shredding anything in its path, then retracts.
// Heavier bleed than a piston; pinned victims take it worst.
// ============================================================

/obj/structure/labyrinth_hazard/wall_saw
	name = "wall saw"
	desc = "A great toothed disc recessed into the wall, rimmed with dried gore. It hums faintly."
	icon = 'modular_bandastation/rust_labyrinth/icons/wall_saw.dmi'
	icon_state = "idle"
	density = FALSE                 // recessed; doesn't block until it strikes
	contact_damage = WALLSAW_CONTACT_DAMAGE

	/// How many tiles the saw sweeps out from the wall.
	var/reach = 2

/obj/structure/labyrinth_hazard/wall_saw/Initialize(mapload)
	. = ..()
	// Idle: only the exposed mouth (tile directly in front) grazes.
	live_offsets = list(1)

/obj/structure/labyrinth_hazard/wall_saw/run_cycle()
	_warn()
	SLEEP_NOT_DEL(WALLSAW_WARN_TIME)
	_extend()
	// Slice mid-stroke so the hit lands while the saw is moving through.
	addtimer(CALLBACK(src, PROC_REF(_slice)), WALLSAW_OUT_TIME * 0.5)
	SLEEP_NOT_DEL(WALLSAW_OUT_TIME)
	SLEEP_NOT_DEL(WALLSAW_HOLD_TIME)
	_retract()
	SLEEP_NOT_DEL(WALLSAW_IN_TIME)

/obj/structure/labyrinth_hazard/wall_saw/proc/_warn()
	playsound(src, 'sound/effects/clang.ogg', 70, TRUE, 10)
	visible_message(span_warning("[src] begins to whine, its disc spinning up..."))

/obj/structure/labyrinth_hazard/wall_saw/proc/_extend()
	var/list/offset = _reach_pixel_offset(reach)
	animate(src, pixel_x = offset[1], pixel_y = offset[2], time = WALLSAW_OUT_TIME, easing = SINE_EASING)
	playsound(src, 'sound/effects/meteorimpact.ogg', 90, TRUE, 12)
	// Whole swept line is live while the disc is out.
	var/list/live = list()
	for(var/i in 1 to reach)
		live += i
	live_offsets = live

/obj/structure/labyrinth_hazard/wall_saw/proc/_retract()
	animate(src, pixel_x = 0, pixel_y = 0, time = WALLSAW_IN_TIME, easing = SINE_EASING)
	playsound(src, 'sound/effects/clang.ogg', 60, TRUE, 10)
	// Back to recessed: only the mouth grazes.
	live_offsets = list(1)

/// Shred every mob along the swept line (the heavy cycle strike).
/obj/structure/labyrinth_hazard/wall_saw/proc/_slice()
	if(QDELETED(src))
		return
	var/turf/current = get_turf(src)
	for(var/i in 1 to reach)
		current = get_step(current, dir)
		if(!current)
			break
		for(var/mob/living/victim in current)
			if(victim.stat == DEAD)
				continue
			victim.visible_message(
				span_danger("[src]'s blade rips into [victim]!"),
				span_userdanger("The spinning blade tears across your flesh!"),
			)
			_bite(victim, WALLSAW_DAMAGE, wound_bonus = 25, zones = list(BODY_ZONE_CHEST, BODY_ZONE_HEAD, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM))

/// [pixel_x, pixel_y] offset for the saw fully extended in `dir`.
/obj/structure/labyrinth_hazard/wall_saw/proc/_reach_pixel_offset(tiles)
	var/px = 32 * tiles
	switch(dir)
		if(NORTH) return list(0,   px)
		if(SOUTH) return list(0,  -px)
		if(EAST)  return list(px,   0)
		if(WEST)  return list(-px,  0)
	return list(0, 0)
