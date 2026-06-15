// ============================================================
// Rust-Forged Labyrinth — Industrial Piston (Phase II, refactored F1)
//
// Stays on its own turf. Extends via pixel-offset animation into
// the adjacent turf, crushing or displacing anything in the path.
//
// Subtype of /obj/structure/labyrinth_hazard — the base owns the
// operating lock, loop driver and sync/channel registration. Piston
// only implements run_cycle() + its collision logic.
//
// Icon placeholder: replace with dedicated piston art.
// Sound placeholders: replace with custom industrial SFX.
// ============================================================

/obj/structure/labyrinth_hazard/piston
	name = "industrial piston"
	desc = "A massive rusted slab of wall on hydraulic runners. The air around it smells of iron and old blood."

	/// PISTON_RETRACTED or PISTON_EXTENDED
	var/piston_state = PISTON_RETRACTED
	/// How many tiles forward the piston travels
	var/push_distance = 1
	/// The wall TYPE the piston head wears. The piston needs no sprite of its
	/// own — it copies this wall's icon/icon_state/name so it reads as that wall
	/// sliding out. To change which wall "moves", set this in the DMM (or a
	/// subtype) to any /turf/closed/wall path — nothing else needs touching.
	var/turf/closed/wall/wall_appearance = /turf/closed/wall/r_wall

/obj/structure/labyrinth_hazard/piston/Initialize(mapload)
	. = ..()
	_wear_wall_appearance()

/// Copy the configured wall's look onto the piston head. Smoothing walls expose
/// their isolated "<base>-0" state via initial(), which is exactly the single
/// standalone block we want for a moving ram.
/obj/structure/labyrinth_hazard/piston/proc/_wear_wall_appearance()
	var/turf/closed/wall/W = wall_appearance
	if(!ispath(W, /turf/closed/wall))
		return
	icon = initial(W.icon)
	icon_state = initial(W.icon_state)
	name = initial(W.name)

// ------------------------------------------------------------------
// Cycle: warn → extend → hold → retract
// ------------------------------------------------------------------

/obj/structure/labyrinth_hazard/piston/run_cycle()
	if(piston_state == PISTON_EXTENDED)
		return
	_warn()
	SLEEP_NOT_DEL(PISTON_WARN_TIME)
	_extend()
	SLEEP_NOT_DEL(PISTON_EXTEND_TIME)
	_on_fully_extended()
	SLEEP_NOT_DEL(PISTON_HOLD_TIME)
	_retract()
	SLEEP_NOT_DEL(PISTON_RETRACT_TIME)
	piston_state = PISTON_RETRACTED

/// Pre-extension groan — gives players a moment to react.
/obj/structure/labyrinth_hazard/piston/proc/_warn()
	playsound(src, 'sound/effects/clang.ogg', 80, TRUE, 12)
	// Telegraph via a brief shudder rather than an icon swap, so the wall
	// sprite stays intact. Small back-and-forth nudge along the push axis.
	var/list/shake = _dir_to_pixel_offset(0.15)
	animate(src, pixel_x = shake[1], pixel_y = shake[2], time = 1, flags = ANIMATION_PARALLEL)
	animate(pixel_x = 0, pixel_y = 0, time = 1)

/// Begin extension animation and deal damage at the right moment.
/obj/structure/labyrinth_hazard/piston/proc/_extend()
	var/list/offset = _dir_to_pixel_offset(push_distance)
	animate(src, pixel_x = offset[1], pixel_y = offset[2], time = PISTON_EXTEND_TIME, easing = SINE_EASING)
	playsound(src, 'sound/effects/meteorimpact.ogg', 100, TRUE, 14)
	// Deal damage partway through the stroke so players feel the hit
	addtimer(CALLBACK(src, PROC_REF(_apply_crush)), PISTON_EXTEND_TIME * 0.6)

/obj/structure/labyrinth_hazard/piston/proc/_on_fully_extended()
	piston_state = PISTON_EXTENDED

/// Retract animation — faster than the extension.
/obj/structure/labyrinth_hazard/piston/proc/_retract()
	animate(src, pixel_x = 0, pixel_y = 0, time = PISTON_RETRACT_TIME, easing = BACK_EASING | EASE_IN)
	playsound(src, 'sound/effects/clang.ogg', 70, TRUE, 12)

// ------------------------------------------------------------------
// Collision & damage
// ------------------------------------------------------------------

/// Walk each turf in the push path and process mobs/objects.
/obj/structure/labyrinth_hazard/piston/proc/_apply_crush()
	if(QDELETED(src))
		return
	var/list/path = _get_push_path()
	for(var/turf/target_turf as anything in path)
		_process_turf(target_turf)

/obj/structure/labyrinth_hazard/piston/proc/_process_turf(turf/T)
	var/turf/escape_turf = get_step(T, dir)  // turf further in push direction
	for(var/mob/living/victim in T)
		_hit_mob(victim, escape_turf)
	// Fling loose items
	for(var/obj/item/loose in T)
		if(!loose.anchored)
			loose.throw_at(escape_turf, 3, 3, src)

/// Tries to displace the victim forward. If blocked, applies full crush damage.
/obj/structure/labyrinth_hazard/piston/proc/_hit_mob(mob/living/victim, turf/escape_turf)
	var/can_escape = escape_turf && !escape_turf.density && _turf_passable_for(victim, escape_turf)

	if(can_escape)
		// Glancing blow — mob is flung but survives easier
		victim.visible_message(
			span_warning("[src] slams into [victim], sending [victim.p_them()] flying!"),
			span_userdanger("[src] slams into you! You're thrown back!"),
		)
		victim.apply_damage(PISTON_DAMAGE_GLANCING, BRUTE, BODY_ZONE_CHEST, wound_bonus = 5, attacking_item = src)
		victim.throw_at(escape_turf, push_distance + 1, 4, src)
	else
		// Pinned against a wall — full crush
		victim.visible_message(
			span_warning("[src] crushes [victim] against the wall!"),
			span_userdanger("[src] pins you against the wall and crushes you!"),
		)
		victim.emote("scream")
		victim.apply_damage(PISTON_DAMAGE_CRUSH, BRUTE, BODY_ZONE_CHEST, wound_bonus = 15, attacking_item = src)
		victim.Paralyze(6 SECONDS)
		victim.add_splatter_floor(get_turf(victim))
	log_combat(src, victim, "piston-crushed")

/// Simple passability check — is the turf safe to throw a mob into?
/obj/structure/labyrinth_hazard/piston/proc/_turf_passable_for(mob/living/M, turf/T)
	if(istype(T, /turf/closed))
		return FALSE
	for(var/atom/A in T)
		if(A == M)
			continue
		if(A.density)
			return FALSE
	return TRUE

// ------------------------------------------------------------------
// Helpers
// ------------------------------------------------------------------

/obj/structure/labyrinth_hazard/piston/proc/_get_push_path()
	var/list/path = list()
	var/turf/current = get_turf(src)
	for(var/i in 1 to push_distance)
		current = get_step(current, dir)
		if(!current)
			break
		path += current
	return path

/// Returns [pixel_x, pixel_y] offset for this piston's direction × distance.
/obj/structure/labyrinth_hazard/piston/proc/_dir_to_pixel_offset(tiles)
	var/px = 32 * tiles
	switch(dir)
		if(NORTH) return list(0,   px)
		if(SOUTH) return list(0,  -px)
		if(EAST)  return list(px,   0)
		if(WEST)  return list(-px,  0)
	return list(0, 0)
