// ============================================================
// Rust-Forged Labyrinth — Procedural Sector Generator (Phase E)
//
// Генерирует геометрию сектора во время раунда через ChangeTurf().
// Используется когда у сектора нет зарегистрированного .dmm.
//
// Результат: стены по периметру, пол внутри, проходы (3 тайла)
// по каждому кардинальному направлению у соседних секторов.
//
// Когда будут готовы реальные DMM-шаблоны — просто зарегистрируй
// mappath через register_sector() и генератор перестанет вызываться.
// ============================================================

/// Заполняет сектор S базовой геометрией (стены + пол + проходы).
/// Вызывается из load_sector() когда mappath == null.
/proc/generate_sector_geometry(datum/rust_sector/S)
	if(!S.anchor_turf)
		return FALSE

	var/ax = S.anchor_turf.x
	var/ay = S.anchor_turf.y
	var/az = S.anchor_turf.z
	var/W  = LABYRINTH_SECTOR_WIDTH   // 46
	var/H  = LABYRINTH_SECTOR_HEIGHT  // 46

	// --- Заполняем тайлы ---
	for(var/x in ax to ax + W - 1)
		for(var/y in ay to ay + H - 1)
			var/turf/T = locate(x, y, az)
			if(!T)
				continue
			var/is_border = (x == ax || x == ax + W - 1 || y == ay || y == ay + H - 1)
			if(is_border)
				T.ChangeTurf(/turf/closed/indestructible/reinforced)
			else
				T.ChangeTurf(/turf/open/floor/iron/dark)
			CHECK_TICK

	// --- Проходы в кардинальных направлениях ---
	// Проход открывается только если у сектора есть загруженный/зарегистрированный сосед.
	var/datum/rust_grid_manager/mgr = GLOB.rust_grid_manager
	var/list/neighbors = mgr.get_neighboring_sectors(S)
	var/list/neighbor_dirs = list()
	for(var/datum/rust_sector/N as anything in neighbors)
		if(!N.registered)
			continue  // не открываем проход в незарегистрированный сектор (космос)
		if(N.grid_x > S.grid_x) neighbor_dirs |= EAST
		if(N.grid_x < S.grid_x) neighbor_dirs |= WEST
		if(N.grid_y > S.grid_y) neighbor_dirs |= NORTH
		if(N.grid_y < S.grid_y) neighbor_dirs |= SOUTH

	// Открываем проходы (3 тайла шириной у каждого соседа).
	// EAST/WEST — граница по X, проход по Y (wall_x=граница, wall_y=середина).
	// NORTH/SOUTH — граница по Y, проход по X (wall_x=середина, wall_y=граница).
	var/mx = ax + round(W / 2)
	var/my = ay + round(H / 2)
	if(EAST  & neighbor_dirs) _open_passage(ax + W - 1, my,         az, EAST,  3)
	if(WEST  & neighbor_dirs) _open_passage(ax,         my,         az, WEST,  3)
	if(NORTH & neighbor_dirs) _open_passage(mx,         ay + H - 1, az, NORTH, 3)
	if(SOUTH & neighbor_dirs) _open_passage(mx,         ay,         az, SOUTH, 3)

	return TRUE

/// Открывает проход шириной [width] тайлов посередине указанной стены.
/// dir указывает ось (NORTH/SOUTH = вертикальная граница, EAST/WEST = горизонтальная).
/proc/_open_passage(wall_x, wall_y, wall_z, dir, width)
	var/half = round(width / 2)
	switch(dir)
		if(NORTH, SOUTH)
			// Граница по Y=wall_y, проход по X
			for(var/dx in -half to half)
				var/turf/T = locate(wall_x + dx, wall_y, wall_z)
				if(T)
					T.ChangeTurf(/turf/open/floor/iron/dark)
		if(EAST, WEST)
			// Граница по X=wall_x, проход по Y
			for(var/dy in -half to half)
				var/turf/T = locate(wall_x, wall_y + dy, wall_z)
				if(T)
					T.ChangeTurf(/turf/open/floor/iron/dark)
