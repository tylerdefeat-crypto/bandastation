// ============================================================
// Rust-Forged Labyrinth — Corrosion Controller + Forge Station
//
// Corrosion_Controller: per-sector background tick that degrades
// items/structures using atom_integrity and damages mobs based
// on the sector's rust_level (0–100).
//
// Forge Station: the unique anchor of the FORGE sector. Holds
// "The Blank" — picking it up triggers the Blacksmith hunt.
// ============================================================

// ============================================================
// /datum/corrosion_controller
// ============================================================

/datum/corrosion_controller
	/// The sector that owns this controller.
	var/datum/rust_sector/owning_sector
	/// FALSE until start() is called.
	var/running = FALSE

/datum/corrosion_controller/New(datum/rust_sector/sector)
	..()
	owning_sector = sector

/datum/corrosion_controller/Destroy()
	running = FALSE
	owning_sector = null
	return ..()

/// Begin the corrosion loop. Safe to call multiple times — no-ops if already running.
/datum/corrosion_controller/proc/start()
	if(running)
		return
	running = TRUE
	_loop()

/// Halt the corrosion loop.
/datum/corrosion_controller/proc/stop()
	running = FALSE

// ------------------------------------------------------------------
// Internal loop
// ------------------------------------------------------------------

/datum/corrosion_controller/proc/_loop()
	set waitfor = FALSE
	while(running && !QDELETED(src))
		SLEEP_NOT_DEL(CORROSION_TICK_INTERVAL)
		if(QDELETED(src) || !running)
			return
		_sweep()

/// One corrosion sweep: degrade items and optionally hurt mobs.
/datum/corrosion_controller/proc/_sweep()
	if(!owning_sector?.anchor_turf)
		return
	var/rust = owning_sector.rust_level
	if(rust < LABYRINTH_RUST_MILD)
		return

	var/item_damage = rust >= LABYRINTH_RUST_LETHAL ? CORROSION_DAMAGE_LETHAL : \
	                  rust >= LABYRINTH_RUST_HEAVY   ? CORROSION_DAMAGE_HEAVY  : \
	                                                   CORROSION_DAMAGE_MILD

	var/list/turfs = owning_sector.get_turfs()
	for(var/turf/T as anything in turfs)
		_process_turf(T, rust, item_damage)
		CHECK_TICK

/// Degrades items/structures on one turf and damages mobs if rust is high enough.
/datum/corrosion_controller/proc/_process_turf(turf/T, rust, item_damage)
	for(var/atom/movable/A as anything in T)
		if(QDELETED(A))
			continue
		if(isitem(A) || istype(A, /obj/structure))
			var/atom/MA = A
			if(MA.uses_integrity && !(MA.resistance_flags & (INDESTRUCTIBLE|ACID_PROOF)))
				if(!QDELING(MA) && MA.get_integrity() > 0)
					MA.take_damage(item_damage, BRUTE, "", FALSE)
			continue
		if(rust >= LABYRINTH_RUST_HEAVY && isliving(A))
			_corrode_mob(A, rust)

/datum/corrosion_controller/proc/_corrode_mob(mob/living/L, rust)
	if(!prob(CORROSION_MOB_PROC_CHANCE))
		return
	if(rust >= LABYRINTH_RUST_LETHAL)
		to_chat(L, span_userdanger("The environment is eating you alive. Every breath tastes like rust and blood."))
		L.apply_damage(CORROSION_MOB_DAMAGE_LETHAL, BRUTE, BODY_ZONE_CHEST)
	else
		to_chat(L, span_warning("The rust-choked air tears at your lungs."))
		L.apply_damage(CORROSION_MOB_DAMAGE_HEAVY, BRUTE, BODY_ZONE_CHEST)

// ============================================================
// /obj/structure/forge_station — The Forge anchor (FORGE sector)
// ============================================================

/obj/structure/forge_station
	name = "The Forge"
	desc = "A massive iron forge, cold yet humming with residual heat. Something rests on the anvil — something important."
	icon = 'icons/obj/structures.dmi'
	icon_state = "furnace"          // placeholder — replace with forge art
	density = TRUE
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE
	armor_type = /datum/armor/structure_forge_station

	/// The Blank sitting atop the forge. Null once taken.
	var/obj/item/blank/the_blank

/datum/armor/structure_forge_station
	melee = 90
	bullet = 60
	laser = 60
	energy = 40
	bomb = 50
	fire = 100
	acid = 80

/obj/structure/forge_station/Initialize(mapload)
	. = ..()
	the_blank = new /obj/item/blank(get_turf(src))
	RegisterSignal(the_blank, COMSIG_ITEM_PICKUP, PROC_REF(_on_blank_taken))

/obj/structure/forge_station/Destroy()
	if(the_blank && !QDELETED(the_blank))
		UnregisterSignal(the_blank, COMSIG_ITEM_PICKUP)
		QDEL_NULL(the_blank)
	return ..()

/obj/structure/forge_station/proc/_on_blank_taken(obj/item/blank/B, mob/user)
	SIGNAL_HANDLER
	the_blank = null   // dissociate — item is now with the player
	playsound(src, 'sound/effects/magic/voidblink.ogg', 100, TRUE)
	visible_message(span_warning("[src] shudders violently as [user] lifts [B] from the anvil, scattering sparks across the floor!"))
	to_chat(user, span_userdanger("The moment you lift [B], something distant stirs. The walls groan."))

// ============================================================
// /obj/item/blank — The Blank (the key item that starts the hunt)
// ============================================================

/obj/item/blank
	name = "The Blank"
	desc = "A massive iron casting, still faintly warm from the forge. Uncomfortably heavy. You feel like you shouldn't be holding this."
	icon = 'icons/obj/weapons/shields.dmi'  // placeholder
	icon_state = "buckler"
	w_class = WEIGHT_CLASS_HUGE
	force = 30
	throwforce = 25
	throw_speed = 1
	throw_range = 3
	max_integrity = 800
	uses_integrity = TRUE
	armor_type = /datum/armor/item_blank

/datum/armor/item_blank
	melee = 50
	bullet = 30
	laser = 30
	energy = 20
	bomb = 20
	fire = 80
	acid = 40

/obj/item/blank/examine(mob/user)
	. = ..()
	. += span_warning("It is unbearably heavy. Something about it feels deeply wrong.")
