// ============================================================
// Rust-Forged Labyrinth — Channel wiring (Phase G2)
//
// Mapper-friendly string-channel linking. A pressure plate set to
// target_channel = "trap_a" fires every responder registered on
// "trap_a" — hazards (start/stop/trigger) and, via signal, puzzles.
//
// Responders self-register in their Initialize:
//   sector.register_wire(channel, src)
// and react through on_channel_signal(mode). Puzzles instead listen
// with RegisterSignal(sector, COMSIG_LABYRINTH_CHANNEL(channel), ...).
// ============================================================

/// Register a responder (hazard, door, …) on a channel.
/datum/rust_sector/proc/register_wire(channel, atom/responder)
	if(!channel || !responder)
		return
	LAZYINITLIST(wiring[channel])
	wiring[channel] |= responder

/// Remove a responder from a channel.
/datum/rust_sector/proc/unregister_wire(channel, atom/responder)
	if(!channel || !wiring?[channel])
		return
	wiring[channel] -= responder
	if(!length(wiring[channel]))
		wiring -= channel

/// Fire a channel: react every direct responder + notify signal listeners.
/// mode is a HAZARD_ACTION_* constant.
/datum/rust_sector/proc/fire_channel(channel, mode = HAZARD_ACTION_TRIGGER)
	if(!channel)
		return
	for(var/atom/responder as anything in wiring[channel])
		if(QDELETED(responder))
			continue
		// Hazards and doors both implement on_channel_signal(mode, channel).
		if(hascall(responder, "on_channel_signal"))
			call(responder, "on_channel_signal")(mode, channel)
	// Puzzles / terminals listen via signal rather than the responder list.
	SEND_SIGNAL(src, COMSIG_LABYRINTH_CHANNEL_FIRED, channel, mode)

/// All channel names currently wired in this sector (for admin/TGUI display).
/datum/rust_sector/proc/get_channels()
	var/list/names = list()
	for(var/channel in wiring)
		names += channel
	return names
