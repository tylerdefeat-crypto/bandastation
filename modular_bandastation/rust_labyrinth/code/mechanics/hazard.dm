// ============================================================
// Rust-Forged Labyrinth — Hazard base (Phase F1)
//
// Common base for every "death mechanism": piston, floor spikes,
// wall saw, floor saw. Provides:
//   — trigger()    : fire one cycle (fire-and-forget, parallel-safe)
//   — start_loop() : run cycles continuously until stopped
//   — channel wiring reaction (on_channel_signal)
//   — auto-registration into the sector's sync_controller + channel
//
// Subtypes ONLY override run_cycle() with their own warn→strike→reset
// animation. The base owns the operating lock and loop driver.
// ============================================================

/obj/structure/labyrinth_hazard
	name = "labyrinth hazard"
	desc = "A grinding mechanism set into the rusted architecture."
	icon = 'icons/obj/structures.dmi'
	icon_state = "grille"
	density = TRUE
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE  // corrosion sweep skips these

	/// TRUE while a cycle is mid-flight — blocks overlapping cycles.
	var/operating = FALSE
	/// Wiring channel this hazard listens on. "" / null = unwired.
	var/hazard_channel
	/// What to do when hazard_channel fires (HAZARD_ACTION_*).
	var/channel_action = HAZARD_ACTION_TRIGGER
	/// TRUE while auto-looping.
	var/loop_active = FALSE
	/// Delay between auto-loop cycles (deciseconds).
	var/loop_interval = HAZARD_LOOP_INTERVAL
	/// Start delay before the first auto-loop cycle — lets rows fire in waves.
	var/loop_offset = 0
	/// Sector sync controller we registered into (sector-wide grouping).
	var/datum/sync_controller/owner_sync
	/// Sector we belong to (cached for wiring unregister).
	var/datum/rust_sector/owner_sector

	// --- Contact damage (spinning-blade graze) ---
	/// Brute per contact tick. 0 = no contact loop (pistons/spikes stay
	/// purely telegraphed). >0 spins up a slow graze loop in Initialize.
	var/contact_damage = 0
	/// Sharpness used for contact grazes.
	var/contact_sharpness = SHARP_EDGED
	/// Tile distances along `dir` that are lethal to touch RIGHT NOW.
	/// 0 = our own tile. Subtypes rewrite this as the blade extends.
	var/list/live_offsets
	/// TRUE while the contact loop is running.
	var/contact_active = FALSE

// ------------------------------------------------------------------
// Registration
// ------------------------------------------------------------------

/obj/structure/labyrinth_hazard/Initialize(mapload)
	. = ..()
	// Contact graze runs regardless of sector registration — an
	// admin-spawned saw on a bare turf must still bite.
	if(contact_damage > 0)
		start_contact_loop()
	if(!GLOB.rust_grid_manager?.initialized)
		return
	var/datum/rust_sector/S = GLOB.rust_grid_manager.get_sector_at(get_turf(src))
	if(!S)
		return
	owner_sector = S
	if(S.sync_controller)
		S.sync_controller.register_hazard(src)
		owner_sync = S.sync_controller
	if(hazard_channel)
		S.register_wire(hazard_channel, src)

/obj/structure/labyrinth_hazard/Destroy()
	stop_loop()
	contact_active = FALSE
	if(owner_sync)
		owner_sync.unregister_hazard(src)
		owner_sync = null
	if(owner_sector && hazard_channel)
		owner_sector.unregister_wire(hazard_channel, src)
	owner_sector = null
	return ..()

// ------------------------------------------------------------------
// Activation
// ------------------------------------------------------------------

/// Fire one cycle. Parallel-safe (waitfor = FALSE) so a controller can
/// pulse many hazards "simultaneously". No-op if already operating.
/obj/structure/labyrinth_hazard/proc/trigger()
	set waitfor = FALSE
	if(operating)
		return FALSE
	operating = TRUE
	run_cycle()
	operating = FALSE
	return TRUE

/// The actual warn→strike→reset body. OVERRIDE in subtypes.
/// Runs inside an operating lock; safe to SLEEP_NOT_DEL here.
/obj/structure/labyrinth_hazard/proc/run_cycle()
	return

/// Begin continuous looping. Cycles run back-to-back with loop_interval
/// between them. loop_offset staggers the first cycle for wave effects.
/obj/structure/labyrinth_hazard/proc/start_loop()
	set waitfor = FALSE
	if(loop_active)
		return
	loop_active = TRUE
	if(loop_offset)
		SLEEP_NOT_DEL(loop_offset)
	while(loop_active && !QDELETED(src))
		if(!operating)
			operating = TRUE
			run_cycle()
			operating = FALSE
		SLEEP_NOT_DEL(loop_interval)

