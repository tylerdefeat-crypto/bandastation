// ============================================================
// Rust-Forged Labyrinth — Grid Manager
// Manages the 5×5 sector grid and runtime DMM loading.
// ============================================================

GLOBAL_DATUM_INIT(rust_grid_manager, /datum/rust_grid_manager, new)

/datum/rust_grid_manager
	/// The dedicated Z-level the labyrinth lives on.
	var/datum/space_level/labyrinth_level
	/// Flat list of /datum/rust_sector, indexed via LABYRINTH_GRID_INDEX(gx, gy).
	var/list/sectors = list()
	/// TRUE once initialize_labyrinth() has completed successfully.
	var/initialized = FALSE

/datum/rust_grid_manager/New()
	_populate_sector_registry()

/// Pre-fill the 25 sector slots so indices are always valid.
/datum/rust_grid_manager/proc/_populate_sector_registry()
	for(var/i in 1 to LABYRINTH_GRID_SIZE * LABYRINTH_GRID_SIZE)
		sectors += new /datum/rust_sector()
	for(var/gx in 1 to LABYRINTH_GRID_SIZE)
		for(var/gy in 1 to LABYRINTH_GRID_SIZE)
			var/datum/rust_sector/S = sectors[LABYRINTH_GRID_INDEX(gx, gy)]
			S.grid_x = gx
			S.grid_y = gy

// ------------------------------------------------------------------
// Public API
// ------------------------------------------------------------------

/**
 * Creates the labyrinth Z-level and assigns anchor turfs to each sector.
 * Call this from an admin verb or event proc — not at world start.
 * Returns TRUE on success.
 */
/datum/rust_grid_manager/proc/initialize_labyrinth()
	if(initialized)
		return FALSE

	labyrinth_level = SSmapping.add_new_zlevel(
		"Rust-Forged Labyrinth",
		ZTRAITS_AWAY_SECRET,
	)
	if(!labyrinth_level)
		CRASH("rust_grid_manager: failed to create labyrinth Z-level")

	var/z = labyrinth_level.z_value
	for(var/gx in 1 to LABYRINTH_GRID_SIZE)
		for(var/gy in 1 to LABYRINTH_GRID_SIZE)
			var/datum/rust_sector/S = sectors[LABYRINTH_GRID_INDEX(gx, gy)]
			S.anchor_turf = locate(
				1 + (gx - 1) * LABYRINTH_SECTOR_WIDTH,
				1 + (gy - 1) * LABYRINTH_SECTOR_HEIGHT,
				z,
			)

	initialized = TRUE
	log_game("rust_grid_manager: labyrinth initialized on Z=[z]")
	return TRUE

/**
 * Register metadata for a sector before the labyrinth is loaded.
 * mappath must be a path inside modular_bandastation/rust_labyrinth/maps/.
 */
/datum/rust_grid_manager/proc/register_sector(grid_x, grid_y, sector_type, mappath, rust_level = 0)
	if(!_in_bounds(grid_x, grid_y))
		return FALSE
	var/datum/rust_sector/S = sectors[LABYRINTH_GRID_INDEX(grid_x, grid_y)]
	S.sector_type = sector_type
	S.mappath     = mappath
	S.rust_level  = rust_level
	S.registered  = TRUE
	return TRUE

/**
 * Loads the DMM for a single sector at runtime.
 * Safe to call after initialize_labyrinth().
 * Returns TRUE on success.
 */
