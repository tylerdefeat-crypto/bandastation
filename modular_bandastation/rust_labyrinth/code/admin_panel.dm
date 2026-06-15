// ============================================================
// Rust-Forged Labyrinth — Admin Control Panel (TGUI)
//
// Pattern from code/modules/admin/verbs/secrets.dm:
//   ADMIN_VERB → datum → ui_interact / ui_data / ui_act
// ============================================================

ADMIN_VERB(labyrinth_panel, R_ADMIN, "Labyrinth: Control Panel", "Открыть панель управления лабиринтом.", ADMIN_CATEGORY_EVENTS)
	var/datum/labyrinth_control_panel/panel = new(user)
	panel.ui_interact(user.mob)
	BLACKBOX_LOG_ADMIN_VERB("Labyrinth Control Panel")

// ============================================================
// /datum/labyrinth_control_panel
// ============================================================

/datum/labyrinth_control_panel
	var/client/holder
	/// Sector index whose object inspector is currently open (null — none).
	var/selected_index

/datum/labyrinth_control_panel/New(client/user)
	..()
	holder = user

/datum/labyrinth_control_panel/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "LabyrinthControl")
		ui.open()

/datum/labyrinth_control_panel/ui_state(mob/user)
	return ADMIN_STATE(R_ADMIN)

/datum/labyrinth_control_panel/ui_close(mob/user)
	qdel(src)

/datum/labyrinth_control_panel/ui_data(mob/user)
	var/datum/rust_grid_manager/mgr = GLOB.rust_grid_manager
	var/list/data = list()
	data["initialized"] = mgr.initialized
	data["labyrinth_z"] = mgr.labyrinth_level?.z_value
	data["grid_size"] = LABYRINTH_GRID_SIZE

	var/list/sector_list = list()
	for(var/i in 1 to LABYRINTH_GRID_SIZE * LABYRINTH_GRID_SIZE)
		var/datum/rust_sector/S = mgr.sectors[i]
		sector_list += list(list(
			"index"        = i,
			"gx"           = S.grid_x,
			"gy"           = S.grid_y,
			"state"        = S.state,
			"sector_type"  = S.sector_type,
			"rust_level"   = S.rust_level,
			"has_sync"     = !isnull(S.sync_controller),
			"has_corrosion" = !isnull(S.corrosion_controller),
			"has_mappath"  = (S.mappath ? TRUE : FALSE),
			"hazard_count" = (S.sync_controller ? length(S.sync_controller.hazards) : 0),
			"puzzle_name"  = (S.active_puzzle ? S.active_puzzle.puzzle_name : ""),
			"channels"     = S.get_channels(),
		))
	data["sectors"] = sector_list

	// Object inspector for the currently selected sector.
	data["selected_index"] = selected_index
	if(selected_index && selected_index >= 1 && selected_index <= length(mgr.sectors))
		var/datum/rust_sector/sel = mgr.sectors[selected_index]
		var/list/hazard_list = list()
		if(sel.sync_controller)
			for(var/obj/structure/labyrinth_hazard/H as anything in sel.sync_controller.hazards)
				if(QDELETED(H))
					continue
				hazard_list += list(list(
					"ref"      = REF(H),
					"name"     = H.name,
					"x"        = H.x,
					"y"        = H.y,
					"operating" = H.operating,
					"looping"  = H.loop_active,
					"channel"  = (H.hazard_channel || ""),
				))
		data["hazards"] = hazard_list

		var/list/door_list = list()
		for(var/obj/structure/labyrinth_door/D as anything in sel.doors)
			if(QDELETED(D))
				continue
			door_list += list(list(
				"ref"    = REF(D),
				"name"   = D.name,
				"x"      = D.x,
				"y"      = D.y,
				"is_open" = D.is_open,
			))
		data["doors"] = door_list
	else
		data["hazards"] = list()
		data["doors"] = list()
	return data

