// ============================================================
// Rust-Forged Labyrinth — Puzzle Terminal (Phase H3)
//
// A rusted console wired into a sector's channels. Players read a
// prompt and enter a code through TGUI. Correct → fires win_channel
// (open door / stop trap). Wrong → fires fail_channel (spring hazards).
//
// Map setup: place the terminal, set `solution`, `prompt`, win_channel
// and fail_channel in the DMM. Wire the door/hazards to those channels.
// ============================================================

/obj/structure/labyrinth_terminal
	name = "corroded terminal"
	desc = "A battered industrial console, its screen flickering with a single prompt."
	icon = 'icons/obj/machines/computer.dmi'
	icon_state = "oldcomp"           // placeholder
	density = TRUE
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE

	/// The code that solves the terminal.
	var/solution = "1379"
	/// Prompt text shown to players.
	var/prompt = "ENTER THE SEQUENCE."
	/// Channel fired on correct answer.
	var/win_channel = "term_win"
	/// Channel fired on wrong answer.
	var/fail_channel = "term_fail"
	/// TRUE once solved — locks further input.
	var/solved = FALSE
	/// Cached sector for fire_channel.
	var/datum/rust_sector/owner_sector

/obj/structure/labyrinth_terminal/Initialize(mapload)
	. = ..()
	if(GLOB.rust_grid_manager.initialized)
		owner_sector = GLOB.rust_grid_manager.get_sector_at(get_turf(src))

/obj/structure/labyrinth_terminal/Destroy()
	owner_sector = null
	return ..()

/obj/structure/labyrinth_terminal/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	ui_interact(user)

/obj/structure/labyrinth_terminal/ui_state(mob/user)
	return GLOB.physical_state

/obj/structure/labyrinth_terminal/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "LabyrinthTerminal")
		ui.open()

/obj/structure/labyrinth_terminal/ui_data(mob/user)
	var/list/data = list()
	data["prompt"] = prompt
	data["solved"] = solved
	return data

/obj/structure/labyrinth_terminal/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	if(solved)
		return TRUE
	switch(action)
		if("submit")
			var/entry = params["code"]
			if(isnull(entry))
				return TRUE
			if("[entry]" == solution)
				_on_solved(usr)
			else
				_on_failed(usr)
			return TRUE

/obj/structure/labyrinth_terminal/proc/_on_solved(mob/user)
	solved = TRUE
	playsound(src, 'sound/machines/ping.ogg', 60, TRUE)
	visible_message(span_nicegreen("[src] chimes — a distant lock disengages."))
	if(owner_sector && win_channel)
		owner_sector.fire_channel(win_channel, HAZARD_ACTION_STOP_LOOP)
	log_game("rust_labyrinth: terminal solved at ([x],[y]).")

/obj/structure/labyrinth_terminal/proc/_on_failed(mob/user)
	playsound(src, 'sound/machines/buzz/buzz-sigh.ogg', 60, TRUE)
	visible_message(span_danger("[src] blares a rejection. Something stirs."))
	if(owner_sector && fail_channel)
		owner_sector.fire_channel(fail_channel, HAZARD_ACTION_TRIGGER)
