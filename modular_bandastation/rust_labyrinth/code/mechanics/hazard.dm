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

// ------------------------------------------------------------------
// Registration
// ------------------------------------------------------------------

/obj/structure/labyrinth_hazard/Initialize(mapload)
	. = ..()
	if(!GLOB.rust_grid_manager.initialized)
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
