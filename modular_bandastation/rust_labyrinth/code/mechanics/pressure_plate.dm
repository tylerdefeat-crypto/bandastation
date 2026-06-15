// ============================================================
// Rust-Forged Labyrinth — Pressure Plate (Phase G1)
//
// Mappable floor activator. Set target_channel + plate_mode in the
// DMM; on being stepped on it fires that channel in its sector, which
// drives any hazard/puzzle wired to the same channel name.
//
// Detection uses the connect_loc element (COMSIG_ATOM_ENTERED/EXITED),
// the same pattern as code/game/objects/effects/mines.dm.
// ============================================================

/obj/structure/labyrinth_pressure_plate
	name = "pressure plate"
	desc = "A slab of grimy steel set a hair above the floor. It gives slightly underfoot."
	icon = 'icons/obj/structures.dmi'
	icon_state = "plasteel_pressure"   // placeholder — swap for plate sprite
	density = FALSE
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE

	/// Channel fired in this sector when triggered.
	var/target_channel
	/// PLATE_MOMENTARY / PLATE_HOLD / PLATE_WEIGHTED
	var/plate_mode = PLATE_MOMENTARY
	/// Action a MOMENTARY plate sends (HAZARD_ACTION_*).
	var/fire_action = HAZARD_ACTION_TRIGGER
	/// WEIGHTED: how many living mobs must stand on it to fire.
	var/required_count = 1
	/// TRUE while currently held down (HOLD/WEIGHTED satisfied).
	var/pressed = FALSE
	/// Cached sector for fire_channel.
	var/datum/rust_sector/owner_sector

/obj/structure/labyrinth_pressure_plate/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
		COMSIG_ATOM_EXITED = PROC_REF(on_exited),
	)
	AddElement(/datum/element/connect_loc, loc_connections)
	if(GLOB.rust_grid_manager.initialized)
		owner_sector = GLOB.rust_grid_manager.get_sector_at(get_turf(src))

/obj/structure/labyrinth_pressure_plate/Destroy()
	owner_sector = null
	return ..()

/// A living mob (or enough of them) just stepped on.
/obj/structure/labyrinth_pressure_plate/proc/on_entered(datum/source, atom/movable/arrived)
	SIGNAL_HANDLER
	if(!isliving(arrived))
		return
	switch(plate_mode)
		if(PLATE_MOMENTARY)
			_depress()
			_fire(fire_action)
		if(PLATE_HOLD)
			if(!pressed)
				pressed = TRUE
				_depress()
				_fire(HAZARD_ACTION_START_LOOP)
		if(PLATE_WEIGHTED)
			if(!pressed && _count_on_plate() >= required_count)
				pressed = TRUE
				_depress()
				_fire(HAZARD_ACTION_TRIGGER)

/// Something left the plate.
/obj/structure/labyrinth_pressure_plate/proc/on_exited(datum/source, atom/movable/gone)
	SIGNAL_HANDLER
	switch(plate_mode)
		if(PLATE_HOLD)
			if(pressed && !_count_on_plate())
				pressed = FALSE
				_release()
				_fire(HAZARD_ACTION_STOP_LOOP)
		if(PLATE_WEIGHTED)
			if(pressed && _count_on_plate() < required_count)
				pressed = FALSE
				_release()
				_fire(HAZARD_ACTION_STOP_LOOP)

/obj/structure/labyrinth_pressure_plate/proc/_fire(mode)
	if(owner_sector && target_channel)
		owner_sector.fire_channel(target_channel, mode)

/// Count living mobs currently standing on this tile.
/obj/structure/labyrinth_pressure_plate/proc/_count_on_plate()
	var/n = 0
	for(var/mob/living/L in get_turf(src))
		n++
	return n

/obj/structure/labyrinth_pressure_plate/proc/_depress()
	pixel_y = -2
	playsound(src, 'sound/machines/clockcult/integration_cog_install.ogg', 50, TRUE, -2)

/obj/structure/labyrinth_pressure_plate/proc/_release()
	pixel_y = 0
