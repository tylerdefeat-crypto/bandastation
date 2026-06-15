// ============================================================
// Rust-Forged Labyrinth — Sequence Puzzle (Phase H2)
//
// Step on plates in the correct order (Cube-like). Each correct step
// advances progress; a wrong step resets progress and springs the
// fail hazards. Completing the order solves the puzzle.
//
// Map setup: place pressure plates with target_channel = each entry of
// correct_order. Wire the punishment hazards to fail_channel and the
// exit door to win_channel.
// ============================================================

/datum/labyrinth_puzzle/sequence
	puzzle_name = "sequence"
	fail_channel = "seq_fail"
	win_channel = "seq_win"
	/// Channels that must be stepped in this exact order.
	var/list/correct_order = list("seq_a", "seq_b", "seq_c")
	/// How many correct steps so far.
	var/progress = 0

/datum/labyrinth_puzzle/sequence/setup(datum/rust_sector/S)
	// Listen to every plate in the sequence.
	input_channels = correct_order.Copy()
	return ..()

/datum/labyrinth_puzzle/sequence/on_input(channel, mode)
	var/expected = correct_order[progress + 1]
	if(channel == expected)
		progress++
		if(progress >= length(correct_order))
			solve()
		else
			_announce(span_notice("A tumbler clicks into place. [progress]/[length(correct_order)]."))
	else
		progress = 0
		fail()

/datum/labyrinth_puzzle/sequence/reset()
	progress = 0
