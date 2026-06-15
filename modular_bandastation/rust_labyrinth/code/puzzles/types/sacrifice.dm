// ============================================================
// Rust-Forged Labyrinth — Sacrifice Puzzle (Phase H2)
//
// The door opens only at a price: a severed limb laid on the altar,
// or a living body held down on it. A confirm plate/lever checks the
// altar tile; if the toll is paid the way opens, otherwise nothing.
//
// Map setup: a WEIGHTED or MOMENTARY plate as the "confirm" input
// (target_channel = confirm_channel) sitting on, or beside, the altar
// tile. The altar tile is the plate's own turf by default.
// ============================================================

/datum/labyrinth_puzzle/sacrifice
	puzzle_name = "sacrifice"
	win_channel = "sac_win"
	/// Plate/lever channel that checks the altar.
	var/confirm_channel = "sac_confirm"
	/// Offset (ox, oy) of the altar tile from the sector anchor.
	/// If null, the puzzle checks every confirm-plate's own tile instead.
	var/altar_ox
	var/altar_oy
	/// If TRUE, a living mob counts; bodyparts always count.
	var/accept_living = TRUE

/datum/labyrinth_puzzle/sacrifice/setup(datum/rust_sector/S)
	input_channels = list(confirm_channel)
	return ..()

/datum/labyrinth_puzzle/sacrifice/on_input(channel, mode)
	var/turf/altar = _altar_turf()
	if(!altar)
		return
	if(_toll_paid(altar))
		solve()
	else
		_announce(span_warning("The altar is bare. It demands flesh."))

/datum/labyrinth_puzzle/sacrifice/proc/_altar_turf()
	if(isnull(altar_ox) || isnull(altar_oy) || !owner_sector?.anchor_turf)
		return null
	return locate(owner_sector.anchor_turf.x + altar_ox, owner_sector.anchor_turf.y + altar_oy, owner_sector.anchor_turf.z)

/// A severed bodypart on the altar, or (optionally) a living mob.
/datum/labyrinth_puzzle/sacrifice/proc/_toll_paid(turf/altar)
	for(var/obj/item/bodypart/limb in altar)
		return TRUE
	if(accept_living)
		for(var/mob/living/L in altar)
			return TRUE
	return FALSE