/// Stop looping after the current cycle finishes.
/obj/structure/labyrinth_hazard/proc/stop_loop()
	loop_active = FALSE

/// Reaction when our wiring channel fires. Hazards act on `mode`;
/// `channel` is accepted for interface parity with doors but ignored.
/obj/structure/labyrinth_hazard/proc/on_channel_signal(mode = HAZARD_ACTION_TRIGGER, channel)
	switch(mode)
		if(HAZARD_ACTION_TRIGGER)
			trigger()
		if(HAZARD_ACTION_START_LOOP)
			start_loop()
		if(HAZARD_ACTION_STOP_LOOP)
			stop_loop()
		if(HAZARD_ACTION_TOGGLE_LOOP)
			if(loop_active)
				stop_loop()
			else
				start_loop()

// ------------------------------------------------------------------
// Damage
// ------------------------------------------------------------------

/// Land one hit of brute on a victim. Shared by cycle strikes and the
/// contact loop so both deal damage identically. Skips the dead.
/// Returns TRUE if a live victim was bitten.
/obj/structure/labyrinth_hazard/proc/_bite(mob/living/victim, damage, wound_bonus = 0, list/zones)
	if(QDELETED(victim) || victim.stat == DEAD)
		return FALSE
	victim.apply_damage(
		damage,
		BRUTE,
		length(zones) ? pick(zones) : null,
		wound_bonus = wound_bonus,
		sharpness = contact_sharpness,
		attacking_item = src,
	)
	victim.add_splatter_floor(get_turf(victim))
	log_combat(src, victim, "[name]-hit")
	return TRUE

// ------------------------------------------------------------------
// Contact graze — a slow, continuous bite for anyone touching a live
// blade tile while it spins. Covers BOTH standing and walking-in, idle
// and mid-cycle. Subtypes set `contact_damage` and rewrite `live_offsets`.
// ------------------------------------------------------------------

/// Driver: ticks every HAZARD_CONTACT_INTERVAL until the hazard is gone.
/obj/structure/labyrinth_hazard/proc/start_contact_loop()
	set waitfor = FALSE
	if(contact_active)
		return
	contact_active = TRUE
	while(contact_active && !QDELETED(src))
		_contact_sweep()
		SLEEP_NOT_DEL(HAZARD_CONTACT_INTERVAL)

/// Damage every living mob standing on a currently-live blade tile.
/obj/structure/labyrinth_hazard/proc/_contact_sweep()
	if(!length(live_offsets))
		return
	var/turf/origin = get_turf(src)
	if(!origin)
		return
	for(var/offset in live_offsets)
		var/turf/live = origin
		for(var/i in 1 to offset)
			live = get_step(live, dir)
			if(!live)
				break
		if(!live)
			continue
		for(var/mob/living/victim in live)
			_bite(victim, contact_damage)

// ============================================================
// Sync_Controller — groups every hazard in one sector.
// Used by the admin "pulse here" verb and sector-wide loop/stop.
// ============================================================

/datum/sync_controller
	/// All hazards currently registered to this controller.
	var/list/obj/structure/labyrinth_hazard/hazards = list()
	/// TRUE while a synchronized pulse is in-flight — prevents overlap.
	var/pulsing = FALSE

/datum/sync_controller/Destroy()
	hazards.Cut()
	return ..()

/datum/sync_controller/proc/register_hazard(obj/structure/labyrinth_hazard/H)
	hazards |= H

/datum/sync_controller/proc/unregister_hazard(obj/structure/labyrinth_hazard/H)
	hazards -= H

/// Fire every hazard once, simultaneously. Locks for one full cycle.
/datum/sync_controller/proc/pulse()
	if(pulsing)
		return FALSE
	pulsing = TRUE
	SEND_SIGNAL(src, COMSIG_LABYRINTH_PISTON_SYNC)
	for(var/obj/structure/labyrinth_hazard/H as anything in hazards)
		if(!QDELETED(H))
			H.trigger()
	addtimer(CALLBACK(src, PROC_REF(_end_pulse)), PISTON_WARN_TIME + PISTON_EXTEND_TIME + PISTON_HOLD_TIME + PISTON_RETRACT_TIME + 5)
	return TRUE

/datum/sync_controller/proc/_end_pulse()
	pulsing = FALSE

/// Start every hazard auto-looping.
/datum/sync_controller/proc/loop_all()
	for(var/obj/structure/labyrinth_hazard/H as anything in hazards)
		if(!QDELETED(H))
			H.start_loop()

/// Stop every hazard auto-looping.
/datum/sync_controller/proc/stop_all()
	for(var/obj/structure/labyrinth_hazard/H as anything in hazards)
		if(!QDELETED(H))
			H.stop_loop()