/datum/rust_grid_manager/proc/load_sector(grid_x, grid_y)
	if(!initialized)
		return FALSE
	if(!_in_bounds(grid_x, grid_y))
		return FALSE

	var/datum/rust_sector/S = sectors[LABYRINTH_GRID_INDEX(grid_x, grid_y)]
	if(!S.registered)
		return FALSE
	if(S.state != LABYRINTH_SECTOR_UNLOADED)
		return FALSE
	if(!S.anchor_turf)
		return FALSE

	if(S.mappath)
		// Загружаем DMM-шаблон
		var/datum/map_template/rust_sector_template/tmpl = new(S.mappath)
		var/list/bounds = tmpl.load(S.anchor_turf)
		if(!bounds)
			stack_trace("rust_grid_manager: failed to load sector ([grid_x],[grid_y]) from [S.mappath]")
			return FALSE
		S.state = LABYRINTH_SECTOR_LOADED
		S.on_loaded(bounds)
		log_game("rust_grid_manager: sector ([grid_x],[grid_y]) loaded from [S.mappath]")
	else
		// Нет DMM — генерируем геометрию процедурно
		S.state = LABYRINTH_SECTOR_LOADED
		S.on_loaded(null)
		generate_sector_geometry(S)
		log_game("rust_grid_manager: sector ([grid_x],[grid_y]) generated procedurally")

	// Автоприменяем дефолтный content module после того, как геометрия готова.
	var/datum/labyrinth_content_module/M = S._default_content_module()
	if(M)
		S.apply_content_module(M)

	SEND_SIGNAL(src, COMSIG_LABYRINTH_SECTOR_LOADED, S)
	return TRUE

/// Load every sector that has a mappath registered. Used for admin/debug full-init.
/datum/rust_grid_manager/proc/load_all_sectors()
	for(var/gx in 1 to LABYRINTH_GRID_SIZE)
		for(var/gy in 1 to LABYRINTH_GRID_SIZE)
			load_sector(gx, gy)
			CHECK_TICK

// ------------------------------------------------------------------
// Lookup helpers
// ------------------------------------------------------------------

/// Returns the /datum/rust_sector that contains world-turf T, or null.
/datum/rust_grid_manager/proc/get_sector_at(turf/T)
	if(!initialized || !labyrinth_level)
		return null
	if(T.z != labyrinth_level.z_value)
		return null
	var/gx = ceil(T.x / LABYRINTH_SECTOR_WIDTH)
	var/gy = ceil(T.y / LABYRINTH_SECTOR_HEIGHT)
	if(!_in_bounds(gx, gy))
		return null
	return sectors[LABYRINTH_GRID_INDEX(gx, gy)]

/// Returns a list of up to 4 cardinal neighbours of the given sector.
/datum/rust_grid_manager/proc/get_neighboring_sectors(datum/rust_sector/S)
	var/list/result = list()
	for(var/delta in list(list(1,0), list(-1,0), list(0,1), list(0,-1)))
		var/nx = S.grid_x + delta[1]
		var/ny = S.grid_y + delta[2]
		if(_in_bounds(nx, ny))
			result += sectors[LABYRINTH_GRID_INDEX(nx, ny)]
	return result

/datum/rust_grid_manager/proc/_in_bounds(gx, gy)
	return (gx >= 1 && gx <= LABYRINTH_GRID_SIZE && gy >= 1 && gy <= LABYRINTH_GRID_SIZE)

// ------------------------------------------------------------------
// /datum/rust_sector — per-cell metadata and state
// ------------------------------------------------------------------

/datum/rust_sector
	/// LABYRINTH_SECTOR_* type constant
	var/sector_type = LABYRINTH_SECTOR_EMPTY
	/// LABYRINTH_SECTOR_UNLOADED / LOADED / ACTIVE
	var/state = LABYRINTH_SECTOR_UNLOADED
	/// TRUE once register_sector() has been called for this slot.
	var/registered = FALSE
	/// Path to the .dmm inside modular_bandastation/rust_labyrinth/maps/
	var/mappath
	/// Grid coordinates (1-based)
	var/grid_x = 0
	var/grid_y = 0
	/// Top-left world turf of this sector's area.
	var/turf/anchor_turf
	/// Corrosion intensity: 0–100. Drives /datum/corrosion_controller behavior.
	var/rust_level = 0
	/// Turfs that act as entry/exit connections to adjacent sectors.
	var/list/connection_turfs = list()
	/// Sync_Controller that owns all pistons in this sector.
	var/datum/sync_controller/sync_controller
	/// Corrosion_Controller that degrades items/structures in this sector.
	var/datum/corrosion_controller/corrosion_controller
	/// The /area/awaymission/rust_labyrinth/* instance assigned to this sector's turfs after load.
	var/area/awaymission/rust_labyrinth/zone_area
	/// Текущий content module, применённый к сектору (null — пусто)
	var/datum/labyrinth_content_module/applied_module
	/// Wiring: assoc list channel(string) → list(responders). Links pressure
	/// plates / terminals to hazards & puzzles. See code/wiring.dm.
	var/list/wiring = list()
	/// Active puzzle bound to this sector (null — none). See code/puzzles/.
	var/datum/labyrinth_puzzle/active_puzzle
	/// Controllable doors in this sector (auto-registered). See labyrinth_door.dm.
	var/list/obj/structure/labyrinth_door/doors = list()

