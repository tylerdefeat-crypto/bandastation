// ============================================================
// Rust-Forged Labyrinth — Floor Saw (Phase F2)
//
// A circular saw riding a recessed rail in the floor. On cycle it
// rolls forward `rail_length` tiles along `dir`, carving every mob it
// rolls over, then rolls back to its start. Non-dense; the rail is
// part of the floor, so the saw object never changes turf — movement
// is pixel animation + per-step damage on the tile it visually occupies.
// ============================================================

/obj/structure/labyrinth_hazard/floor_saw
	name = "floor saw"
	desc = "A toothed wheel half-sunk into a greasy rail. It judders, eager to run."
	icon_state = "grille"           // placeholder — swap for floor-saw sprite
	density = FALSE

	/// How many tiles the saw travels along its rail.
	var/rail_length = 4

/obj/structure/labyrinth_hazard/floor_saw/run_cycle()
	_warn()
	SLEEP_NOT_DEL(FLOORSAW_WARN_TIME)
	playsound(src, 'sound/effects/meteorimpact.ogg', 80, TRUE, 12)
	// Roll out, carving each tile as we reach it.
	for(var/i in 1 to rail_length)
		_roll_to(i)
		SLEEP_NOT_DEL(FLOORSAW_STEP_TIME)
		_carve_offset(i)
	// Roll back to the rail's origin.
	for(var/i in rail_length - 1 to 0 step -1)
		_roll_to(i)
		SLEEP_NOT_DEL(FLOORSAW_STEP_TIME)
	pixel_x = 0
	pixel_y = 0

/obj/structure/labyrinth_hazard/floor_saw/proc/_warn()
	playsound(src, 'sound/effects/clang.ogg', 65, TRUE, 9)
	visible_message(span_warning("[src] shrieks against its rail, about to run..."))

/// Animate the saw to tile-offset `n` along `dir` (1 tile = 32 px).
/obj/structure/labyrinth_hazard/floor_saw/proc/_roll_to(n)
	var/px = 32 * n
	switch(dir)
		if(NORTH) animate(src, pixel_y =  px, time = FLOORSAW_STEP_TIME, easing = LINEAR_EASING)
		if(SOUTH) animate(src, pixel_y = -px, time = FLOORSAW_STEP_TIME, easing = LINEAR_EASING)
		if(EAST)  animate(src, pixel_x =  px, time = FLOORSAW_STEP_TIME, easing = LINEAR_EASING)
		if(WEST)  animate(src, pixel_x = -px, time = FLOORSAW_STEP_TIME, easing = LINEAR_EASING)

/// Damage mobs on the tile the saw currently sits over (offset `n`).
/obj/structure/labyrinth_hazard/floor_saw/proc/_carve_offset(n)
	if(QDELETED(src))
		return
	var/turf/current = get_turf(src)
	for(var/i in 1 to n)
		current = get_step(current, dir)
		if(!current)
			return
	for(var/mob/living/victim in current)
		victim.visible_message(
			span_danger("[src] rolls straight over [victim]!"),
			span_userdanger("The saw rolls over you, teeth biting deep!"),
		)
		victim.apply_damage(FLOORSAW_DAMAGE, BRUTE, pick(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG, BODY_ZONE_CHEST), wound_bonus = 20, sharpness = SHARP_EDGED, attacking_item = src)
		victim.add_splatter_floor(current)
		log_combat(src, victim, "floor-saw-run")
