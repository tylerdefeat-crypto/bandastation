// ============================================================
// Rust-Forged Labyrinth — Content Module: Piston Trap (Phase D2)
//
// Расставляет поршни в секторах типа TRAP/CORRIDOR.
// Паттерн: N рядов навстречу (EW или NS), случайное число рядов.
// Поршни самостоятельно регистрируются в sync_controller сектора
// через piston/Initialize() → get_sector_at() → register_piston().
// ============================================================

/datum/labyrinth_content_module/piston_trap
	module_name = "piston_trap"

	/// PISTON_ORIENT_EW или PISTON_ORIENT_NS — задаётся при apply()
	var/orientation = PISTON_ORIENT_EW
	/// Количество рядов (3–5, рандом)
	var/row_count = 3

/datum/labyrinth_content_module/piston_trap/apply(datum/rust_sector/S)
	. = ..()
	if(!S.anchor_turf)
		return

	orientation = pick(PISTON_ORIENT_EW, PISTON_ORIENT_NS)
	row_count    = rand(3, 5)

	var/ax = S.anchor_turf.x
	var/ay = S.anchor_turf.y
	var/az = S.anchor_turf.z
	var/W  = LABYRINTH_SECTOR_WIDTH   // 46
	var/H  = LABYRINTH_SECTOR_HEIGHT  // 46

	if(orientation == PISTON_ORIENT_EW)
		// Ряды горизонтальные (по Y), поршни толкают EAST ↔ WEST
		for(var/r in 1 to row_count)
			var/row_y = ay + round(H * r / (row_count + 1))

			// Западный — смотрит EAST (толкает вправо)
			var/turf/west_t = locate(ax + 2, row_y, az)
			if(west_t)
				var/obj/structure/labyrinth_hazard/piston/P = new(west_t)
				P.dir = EAST
				_track(P)

			// Восточный — смотрит WEST (толкает влево)
			var/turf/east_t = locate(ax + W - 3, row_y, az)
			if(east_t)
				var/obj/structure/labyrinth_hazard/piston/P2 = new(east_t)
				P2.dir = WEST
				_track(P2)

			// С вероятностью 40% — дополнительный поршень в центре ряда
			if(prob(40))
				var/mid_x = ax + round(W / 2) + rand(-3, 3)
				var/turf/mid_t = locate(mid_x, row_y, az)
				if(mid_t)
					var/obj/structure/labyrinth_hazard/piston/Pm = new(mid_t)
					Pm.dir = pick(EAST, WEST)
					_track(Pm)
	else
		// Ряды вертикальные (по X), поршни толкают NORTH ↔ SOUTH
		for(var/r in 1 to row_count)
			var/col_x = ax + round(W * r / (row_count + 1))

			// Южный — смотрит NORTH
			var/turf/south_t = locate(col_x, ay + 2, az)
			if(south_t)
				var/obj/structure/labyrinth_hazard/piston/P = new(south_t)
				P.dir = NORTH
				_track(P)

			// Северный — смотрит SOUTH
			var/turf/north_t = locate(col_x, ay + H - 3, az)
			if(north_t)
				var/obj/structure/labyrinth_hazard/piston/P2 = new(north_t)
				P2.dir = SOUTH
				_track(P2)

			if(prob(40))
				var/mid_y = ay + round(H / 2) + rand(-3, 3)
				var/turf/mid_t = locate(col_x, mid_y, az)
				if(mid_t)
					var/obj/structure/labyrinth_hazard/piston/Pm = new(mid_t)
					Pm.dir = pick(NORTH, SOUTH)
					_track(Pm)
