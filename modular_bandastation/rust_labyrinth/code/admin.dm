// ============================================================
// Rust-Forged Labyrinth — Admin verbs
// Uses ADMIN_VERB macro (SSadmin_verbs system).
// `user` = client who called the verb (не usr!).
// ============================================================

ADMIN_VERB(labyrinth_initialize, R_ADMIN, "Labyrinth: Initialize", "Создать Z-уровень лабиринта и инициализировать сетку 5x5.", ADMIN_CATEGORY_EVENTS)
	if(GLOB.rust_grid_manager.initialized)
		to_chat(user, span_warning("Лабиринт уже инициализирован (Z=[GLOB.rust_grid_manager.labyrinth_level?.z_value])."))
		return
	to_chat(user, span_notice("Инициализация Ржавого Лабиринта..."))
	if(GLOB.rust_grid_manager.initialize_labyrinth())
		to_chat(user, span_notice("Лабиринт создан на Z=[GLOB.rust_grid_manager.labyrinth_level.z_value]."))
	else
		to_chat(user, span_warning("Ошибка инициализации. Смотри server log."))

ADMIN_VERB(labyrinth_load_all, R_ADMIN, "Labyrinth: Load All Sectors", "Загрузить все зарегистрированные .dmm секторы.", ADMIN_CATEGORY_EVENTS)
	if(!GLOB.rust_grid_manager.initialized)
		to_chat(user, span_warning("Сначала выполни 'Labyrinth: Initialize'."))
		return
	to_chat(user, span_notice("Загружаю все зарегистрированные секторы..."))
	GLOB.rust_grid_manager.load_all_sectors()
	to_chat(user, span_notice("Готово."))

ADMIN_VERB(labyrinth_status, R_ADMIN, "Labyrinth: Status", "Показать состояние сетки секторов.", ADMIN_CATEGORY_EVENTS)
	if(!GLOB.rust_grid_manager.initialized)
		to_chat(user, span_warning("Лабиринт не инициализирован."))
		return
	var/datum/rust_grid_manager/mgr = GLOB.rust_grid_manager
	var/msg = "Ржавый Лабиринт — Z=[mgr.labyrinth_level.z_value]<br>"
	for(var/gx in 1 to LABYRINTH_GRID_SIZE)
		var/row = ""
		for(var/gy in 1 to LABYRINTH_GRID_SIZE)
			var/datum/rust_sector/S = mgr.sectors[LABYRINTH_GRID_INDEX(gx, gy)]
			switch(S.state)
				if(LABYRINTH_SECTOR_UNLOADED) row += "[S.grid_x],[S.grid_y]:EMPTY "
				if(LABYRINTH_SECTOR_LOADED)   row += "[S.grid_x],[S.grid_y]:LOADED "
				if(LABYRINTH_SECTOR_ACTIVE)   row += "[S.grid_x],[S.grid_y]:ACTIVE "
		msg += row + "<br>"
	to_chat(user, msg)

ADMIN_VERB(labyrinth_set_rust, R_ADMIN, "Labyrinth: Set Rust Level", "Установить уровень ржавчины (0–100) для сектора под ногами.", ADMIN_CATEGORY_EVENTS)
	if(!GLOB.rust_grid_manager.initialized)
		to_chat(user, span_warning("Лабиринт не инициализирован."))
		return
	var/datum/rust_sector/S = GLOB.rust_grid_manager.get_sector_at(get_turf(user.mob))
	if(!S)
		to_chat(user, span_warning("Ты не находишься в секторе лабиринта."))
		return
	var/new_level = input(user, "Уровень ржавчины (0–100):", "Rust Level", S.rust_level) as num|null
	if(isnull(new_level))
		return
	new_level = clamp(new_level, 0, 100)
	S.rust_level = new_level
	if(S.corrosion_controller)
		if(new_level > 0)
			S.corrosion_controller.start()
		else
			S.corrosion_controller.stop()
	to_chat(user, span_notice("Сектор ([S.grid_x],[S.grid_y]): rust_level → [new_level]."))

ADMIN_VERB(labyrinth_force_corrosion, R_ADMIN, "Labyrinth: Force Corrosion Sweep", "Запустить немедленный цикл коррозии для сектора под ногами.", ADMIN_CATEGORY_EVENTS)
	if(!GLOB.rust_grid_manager.initialized)
		to_chat(user, span_warning("Лабиринт не инициализирован."))
		return
	var/datum/rust_sector/S = GLOB.rust_grid_manager.get_sector_at(get_turf(user.mob))
	if(!S)
		to_chat(user, span_warning("Ты не находишься в секторе лабиринта."))
		return
	if(!S.corrosion_controller)
		to_chat(user, span_warning("В этом секторе нет Corrosion_Controller (сектор не загружен?)."))
		return
	to_chat(user, span_notice("Принудительный sweep коррозии для сектора ([S.grid_x],[S.grid_y])..."))
	S.corrosion_controller._sweep()

