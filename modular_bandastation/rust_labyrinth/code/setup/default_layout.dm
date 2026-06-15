// ============================================================
// Rust-Forged Labyrinth — Default 5×5 Layout (Phase E)
//
// Кольцевая структура «Куб» под 40 игроков (4 группы по 10).
// register_default_layout() регистрирует все 25 секторов.
//
// Координатная система: gx=1 — левый, gy=1 — нижний.
// Визуальная схема (gy убывает сверху вниз):
//
//   gy↑
//   5│ COR  TRP  GТ↓  TRP  COR
//   4│ TRP  COR  GI   COR  TRP
//   3│ GТ→ GI   BOSS GI   GТ←
//   2│ TRP  COR  GI   COR  TRP
//   1│ COR  TRP  GТ↑  TRP  COR
//      └─────────────────────── gx→
//         1    2    3    4    5
//
//   COR  — статичный угол-перекрёсток. Ловушек НЕТ: точки сбора/регруппировки.
//   TRP  — активная комната (ловушки + головоломки).
//   GТ   — внешний «гейт» (середина ребра): проход во внутреннее кольцо.
//   GI   — внутренний «гейт»: примыкает к центру, последняя головоломка к боссу.
//   BOSS — центр (3,3): все группы сходятся здесь.
//
// КОЛЬЦА:
//   Центр   (3,3)                                  = BOSS
//   Внутр.  (2,2)(3,2)(4,2)(2,3)(4,3)(2,4)(3,4)(4,4) — углы статичны, середины GI
//   Внешнее периметр                                — углы статичны, рёбра активны
//
// МАРШРУТ (по часовой, каждая группа = одно ребро, 3 активные комнаты):
//   A: (1,1)→(1,2)→(1,3)GТ→(1,4)→(1,5)
//   B: (1,5)→(2,5)→(3,5)GТ→(4,5)→(5,5)
//   C: (5,5)→(5,4)→(5,3)GТ→(5,2)→(5,1)
//   D: (5,1)→(4,1)→(3,1)GТ→(2,1)→(1,1)
//   Внешние гейты (3,1)(1,3)(5,3)(3,5) — единственные спуски во внутреннее кольцо
//   (адъяcентность по кресту, не по диагонали). Из внутреннего кольца один шаг
//   против часовой к GI → переход в центр к боссу.
//
// Углы (4 внешних + 4 внутренних = 8 COR) ВСЕГДА статичны — без ловушек.
// ============================================================

/// Список конфигов секторов: list(gx, gy, type, mappath, rust_level)
/// Порядок совпадает с register_sector(gx, gy, sector_type, mappath, rust_level).
var/static/list/LABYRINTH_DEFAULT_LAYOUT = list(
	// gy=1 (нижний ряд) — внешние углы (1,1)(5,1) статичны, (3,1) внешний гейт
	list(1, 1, LABYRINTH_SECTOR_CORRIDOR,   'modular_bandastation/rust_labyrinth/maps/test_corridor.dmm',    0),
	list(2, 1, LABYRINTH_SECTOR_TRAP,       'modular_bandastation/rust_labyrinth/maps/test_trap.dmm',       50),
	list(3, 1, LABYRINTH_SECTOR_TRAP,       'modular_bandastation/rust_labyrinth/maps/test_trap.dmm',       60),
	list(4, 1, LABYRINTH_SECTOR_TRAP,       'modular_bandastation/rust_labyrinth/maps/test_trap.dmm',       50),
	list(5, 1, LABYRINTH_SECTOR_CORRIDOR,   'modular_bandastation/rust_labyrinth/maps/test_corridor.dmm',    0),
	// gy=2 — внутренние углы (2,2)(4,2) статичны, (3,2) внутренний гейт к центру
	list(1, 2, LABYRINTH_SECTOR_TRAP,       'modular_bandastation/rust_labyrinth/maps/test_trap.dmm',       50),
	list(2, 2, LABYRINTH_SECTOR_CORRIDOR,   'modular_bandastation/rust_labyrinth/maps/test_corridor.dmm',    0),
	list(3, 2, LABYRINTH_SECTOR_TRAP,       'modular_bandastation/rust_labyrinth/maps/test_trap.dmm',       75),
	list(4, 2, LABYRINTH_SECTOR_CORRIDOR,   'modular_bandastation/rust_labyrinth/maps/test_corridor.dmm',    0),
	list(5, 2, LABYRINTH_SECTOR_TRAP,       'modular_bandastation/rust_labyrinth/maps/test_trap.dmm',       50),
	// gy=3 — внешние гейты (1,3)(5,3), внутренние гейты (2,3)(4,3), центр (3,3) BOSS
	list(1, 3, LABYRINTH_SECTOR_TRAP,       'modular_bandastation/rust_labyrinth/maps/test_trap.dmm',       60),
	list(2, 3, LABYRINTH_SECTOR_TRAP,       'modular_bandastation/rust_labyrinth/maps/test_trap.dmm',       75),
	list(3, 3, LABYRINTH_SECTOR_BOSS,       'modular_bandastation/rust_labyrinth/maps/test_boss.dmm',       90),
	list(4, 3, LABYRINTH_SECTOR_TRAP,       'modular_bandastation/rust_labyrinth/maps/test_trap.dmm',       75),
	list(5, 3, LABYRINTH_SECTOR_TRAP,       'modular_bandastation/rust_labyrinth/maps/test_trap.dmm',       60),
	// gy=4 — внутренние углы (2,4)(4,4) статичны, (3,4) внутренний гейт к центру
	list(1, 4, LABYRINTH_SECTOR_TRAP,       'modular_bandastation/rust_labyrinth/maps/test_trap.dmm',       50),
	list(2, 4, LABYRINTH_SECTOR_CORRIDOR,   'modular_bandastation/rust_labyrinth/maps/test_corridor.dmm',    0),
	list(3, 4, LABYRINTH_SECTOR_TRAP,       'modular_bandastation/rust_labyrinth/maps/test_trap.dmm',       75),
	list(4, 4, LABYRINTH_SECTOR_CORRIDOR,   'modular_bandastation/rust_labyrinth/maps/test_corridor.dmm',    0),
	list(5, 4, LABYRINTH_SECTOR_TRAP,       'modular_bandastation/rust_labyrinth/maps/test_trap.dmm',       50),
	// gy=5 (верхний ряд) — внешние углы (1,5)(5,5) статичны, (3,5) внешний гейт
	list(1, 5, LABYRINTH_SECTOR_CORRIDOR,   'modular_bandastation/rust_labyrinth/maps/test_corridor.dmm',    0),
	list(2, 5, LABYRINTH_SECTOR_TRAP,       'modular_bandastation/rust_labyrinth/maps/test_trap.dmm',       50),
	list(3, 5, LABYRINTH_SECTOR_TRAP,       'modular_bandastation/rust_labyrinth/maps/test_trap.dmm',       60),
	list(4, 5, LABYRINTH_SECTOR_TRAP,       'modular_bandastation/rust_labyrinth/maps/test_trap.dmm',       50),
	list(5, 5, LABYRINTH_SECTOR_CORRIDOR,   'modular_bandastation/rust_labyrinth/maps/test_corridor.dmm',    0),
)

