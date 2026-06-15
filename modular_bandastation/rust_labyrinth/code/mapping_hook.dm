// ============================================================
// Rust-Forged Labyrinth — SSmapping hook
//
// Extends SSmapping/Initialize so the labyrinth loads at the
// same stage as lavaland and random ruins — during server load,
// never mid-round.
// ============================================================

/datum/controller/subsystem/mapping/Initialize(start_mc_time)
	. = ..()
	var/datum/rust_grid_manager/mgr = GLOB.rust_grid_manager
	if(!mgr.initialize_labyrinth())
		log_game("rust_labyrinth: initialize_labyrinth() failed during SSmapping init.")
		return
	register_default_labyrinth_layout()
	for(var/gx in 1 to LABYRINTH_GRID_SIZE)
		for(var/gy in 1 to LABYRINTH_GRID_SIZE)
			mgr.load_sector(gx, gy)
			CHECK_TICK
	log_game("rust_labyrinth: [LABYRINTH_GRID_SIZE * LABYRINTH_GRID_SIZE] sectors loaded on Z=[mgr.labyrinth_level.z_value].")