/datum/labyrinth_control_panel/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	var/datum/rust_grid_manager/mgr = GLOB.rust_grid_manager

	switch(action)
		if("initialize")
			if(mgr.initialized)
				return TRUE
			mgr.initialize_labyrinth()
			log_admin("[key_name(holder)] initialized the Rust Labyrinth via control panel.")
			message_admins("[key_name_admin(holder)] initialized the Rust Labyrinth.")
			return TRUE

		if("load_all")
			if(!mgr.initialized)
				return TRUE
			mgr.load_all_sectors()
			log_admin("[key_name(holder)] loaded all Rust Labyrinth sectors via control panel.")
			return TRUE

		if("goto_sector")
			var/index = text2num(params["index"])
			if(!isnum(index) || !mgr.initialized)
				return TRUE
			var/datum/rust_sector/S = mgr.sectors[index]
			if(!S?.anchor_turf)
				return TRUE
			holder.mob.abstract_move(S.anchor_turf)
			log_admin("[key_name(holder)] teleported to labyrinth sector ([S.grid_x],[S.grid_y]).")
			return TRUE

		if("load_sector")
			var/index = text2num(params["index"])
			if(!isnum(index) || !mgr.initialized)
				return TRUE
			var/datum/rust_sector/S = mgr.sectors[index]
			if(!S)
				return TRUE
			mgr.load_sector(S.grid_x, S.grid_y)
			log_admin("[key_name(holder)] loaded labyrinth sector ([S.grid_x],[S.grid_y]) via control panel.")
			return TRUE

		if("pulse_pistons")
			var/index = text2num(params["index"])
			if(!isnum(index))
				return TRUE
			var/datum/rust_sector/S = mgr.sectors[index]
			if(!S?.sync_controller)
				return TRUE
			S.sync_controller.pulse()
			log_admin("[key_name(holder)] pulsed pistons in labyrinth sector ([S.grid_x],[S.grid_y]).")
			return TRUE

		if("loop_traps")
			var/index = text2num(params["index"])
			if(!isnum(index))
				return TRUE
			var/datum/rust_sector/S = mgr.sectors[index]
			if(!S?.sync_controller)
				return TRUE
			S.sync_controller.loop_all()
			log_admin("[key_name(holder)] started trap loop in labyrinth sector ([S.grid_x],[S.grid_y]).")
			return TRUE

		if("stop_traps")
			var/index = text2num(params["index"])
			if(!isnum(index))
				return TRUE
			var/datum/rust_sector/S = mgr.sectors[index]
			if(!S?.sync_controller)
				return TRUE
			S.sync_controller.stop_all()
			log_admin("[key_name(holder)] stopped trap loop in labyrinth sector ([S.grid_x],[S.grid_y]).")
			return TRUE

		if("select_sector")
			var/index = text2num(params["index"])
			selected_index = (isnum(index) ? index : null)
			return TRUE

		if("trigger_hazard")
			var/obj/structure/labyrinth_hazard/H = locate(params["ref"])
			if(!istype(H))
				return TRUE
			H.trigger()
			log_admin("[key_name(holder)] triggered hazard [H.name] at ([H.x],[H.y]).")
			return TRUE

		if("loop_hazard")
			var/obj/structure/labyrinth_hazard/H = locate(params["ref"])
			if(!istype(H))
				return TRUE
			H.start_loop()
			log_admin("[key_name(holder)] looped hazard [H.name] at ([H.x],[H.y]).")
			return TRUE

		if("stop_hazard")
			var/obj/structure/labyrinth_hazard/H = locate(params["ref"])
			if(!istype(H))
				return TRUE
			H.stop_loop()
			log_admin("[key_name(holder)] stopped hazard [H.name] at ([H.x],[H.y]).")
			return TRUE

		if("toggle_door")
			var/obj/structure/labyrinth_door/D = locate(params["ref"])
			if(!istype(D))
				return TRUE
			D.toggle()
			log_admin("[key_name(holder)] [D.is_open ? "opened" : "closed"] door at ([D.x],[D.y]).")
			return TRUE

		if("set_rust")
			var/index = text2num(params["index"])
			var/level = text2num(params["level"])
			if(!isnum(index) || !isnum(level))
				return TRUE
			var/datum/rust_sector/S = mgr.sectors[index]
			if(!S)
				return TRUE
			level = clamp(level, 0, 100)
			S.rust_level = level
			if(S.corrosion_controller)
				if(level > 0)
					S.corrosion_controller.start()
				else
					S.corrosion_controller.stop()
			log_admin("[key_name(holder)] set rust_level=[level] in labyrinth sector ([S.grid_x],[S.grid_y]).")
			return TRUE

		if("force_corrosion")
			var/index = text2num(params["index"])
			if(!isnum(index))
				return TRUE
			var/datum/rust_sector/S = mgr.sectors[index]
			if(!S?.corrosion_controller)
				return TRUE
			S.corrosion_controller._sweep()
			log_admin("[key_name(holder)] forced corrosion sweep in labyrinth sector ([S.grid_x],[S.grid_y]).")
			return TRUE

		if("setup_layout")
			if(!mgr.initialized)
				return TRUE
			register_default_labyrinth_layout()
			mgr.load_all_sectors()
			log_admin("[key_name(holder)] applied default labyrinth layout via control panel.")
			message_admins("[key_name_admin(holder)] применил дефолтный лейаут лабиринта.")
			return TRUE

	return FALSE