ADMIN_VERB(labyrinth_pulse_sector, R_ADMIN, "Labyrinth: Pulse Pistons Here", "Активировать все поршни в секторе под ногами.", ADMIN_CATEGORY_EVENTS)
	if(!GLOB.rust_grid_manager.initialized)
		to_chat(user, span_warning("Лабиринт не инициализирован."))
		return
	var/datum/rust_sector/S = GLOB.rust_grid_manager.get_sector_at(get_turf(user.mob))
	if(!S)
		to_chat(user, span_warning("Ты не находишься в секторе лабиринта."))
		return
	if(!S.sync_controller)
		to_chat(user, span_warning("В этом секторе нет Sync_Controller (сектор не загружен?)."))
		return
	to_chat(user, span_notice("Пульс поршней сектора ([S.grid_x],[S.grid_y])..."))
	S.sync_controller.pulse()

ADMIN_VERB(labyrinth_goto, R_ADMIN, "Labyrinth: Go To Labyrinth", "Телепортироваться на Z-уровень лабиринта (работает для призраков).", ADMIN_CATEGORY_EVENTS)
	if(!GLOB.rust_grid_manager.initialized)
		to_chat(user, span_warning("Лабиринт не инициализирован — сначала выполни 'Labyrinth: Initialize'."))
		return
	var/datum/rust_sector/S = GLOB.rust_grid_manager.sectors[1]
	if(!S?.anchor_turf)
		to_chat(user, span_warning("Нет anchor_turf. Выполни 'Labyrinth: Initialize'."))
		return
	user.mob.abstract_move(S.anchor_turf)
	to_chat(user, span_notice("Телепортирован в лабиринт (Z=[S.anchor_turf.z])."))

ADMIN_VERB(labyrinth_trigger_piston_here, R_ADMIN, "Labyrinth: Trigger Nearest Piston", "Активировать ближайший поршень (радиус 2 тайла).", ADMIN_CATEGORY_EVENTS)
	var/turf/T = get_turf(user.mob)
	var/obj/structure/labyrinth_hazard/piston/P
	for(var/obj/structure/labyrinth_hazard/piston/found in range(2, T))
		P = found
		break
	if(!P)
		to_chat(user, span_warning("Нет поршня в радиусе 2 тайлов."))
		return
	to_chat(user, span_notice("Активирую поршень на ([P.x],[P.y])..."))
	P.trigger()

ADMIN_VERB(labyrinth_setup_test_layout, R_ADMIN, "Labyrinth: Setup Test Layout", "Загрузить минимальный тестовый лейаут (5 секторов): FORGE→TRAP→CORRIDOR с боковыми коридорами.", ADMIN_CATEGORY_EVENTS)
	var/datum/rust_grid_manager/mgr = GLOB.rust_grid_manager
	if(!mgr.initialized)
		to_chat(user, span_warning("Сначала выполни 'Labyrinth: Initialize'."))
		return
	to_chat(user, span_notice("Регистрирую тестовый лейаут (5 секторов)..."))
	register_test_labyrinth_layout()
	to_chat(user, span_notice("Загружаю секторы..."))
	mgr.load_all_sectors()
	message_admins("[key_name_admin(user)] применил тестовый лейаут Ржавого Лабиринта.")
	log_admin("[key_name(user)] setup test labyrinth layout.")
	to_chat(user, span_notice("Готово — 5 секторов загружены. Иди на лабиринт ('Go To Labyrinth')."))
	BLACKBOX_LOG_ADMIN_VERB("Labyrinth Setup Test Layout")

ADMIN_VERB(labyrinth_setup_default_layout, R_ADMIN, "Labyrinth: Setup Default Layout", "Зарегистрировать дефолтный 5×5 лейаут и загрузить все секторы процедурно.", ADMIN_CATEGORY_EVENTS)
	var/datum/rust_grid_manager/mgr = GLOB.rust_grid_manager
	if(!mgr.initialized)
		to_chat(user, span_warning("Сначала выполни 'Labyrinth: Initialize'."))
		return
	to_chat(user, span_notice("Регистрирую дефолтный лейаут..."))
	register_default_labyrinth_layout()
	to_chat(user, span_notice("Загружаю все секторы процедурно..."))
	mgr.load_all_sectors()
	message_admins("[key_name_admin(user)] применил дефолтный лейаут Ржавого Лабиринта.")
	log_admin("[key_name(user)] setup default labyrinth layout.")
	to_chat(user, span_notice("Готово — 25 секторов загружены."))
	BLACKBOX_LOG_ADMIN_VERB("Labyrinth Setup Default Layout")