/// Пул DMM-кусков по типу сектора. Маппер кладёт свои карты сюда; на старте
/// каждый слот берёт СЛУЧАЙНУЮ карту из пула своего типа — позиции типов
/// (кольца) фиксированы, рандомится только геометрия внутри типа.
/// Пустой/отсутствующий пул → mappath = null → процедурная геометрия (fallback).
GLOBAL_LIST_INIT(labyrinth_sector_pools, list(
	"[LABYRINTH_SECTOR_CORRIDOR]" = list(
		'modular_bandastation/rust_labyrinth/maps/test_corridor.dmm',
	),
	"[LABYRINTH_SECTOR_TRAP]" = list(
		'modular_bandastation/rust_labyrinth/maps/test_trap.dmm',
		'modular_bandastation/rust_labyrinth/maps/test_puzzle.dmm',
	),
	"[LABYRINTH_SECTOR_FORGE]" = list(
		'modular_bandastation/rust_labyrinth/maps/test_forge.dmm',
	),
	"[LABYRINTH_SECTOR_BOSS]" = list(
		'modular_bandastation/rust_labyrinth/maps/test_boss.dmm',
	),
	"[LABYRINTH_SECTOR_EMPTY]" = list(
		'modular_bandastation/rust_labyrinth/maps/test_transition.dmm',
	),
))

/// Случайный DMM из пула для данного типа сектора, или null если пул пуст.
/proc/labyrinth_pick_sector_map(sector_type)
	var/list/pool = GLOB.labyrinth_sector_pools["[sector_type]"]
	if(!length(pool))
		return null
	return pick(pool)

/// Регистрирует дефолтный лейаут: типы фиксированы, карта на каждый слот —
/// случайная из пула своего типа. Вызывается из round-start хука и
/// ADMIN_VERB "Labyrinth: Setup Default Layout".
/proc/register_default_labyrinth_layout()
	var/datum/rust_grid_manager/mgr = GLOB.rust_grid_manager
	for(var/list/cfg as anything in LABYRINTH_DEFAULT_LAYOUT)
		// cfg = list(gx, gy, type, mappath, rust_level) — cfg[4] игнорируется,
		// карта выбирается случайно из пула типа cfg[3].
		mgr.register_sector(cfg[1], cfg[2], cfg[3], labyrinth_pick_sector_map(cfg[3]), cfg[5])

// ============================================================
// Тестовый минимальный лейаут (5 секторов, центральная колонна)
//
//   gy↑
//   3│ COR
//   2│ TRAP   ← поршни
//   1│ FORGE  ← кузница
//      └── gx=3
//
// + два коридора слева и справа от TRAP для проверки проходов.
//
// Игрок попадает через FORGE (3,1), поднимается в TRAP (3,2) и выход — COR (3,3).
// Два CORRIDOR (2,2)(4,2) примыкают к TRAP с боков.
// ============================================================
/proc/register_test_labyrinth_layout()
	var/datum/rust_grid_manager/mgr = GLOB.rust_grid_manager
	// Центральная вертикальная цепочка
	mgr.register_sector(3, 1, LABYRINTH_SECTOR_FORGE,    'modular_bandastation/rust_labyrinth/maps/test_forge.dmm',    60)
	mgr.register_sector(3, 2, LABYRINTH_SECTOR_TRAP,     'modular_bandastation/rust_labyrinth/maps/test_trap.dmm',     70)
	mgr.register_sector(3, 3, LABYRINTH_SECTOR_CORRIDOR, 'modular_bandastation/rust_labyrinth/maps/test_corridor.dmm', 30)
	// Боковые коридоры у TRAP
	mgr.register_sector(2, 2, LABYRINTH_SECTOR_CORRIDOR, 'modular_bandastation/rust_labyrinth/maps/test_corridor.dmm', 40)
	mgr.register_sector(4, 2, LABYRINTH_SECTOR_CORRIDOR, 'modular_bandastation/rust_labyrinth/maps/test_corridor.dmm', 40)
