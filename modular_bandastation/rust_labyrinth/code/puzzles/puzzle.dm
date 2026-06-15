// ============================================================
// Rust-Forged Labyrinth — Puzzle framework (Phase H1)
//
// A puzzle is a datum that listens to its sector's channels (fired by
// pressure plates / terminals), checks a win condition, and on solve
// fires win_channel (open a door, stop a loop trap); on fail fires
// fail_channel (spring the hazards).
//
// Subtypes override on_input(channel, mode). The base owns signal
// wiring, solve()/fail()/reset() and broadcast messaging.
// ============================================================

/datum/labyrinth_puzzle
	/// Human-readable name (logs / TGUI).
	var/puzzle_name = "puzzle"
	/// Sector this puzzle lives in.
	var/datum/rust_sector/owner_sector
	/// Channels this puzzle reacts to (pressure plates / terminals).
	var/list/input_channels = list()
	/// Fired on solve — wire a door/loop-stop hazard to this name.
	var/win_channel
	/// Fired on fail — wire the punishment hazards to this name.
	var/fail_channel
	/// TRUE once solved; further input is ignored.
	var/solved = FALSE

/// Bind the puzzle to a sector and start listening to its input channels.
/datum/labyrinth_puzzle/proc/setup(datum/rust_sector/S)
	owner_sector = S
	RegisterSignal(S, COMSIG_LABYRINTH_CHANNEL_FIRED, PROC_REF(_on_channel))

/datum/labyrinth_puzzle/Destroy()
	if(owner_sector)
		UnregisterSignal(owner_sector, COMSIG_LABYRINTH_CHANNEL_FIRED)
	owner_sector = null
	return ..()

/// Signal gate — filters to our input channels, then defers to on_input.
/datum/labyrinth_puzzle/proc/_on_channel(datum/source, channel, mode)
	SIGNAL_HANDLER
	if(solved)
		return
	if(!(channel in input_channels))
		return
	on_input(channel, mode)

/// Per-subtype puzzle logic. OVERRIDE.
/datum/labyrinth_puzzle/proc/on_input(channel, mode)
	return

/// Mark solved, fire the reward channel, announce to the sector.
/datum/labyrinth_puzzle/proc/solve()
	if(solved)
		return
	solved = TRUE
	if(owner_sector && win_channel)
		owner_sector.fire_channel(win_channel, HAZARD_ACTION_STOP_LOOP)
	_announce(span_nicegreen("Something heavy unlatches in the dark. The way forward groans open."))
	log_game("rust_labyrinth: puzzle '[puzzle_name]' solved in sector ([owner_sector?.grid_x],[owner_sector?.grid_y]).")

/// Punish failure — spring the wired hazards.
/datum/labyrinth_puzzle/proc/fail()
	if(owner_sector && fail_channel)
		owner_sector.fire_channel(fail_channel, HAZARD_ACTION_TRIGGER)
	_announce(span_danger("A wrong move. The mechanisms shudder awake."))

/// Reset progress (does not un-solve).
/datum/labyrinth_puzzle/proc/reset()
	return

/// Broadcast a message to everyone standing in the sector.
/datum/labyrinth_puzzle/proc/_announce(message)
	if(!owner_sector)
		return
	for(var/turf/T as anything in owner_sector.get_turfs())
		for(var/mob/living/L in T)
			to_chat(L, message)
