// ============================================================
// Rust-Forged Labyrinth — Content Module: Forge Decor (Phase D2)
//
// Применяется к FORGE-секторам. Спавнит:
//   — forge_station (якорь квеста) в центре
//   — кузнечный хлам: girder'ы, цепи, кровь, ржавые инструменты
//
// Кастомные объекты /obj/structure/forge_chain и
// /obj/structure/hanging_chain определены здесь же.
// ============================================================

// ============================================================
// Объекты-декор (определяем прямо в этом файле)
// ============================================================

/obj/structure/forge_chain
	name = "heavy chain"
	desc = "Thick iron links, dark with rust and old grease. Something was once held here."
	icon = 'icons/obj/structures.dmi'
	icon_state = "grille"      // placeholder — заменить на chainlink-спрайт
	density = FALSE
	anchored = TRUE
	max_integrity = 300
	armor_type = /datum/armor/structure_forge_chain

/datum/armor/structure_forge_chain
	melee = 50
	fire = 100
	acid = 30

/obj/structure/forge_chain/hanging
	name = "hanging chain"
	desc = "Chains suspended from the ceiling. They sway slightly, though there is no wind."
	layer = ABOVE_MOB_LAYER
	plane = ABOVE_GAME_PLANE

// ============================================================
// Модуль
// ============================================================

/datum/labyrinth_content_module/forge_decor
	module_name = "forge_decor"

/datum/labyrinth_content_module/forge_decor/apply(datum/rust_sector/S)
	. = ..()
	if(!S.anchor_turf)
		return

	var/ax = S.anchor_turf.x
	var/ay = S.anchor_turf.y
	var/az = S.anchor_turf.z
	var/cx = ax + round(LABYRINTH_SECTOR_WIDTH  / 2)
	var/cy = ay + round(LABYRINTH_SECTOR_HEIGHT / 2)

	// --- Forge Station в центре сектора ---
	var/turf/center = locate(cx, cy, az)
	if(center)
		_track(new /obj/structure/forge_station(center))

	// --- Рассыпанные балки (girder) ---
	var/girder_count = rand(4, 7)
	for(var/i in 1 to girder_count)
		var/turf/T = _rand_turf(S, 3)
		if(T)
			var/obj/structure/girder/G = new(T)
			G.anchored = TRUE
			_track(G)

	// --- Тяжёлые цепи на полу ---
	var/chain_count = rand(3, 6)
	for(var/i in 1 to chain_count)
		var/turf/T = _rand_turf(S, 2)
		if(T)
			_new(/obj/structure/forge_chain, T)

	// --- Ржавые кирки ---
	var/pick_count = rand(2, 4)
	for(var/i in 1 to pick_count)
		var/turf/T = _rand_turf(S, 2)
		if(T)
			_new(/obj/item/pickaxe/rusted, T)

	// --- Кровавые пятна (тяжёлые следы работ) ---
	var/blood_count = rand(3, 7)
	for(var/i in 1 to blood_count)
		var/turf/T = _rand_turf(S, 1)
		if(T)
			_new(/obj/effect/decal/cleanable/blood, T)

	// --- Листы металла (лом) ---
	var/scrap_count = rand(2, 5)
	for(var/i in 1 to scrap_count)
		var/turf/T = _rand_turf(S, 2)
		if(T)
			_new(/obj/item/stack/sheet/iron, T)

	// --- Подвешенные цепи вокруг центра (декор на верхнем слое) ---
	var/offsets = list(
		list(-3, -3), list(0, -4), list(3, -3),
		list(-4, 0),               list(4, 0),
		list(-3,  3), list(0,  4), list(3,  3),
	)
	for(var/pair as anything in offsets)
		if(prob(60))
			var/turf/T = locate(cx + pair[1], cy + pair[2], az)
			if(T)
				_new(/obj/structure/forge_chain/hanging, T)
