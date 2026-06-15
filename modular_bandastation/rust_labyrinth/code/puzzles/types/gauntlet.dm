// ============================================================
// Rust-Forged Labyrinth — Gauntlet Puzzle (Phase H2)
//
// Not a riddle — a survival run. On setup every hazard in the sector
// starts looping continuously (spikes, pistons, saws). The only "win"
// is reaching the finish plate at the far end alive, which halts the
// machines and opens the exit. Failure = dying in the corridor.
//
// Map setup: lay the obstacle hazards down the room (they auto-loop),
// and a finish pressure plate at the exit with target_channel =
// finish_channel. Wire the exit door to win_channel.
// ============================================================

/datum/labyrinth_puzzle/gauntlet
	puzzle_name = "gauntlet"
	win_channel = "gauntlet_win"
	/// Plate at the far end that ends the run.
	var/finish_channel = "gauntlet_finish"

/datum/labyrinth_puzzle/gauntlet/setup(datum/rust_sector/S)
	input_channels = list(finish_channel)
	. = ..()
	// Bring the whole room to life.
	S.sync_controller?.loop_all()
	_announce(span_danger("Machinery roars to life all around. The only way out is through."))

/datum/labyrinth_puzzle/gauntlet/on_input(channel, mode)
	// Reaching the finish plate stops every hazard and opens the exit.
	owner_sector?.sync_controller?.stop_all()
	solve()

/datum/labyrinth_puzzle/gauntlet/Destroy()
	// Make sure the room doesn't keep grinding if the puzzle is torn down.
	owner_sector?.sync_controller?.stop_all()
	return ..()
