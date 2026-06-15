// ============================================================
// Rust-Forged Labyrinth — Content Module System (Phase D1)
//
// /datum/labyrinth_content_module — базовый тип.
// Конкретные подтипы определяют, что именно спавнится в секторе.
// apply(S) — расставить объекты; clear() — удалить все spawned.
// ============================================================

/datum/labyrinth_content_module
	/// Человекочитаемое имя модуля (для TGUI и логов)
	var/module_name = "base"
	/// Все атомы, созданные этим модулем
	var/list/spawned = list()
	/// Сектор, к которому сейчас применён модуль (null если clear())
	var/datum/rust_sector/owner_sector

// ------------------------------------------------------------------
// API
// ------------------------------------------------------------------

/// Применяет контент к сектору. Override в подтипах.
/// Вызывается из rust_sector.apply_content_module().
/datum/labyrinth_content_module/proc/apply(datum/rust_sector/S)
	owner_sector = S

/// Удаляет все созданные объекты.
/datum/labyrinth_content_module/proc/clear()
	for(var/atom/A as anything in spawned)
		if(!QDELETED(A))
			qdel(A)
	spawned.Cut()
	owner_sector = null

/datum/labyrinth_content_module/Destroy()
	clear()
	return ..()

// ------------------------------------------------------------------
// Helpers для подтипов
// ------------------------------------------------------------------

/// Создаёт объект типа T на тайле T и регистрирует его.
/datum/labyrinth_content_module/proc/_new(atom/movable/T, turf/location)
	var/atom/movable/A = new T(location)
	spawned += A
	return A

/// Регистрирует уже созданный объект (для случаев ручного new).
/datum/labyrinth_content_module/proc/_track(atom/A)
	spawned += A
	return A

/// Возвращает случайный тайл внутри сектора, не у самого края.
/// margin — отступ от края сектора в тайлах.
/datum/labyrinth_content_module/proc/_rand_turf(datum/rust_sector/S, margin = 2)
	if(!S.anchor_turf)
		return null
	var/ax = S.anchor_turf.x + margin
	var/ay = S.anchor_turf.y + margin
	var/bx = S.anchor_turf.x + LABYRINTH_SECTOR_WIDTH  - 1 - margin
	var/by = S.anchor_turf.y + LABYRINTH_SECTOR_HEIGHT - 1 - margin
	if(ax > bx || ay > by)
		return null
	return locate(rand(ax, bx), rand(ay, by), S.anchor_turf.z)

/// Возвращает конкретный тайл (ox, oy) относительно anchor_turf сектора.
/datum/labyrinth_content_module/proc/_sector_turf(datum/rust_sector/S, ox, oy)
	if(!S.anchor_turf)
		return null
	return locate(S.anchor_turf.x + ox, S.anchor_turf.y + oy, S.anchor_turf.z)
