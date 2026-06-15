// ============================================================
// Rust-Forged Labyrinth — Controllable Door (Phase G/console)
//
// A mappable blast gate the admin console (and puzzles via channels)
// can open and close. Blocks passage and sight while shut. Reacts to
// wiring channels: open_channel opens it, close_channel shuts it.
//
// Self-registers into its sector's door list so the control panel can
// enumerate every door in a zone.
// ============================================================

/obj/structure/labyrinth_door
	name = "rusted gate"
	desc = "A slab of pitted blast plating on corroded runners. It can still be driven up and down."
	icon = 'icons/obj/structures.dmi'
	icon_state = "grille"            // placeholder — swap for shutter sprite
	density = TRUE
	opacity = TRUE
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE

	/// Channel that opens this gate (any mode).
	var/open_channel
	/// Channel that closes this gate (any mode).
	var/close_channel
	/// TRUE while raised/open.
	var/is_open = FALSE
	/// Cached sector for unregister.
	var/datum/rust_sector/owner_sector

/obj/structure/labyrinth_door/Initialize(mapload)
	. = ..()
	if(!GLOB.rust_grid_manager.initialized)
		return
	var/datum/rust_sector/S = GLOB.rust_grid_manager.get_sector_at(get_turf(src))
	if(!S)
		return
	owner_sector = S
	S.doors |= src
	if(open_channel)
		S.register_wire(open_channel, src)
	if(close_channel)
		S.register_wire(close_channel, src)

/obj/structure/labyrinth_door/Destroy()
	if(owner_sector)
		owner_sector.doors -= src
		if(open_channel)
			owner_sector.unregister_wire(open_channel, src)
		if(close_channel)
			owner_sector.unregister_wire(close_channel, src)
	owner_sector = null
	return ..()

/obj/structure/labyrinth_door/proc/open()
	if(is_open)
		return
	is_open = TRUE
	set_density(FALSE)
	set_opacity(FALSE)
	icon_state = "grille_broken"     // placeholder: open state
	playsound(src, 'sound/machines/airlock/airlock.ogg', 70, TRUE)

/obj/structure/labyrinth_door/proc/close()
	if(!is_open)
		return
	is_open = FALSE
	set_density(TRUE)
	set_opacity(TRUE)
	icon_state = "grille"            // placeholder: closed state
	playsound(src, 'sound/machines/airlock/airlock.ogg', 70, TRUE)

/obj/structure/labyrinth_door/proc/toggle()
	if(is_open)
		close()
	else
		open()

/// Wiring reaction. Channel decides open vs close; same channel = toggle.
/obj/structure/labyrinth_door/proc/on_channel_signal(mode, channel)
	if(open_channel && close_channel && open_channel == close_channel)
		toggle()
	else if(channel == open_channel)
		open()
	else if(channel == close_channel)
		close()