/// Called by grid_manager after the DMM loads. Override in subtypes for post-load setup.
/datum/rust_sector/proc/on_loaded(list/bounds)
	sync_controller = new /datum/sync_controller()
	corrosion_controller = new /datum/corrosion_controller(src)
	if(rust_level > 0)
		corrosion_controller.start()
	zone_area = _make_zone_area()
	if(zone_area)
		set_turfs_to_area(get_turfs(), zone_area)

/// Returns a fresh area instance of the correct subtype for this sector's sector_type.
/datum/rust_sector/proc/_make_zone_area()
	switch(sector_type)
		if(LABYRINTH_SECTOR_CORRIDOR)
			return new /area/awaymission/rust_labyrinth/corridor()
		if(LABYRINTH_SECTOR_TRAP)
			return new /area/awaymission/rust_labyrinth/trap_zone()
		if(LABYRINTH_SECTOR_FORGE)
			return new /area/awaymission/rust_labyrinth/forge()
		if(LABYRINTH_SECTOR_BOSS)
			return new /area/awaymission/rust_labyrinth/boss()
		if(LABYRINTH_SECTOR_EMPTY)
			return new /area/awaymission/rust_labyrinth/transition()
	return new /area/awaymission/rust_labyrinth()

/// Возвращает дефолтный content module для типа сектора, или null.
/datum/rust_sector/proc/_default_content_module()
	switch(sector_type)
		if(LABYRINTH_SECTOR_TRAP)
			return new /datum/labyrinth_content_module/piston_trap()
		if(LABYRINTH_SECTOR_FORGE)
			return new /datum/labyrinth_content_module/forge_decor()
		if(LABYRINTH_SECTOR_CORRIDOR, LABYRINTH_SECTOR_BOSS, LABYRINTH_SECTOR_EMPTY)
			return new /datum/labyrinth_content_module/horror_ambience()
	return null

/// Применяет content module к сектору (заменяет предыдущий если есть).
/datum/rust_sector/proc/apply_content_module(datum/labyrinth_content_module/M)
	if(applied_module)
		clear_content_module()
	applied_module = M
	M.apply(src)

/// Очищает текущий content module — удаляет все spawned объекты.
/datum/rust_sector/proc/clear_content_module()
	if(!applied_module)
		return
	applied_module.clear()
	qdel(applied_module)
	applied_module = null

/// Привязывает головоломку к сектору (заменяет предыдущую если есть).
/datum/rust_sector/proc/attach_puzzle(datum/labyrinth_puzzle/P)
	if(active_puzzle)
		clear_puzzle()
	active_puzzle = P
	P.setup(src)

/// Удаляет текущую головоломку.
/datum/rust_sector/proc/clear_puzzle()
	if(!active_puzzle)
		return
	qdel(active_puzzle)
	active_puzzle = null

/// Returns all turfs belonging to this sector via block().
/datum/rust_sector/proc/get_turfs()
	if(!anchor_turf)
		return list()
	return block(
		anchor_turf.x,
		anchor_turf.y,
		anchor_turf.z,
		anchor_turf.x + LABYRINTH_SECTOR_WIDTH - 1,
		anchor_turf.y + LABYRINTH_SECTOR_HEIGHT - 1,
		anchor_turf.z,
	)

// ------------------------------------------------------------------
// /datum/map_template subtype — cached sector loader
// ------------------------------------------------------------------

/datum/map_template/rust_sector_template
	keep_cached_map = TRUE
	should_place_on_top = TRUE
	has_ceiling = FALSE
