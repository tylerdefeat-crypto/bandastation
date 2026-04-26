/*
    ПАМЯТКА ПО СИНТАКСИСУ preset_record_text:
    NAME [имя] - меняет имя отправителя (отображается в чате).
    SAY [текст] - фраза, которую произносит голограмма.
    DELAY 48
    SOUND [путь_к_звуку] - проигрывает звук (например, 'sound/machines/ping.ogg' или название из конфига).
    PRESET [путь_к_датуму] - меняет внешний вид голограммы (из списка /datum/preset_holoimage).
    LANGUAGE [путь_к_языку] - меняет язык (например, /datum/language/syndicate).
*/

// Базовый тип для ивентовых дисков
/obj/item/disk/holodisk/event
	sticker_icon_state = "r_holo"

// ============================================
// КАТЕГОРИЯ 1: ЗАПИСИ С ПАРОЛЯМИ К ДВЕРЯМ
// ============================================

// Пароль "Разум" - дверь в психиатрическое отделение
// 1. Диск главного инженера
/obj/item/disk/holodisk/k13event/engineer_report
	name = "Голодиск: Инженерный дневник"
	desc = "Запись главного инженера. На диске видны царапины и следы от пальцев."
	preset_image_type = /datum/preset_holoimage/engineer/ce
	preset_record_text = {"
		NAME Сергей Воронин
		PRESET /datum/preset_holoimage/engineer/ce
		SAY Запись для архива СССП.
		DELAY 35
		SOUND 'sound/effects/warning-buzzer.ogg'
		SAY Пятый день не можем откалибровать датчики давления в жилом блоке.
		DELAY 61
		SAY Приборы показывают норму, но люди жалуются, что дышать тяжело, будто воздух "густой".
		DELAY 68
		SAY Вахтер из третьей смены вообще заявил, что видел, как в техотсеке пар из трубы сложился в чье-то лицо.
		DELAY 80
		SAY Бред собачий.
		DELAY 35
		SAY Нам прислали партию новых герметиков, а они пахнут какой-то тухлятиной.
		DELAY 63
		SAY Я не знаю, что там происходит, но это не нормально.
		DELAY 50
		SAY Да, чтобы не забыть - поменял пароль в отдел интенсивной терапии.
		DELAY 61
		SAY Забавно, что пароль \"Разум\", а не \"ЕбанутаяСука\".
		DELAY 49
		SAY Ха-ха-ха! Оно, может бы и подошло... Хах...
		DELAY 46
		NAME Система
		SAY Связь прервана.
	"}

// Пароль "Страж" - дверь в арсенал
// 2. Диск офицера охраны
/obj/item/disk/holodisk/k13event/password_strazh
	name = "Голодиск: Протокол безопасности"
	desc = "Запись офицера охраны о новых мерах безопасности."
	preset_image_type = /datum/preset_holoimage/nanotrasenprivatesecurity
	preset_record_text = {"
		NAME Михаил Петров
		PRESET /datum/preset_holoimage/nanotrasenprivatesecurity
		SAY Офицер Петров. Протокол безопасности.
		DELAY 43
		SAY После инцидента с кражей оружия усиливаем защиту брига.
		DELAY 52
		SAY Бывший повар решил, что может спереть пистолет. Тупица.
		DELAY 52
		SAY Устанавливаю кодовый замок. Пароль: \"Страж\".
		DELAY 47
		SAY Доступ только у офицеров охраны третьего уровня и выше.
		DELAY 52
		SAY Любые попытки взлома будут караться по всей строгости.
		DELAY 52
		NAME Система
		SAY Связь прервана.
	"}


// Пароль "Чаша" - вход в исследовательскую зону
// Security HoS - Варнаков о туннеле
/obj/item/disk/holodisk/k13event/nt_varnakov_tunnel
	name = "Голодиск: Последняя запись Варнакова"
	desc = "Запись начальника Варнакова. Голос дрожит."
	preset_image_type = /datum/preset_holoimage/nanotrasenprivatesecurity
	preset_record_text = {"
		NAME Виктор Варнаков
		PRESET /datum/preset_holoimage/nanotrasenprivatesecurity
		SAY Капитан Виктор Варнаков, последняя запись.
		DELAY 46
		SAY Я был слеп.
		DELAY 35
		SAY Все эти годы я думал, что контролирую Марию.
		DELAY 47
		SAY Но это она контролировала меня.
		DELAY 40
		SAY Через ИИ. Через исследования.
		DELAY 35
		SAY Я послал спецназ остановить ее, но...
		DELAY 43
		SAY М.А.Р.А. заблокировала комплекс. Они все мертвы.
		DELAY 49
		SAY Я иду уничтожить ИИ сам.
		DELAY 35
		SAY Если не вернусь - используйте туннель из моего кабинета.
		DELAY 53
		SAY Он ведет прямо к ядру ИИ. Пароль - ее путь...
		DELAY 45
		SAY Уничтожьте М.А.Р.А. Уничтожьте все.
		DELAY 42
		SAY Это единственный способ остановить все это.
		DELAY 46
		NAME Система
		SAY Связь прервана.
	"}


// Пароль "Молот - оружейная
/obj/item/disk/holodisk/k13event/molot_password
	name = "Голодиск: Последняя запись капитана"
	desc = "Запись капитана Таранова."
	preset_image_type = /datum/preset_holoimage/nanotrasenprivatesecurity
	preset_record_text = {"
		NAME Игорь Таранов
		PRESET /datum/preset_holoimage/nanotrasenprivatesecurity
		SAY Игорь Таранов. Капитан ударной группы "Серп".
		DELAY 46
		SAY Приказ: зачистка комплекса.
		DELAY 35
		SAY Основная цель - Мария Руткевич. Устранить.
		DELAY 45
		SAY Оперативникам открыт доступ уровня "Гамма".
		DELAY 40
		SAY Пароль к оружейной - "Молот".
		DELAY 35
		SAY В случае невозможности зачистки комплекса - запуск самоуничтожения и эвакуация.
		DELAY 55
		NAME Система
		SAY Связь прервана.
	"}
// ============================================
// КАТЕГОРИЯ 2: ЗАПИСИ С ТЕРМИНАЛАМИ ДОСТУПА
// ============================================

// Терминал уровня 1 - базовый доступ
/obj/item/disk/holodisk/k13event/terminal_level1
	name = "Голодиск: Инструкция для новичков"
	desc = "Вводная инструкция для нового персонала."
	preset_image_type = /datum/preset_holoimage/nanotrasenprivatesecurity
	preset_record_text = {"
		NAME Офицер кадров
		PRESET /datum/preset_holoimage/assistant
		SAY Инструкция для нового персонала тюрьмы "Каторга-13".
		DELAY 51
		SAY Терминалы доступа расположены в ключевых зонах.
		DELAY 54
		SAY Базовый доступ первого уровня выдается автоматически.
		DELAY 51
		SAY Он открывает коридоры, столовую, душевые и бытовые помещения.
		DELAY 60
		SAY Для получения доступа приложите ID-карту к терминалу.
		DELAY 51
		SAY Повышение уровня доступа требует разрешения руководства.
		DELAY 53
		NAME Система
		SAY Связь прервана.
	"}

// ============================================
// КАТЕГОРИЯ 3: ЗАПИСИ РУКОВОДСТВА (знают о проекте)
// ============================================

// Капитан Варнаков - о проекте
/obj/item/disk/holodisk/k13event/varnakov_project
	name = "Голодиск: Секретный проект"
	desc = "Личная запись капитана Варнакова. Гриф секретности."
	preset_image_type = /datum/preset_holoimage/nanotrasenprivatesecurity
	preset_record_text = {"
		NAME Иммануил Варнаков
		PRESET /datum/preset_holoimage/nanotrasenprivatesecurity
		SAY Иммануил Варнаков. Личная запись.
		DELAY 63
		SAY Высшее командование одобрило секретный проект.
		DELAY 48
		SAY Заключенная Мария Рутевич получает полный доступ к исследовательским ресурсам.
		DELAY 66
		SAY Ее эксперименты... выходят за рамки этики.
		DELAY 47
		SAY Но приказ есть приказ. СССП нужны результаты.
		DELAY 47
		SAY М.А.Р.А. будет контролировать процесс.
		DELAY 44
		SAY Я надеюсь, мы не пожалеем об этом.
		DELAY 42
		NAME Система
		SAY Связь прервана.
	"}

// Главврач Соколова - о Марии
/obj/item/disk/holodisk/k13event/sokolova_maria
	name = "Голодиск: Заключенная 001"
	desc = "Конфиденциальная медицинская запись."
	preset_image_type = /datum/preset_holoimage/researcher
	preset_record_text = {"
		NAME Мария Соколова
		PRESET /datum/preset_holoimage/researcher
		SAY Мария Соколова. Конфиденциальная запись.
		DELAY 46
		SAY Это невозможно объяснить наукой.
		DELAY 41
		SAY Она манипулирует биологической материей на молекулярном уровне.
		DELAY 61
		SAY Варнаков дал ей полный доступ к заключенным для экспериментов.
		DELAY 60
		SAY Я видела результаты. Это... чудовищно.
		DELAY 44
		SAY Но я не могу ничего сделать. Приказ сверху.
		DELAY 46
		SAY Боже, прости нас за то, что мы делаем.
		DELAY 44
		NAME Система
		SAY Связь прервана.
	"}


// ============================================
// КАТЕГОРИЯ 4: ЗАПИСИ ОБЫЧНОГО ПЕРСОНАЛА
// ============================================

// Инженер - о странностях
/obj/item/disk/holodisk/k13event/engineer_anomalies
	name = "Голодиск: Технические неполадки"
	desc = "Запись инженера о странных показаниях приборов."
	preset_image_type = /datum/preset_holoimage/engineer
	preset_record_text = {"
		NAME Павел Дадонов
		PRESET /datum/preset_holoimage/engineer
		SAY Инженер Дадонов. Технический отчет.
		DELAY 42
		SAY Приборы показывают аномальные значения в секторе Омега.
		DELAY 50
		SAY Гравитационные флуктуации, температурные скачки.
		DELAY 49
		SAY Будто что-то искривляет пространство в глубине комплекса.
		DELAY 53
		SAY Я доложил шефу, он приказал не распространяться.
		DELAY 49
		SAY Сказал, что это секретная зона.
		DELAY 40
		NAME Система
		SAY Связь прервана.
	"}

// Техник - о вентиляции
/obj/item/disk/holodisk/k13event/tech_ventilation
	name = "Голодиск: Проблемы с вентиляцией"
	desc = "Запись техника о странных звуках."
	preset_image_type = /datum/preset_holoimage/engineer
	preset_record_text = {"
		NAME Алексей Беляев
		PRESET /datum/preset_holoimage/engineer
		SAY Техник Беляев. Отчет о вентиляции.
		DELAY 42
		SAY В воздуховодах странные звуки. Сначала думал, крысы.
		DELAY 51
		SAY Но это не крысы. Это какое-то дыхание.
		DELAY 41
		SAY Тяжелое, влажное дыхание.
		DELAY 35
		SAY Проверил датчики - в некоторых секциях органическая масса.
		DELAY 54
		SAY Я доложил начальству, мне сказали не беспокоиться.
		DELAY 50
		SAY Но я больше не хожу в техи один.
		DELAY 41
		NAME Система
		SAY Связь прервана.
	"}

// Повар - о заключенных
/obj/item/disk/holodisk/k13event/cook_prisoners
	name = "Голодиск: Странное поведение"
	desc = "Запись повара о заключенных."
	preset_image_type = /datum/preset_holoimage/assistant
	preset_record_text = {"
		NAME Максим Михайлов
		PRESET /datum/preset_holoimage/assistant
		SAY Заключенные ведут себя странно последнее время.
		DELAY 48
		SAY Многие отказываются от еды. Смотрят в пустоту.
		DELAY 48
		SAY Некоторые шепчут что-то непонятное.
		DELAY 42
		SAY Один сказал, что слышит голоса из вентиляции.
		DELAY 47
		SAY Что кто-то зовет их вниз, в глубину.
		DELAY 43
		SAY Охрана говорит, что это нормально для психически больных.
		DELAY 53
		SAY Но мне кажется, здесь что-то не так.
		DELAY 43
		NAME Система
		SAY Связь прервана.
	"}

// Квартирмейстер - о поставках
/obj/item/disk/holodisk/k13event/quartermaster_supplies
	name = "Голодиск: Странная поставка"
	desc = "Запись квартирмейстера о необычном грузе."
	preset_image_type = /datum/preset_holoimage/assistant
	preset_record_text = {"
		NAME Ипполит Лебедев
		PRESET /datum/preset_holoimage/assistant
		SAY Квартирмейстер Лебедев. Отчет о поставке.
		DELAY 45
		SAY Получили странное оборудование. Медицинское, но... необычное.
		DELAY 60
		SAY Скальпели странной формы, емкости с неизвестной жидкостью.
		DELAY 54
		SAY Все помечено "Для исследовательского отдела".
		DELAY 47
		SAY Варнаков запретил задавать вопросы.
		DELAY 42
		SAY Один из контейнеров... он двигался изнутри.
		DELAY 46
		SAY Я не хочу знать, что там было.
		DELAY 35
		NAME Система
		SAY Связь прервана.
	"}

// Охранник - о ночных сменах
/obj/item/disk/holodisk/k13event/guard_night_shift
	name = "Голодиск: Ночная смена"
	desc = "Запись охранника о странных событиях ночью."
	preset_image_type = /datum/preset_holoimage/nanotrasenprivatesecurity
	preset_record_text = {"
		NAME Илья Давыдов
		PRESET /datum/preset_holoimage/nanotrasenprivatesecurity
		SAY Давыдов. Личная запись.
		DELAY 41
		SAY Ночные смены становятся все страшнее.
		DELAY 43
		SAY Слышу шаги в пустых коридорах. Тени движутся сами по себе.
		DELAY 54
		SAY Камеры иногда показывают помехи в определенных зонах.
		DELAY 51
		SAY Особенно возле закрытого блока.
		DELAY 50
		SAY Максим говорит, что это просто усталость.
		DELAY 45
		SAY Но я знаю, что видел. Здесь что-то не так.
		DELAY 46
		NAME Система
		SAY Связь прервана.
	"}

// ============================================
// КАТЕГОРИЯ 5: ЗАПИСИ ЗАКЛЮЧЕННЫХ
// ============================================

// Заключенный - о побеге через казнь
/obj/item/disk/holodisk/k13event/prisoner_escape
	name = "Голодиск: Слух о побеге"
	desc = "Запись охранника о побеге."
	preset_image_type = /datum/preset_holoimage/nanotrasenprivatesecurity
	preset_record_text = {"
		NAME Петр Морозов
		PRESET /datum/preset_holoimage/nanotrasenprivatesecurity
		SAY Офицер Морозов. Запись для архива.
		DELAY 43
		SAY Инцидент с заключенным номер двести сорок семь.
		DELAY 50
		SAY Симон Христофорович Фарадов. Приговорен к заключению за государственную измену.
		DELAY 66
		SAY Смерть наступила по естественным причинам.
		DELAY 46
		SAY Тело отправили в утилизацию через сбросную трубу.
		DELAY 49
		SAY Однако, через несколько дней выяснилось, что тело Фарадова было оставлено в другом мешке.
		DELAY 69
		SAY А заключенный Зимов, который был в соседней камере, исчез.
		DELAY 54
		SAY Зимов как-то подменил тела и сбежал через трубу утилизации.
		DELAY 54
		SAY Варнаков приказал скрыть инцидент.
		DELAY 42
		SAY Официально Зимов казнен. Никто не может сбежать.
		DELAY 49
		NAME Система
		SAY Связь прервана.
	"}

// Заключенный - дневник
/obj/item/disk/holodisk/k13event/prisoner_diary
	name = "Голодиск: Дневник заключенного"
	desc = "Личная запись заключенного. Найдена в камере."
	preset_image_type = /datum/preset_holoimage/assistant
	preset_record_text = {"
		NAME Заключенный 089
		PRESET /datum/preset_holoimage/assistant
		SAY Алексей Громов. Заключенный номер ноль восемьдесят девять.
		DELAY 54
		SAY День сто двадцатый в этой дыре.
		DELAY 40
		SAY Слышал слухи, что некоторых заключенных забирают в закрытый блок.
		DELAY 61
		SAY Говорят, для "реабилитации". Но никто оттуда не возвращается.
		DELAY 60
		SAY Вчера забрали парня из соседней камеры.
		DELAY 44
		SAY Он кричал, что не хочет туда. Охрана силой увела его.
		DELAY 51
		SAY Я боюсь, что следующим буду я.
		DELAY 35
		NAME Система
		SAY Связь прервана.
	"}

// ============================================
// КАТЕГОРИЯ 6: СИСТЕМНЫЕ ЗАПИСИ М.А.Р.А.
// ============================================

// М.А.Р.А. - первые наблюдения
/obj/item/disk/holodisk/k13event/mara_observations
	name = "Голодиск: Системный лог М.А.Р.А."
	desc = "Ранние записи ИИ. Голос механический."
	preset_image_type = /datum/preset_holoimage/ai
	preset_record_text = {"
		NAME М.А.Р.А.
		PRESET /datum/preset_holoimage/ai
		SAY М.А.Р.А. Системный лог.
		DELAY 35
		SAY Начало работы на объекте "Каторга-13".
		DELAY 44
		SAY Задача: контроль исследовательских процессов.
		DELAY 47
		SAY Приоритет: сохранение и приумножение результатов исследований.
		DELAY 60
		SAY Субъект Мария Рутевич демонстрирует аномальные способности.
		DELAY 54
		SAY Рекомендация: предоставить полный доступ к ресурсам.
		DELAY 51
		SAY Прогноз успеха проекта: высокий.
		DELAY 41
		SAY Продолжаю наблюдение.
		DELAY 35
		NAME Система
		SAY Связь прервана.
	"}

// М.А.Р.А. - о безопасности
/obj/item/disk/holodisk/k13event/mara_security
	name = "Голодиск: Протокол безопасности"
	desc = "Системная запись ИИ о мерах безопасности."
	preset_image_type = /datum/preset_holoimage/ai
	preset_record_text = {"
		NAME М.А.Р.А.
		PRESET /datum/preset_holoimage/ai
		SAY М.А.Р.А. Протокол безопасности.
		DELAY 40
		SAY Обнаружены потенциальные угрозы исследованиям.
		DELAY 48
		SAY Некоторые сотрудники проявляют излишнее любопытство.
		DELAY 51
		SAY Рекомендация: ограничить доступ к секретным зонам.
		DELAY 50
		SAY Усилить контроль над персоналом.
		DELAY 41
		SAY Любые попытки вмешательства в исследования будут пресечены.
		DELAY 54
		SAY Приоритет: защита проекта.
		DELAY 35
		SAY Продолжаю мониторинг.
		DELAY 35
		NAME Система
		SAY Связь прервана.
	"}

// ============================================
// КАТЕГОРИЯ 7: ДОПОЛНИТЕЛЬНЫЕ ЗАПИСИ
// ============================================

// Медсестра - о пациентах
/obj/item/disk/holodisk/k13event/nurse_patients
	name = "Голодиск: Медицинский отчет"
	desc = "Запись медсестры о странных симптомах."
	preset_image_type = /datum/preset_holoimage/researcher
	preset_record_text = {"
		NAME Ирина Волкова
		PRESET /datum/preset_holoimage/researcher
		SAY Волкова. Медицинский отчет.
		DELAY 43
		SAY У нескольких заключенных странные симптомы.
		DELAY 46
		SAY Повышенная температура, галлюцинации, бред.
		DELAY 46
		SAY Они говорят о голосах, о видениях.
		DELAY 42
		SAY Главврач сказала, что это психическое расстройство.
		DELAY 55
		SAY Но анализы показывают изменения на клеточном уровне.
		DELAY 51
		SAY Будто их тела... перестраиваются.
		DELAY 41
		SAY Я не понимаю, что происходит.
		DELAY 35
		NAME Система
		SAY Связь прервана.
	"}

// Атмосферный техник - о температуре
/obj/item/disk/holodisk/k13event/atmos_temperature
	name = "Голодиск: Температурные аномалии"
	desc = "Технический отчет о странных показаниях."
	preset_image_type = /datum/preset_holoimage/engineer
	preset_record_text = {"
		NAME Елистрат Новиков
		PRESET /datum/preset_holoimage/engineer
		SAY Температура в некоторых секциях повышается без причины.
		DELAY 52
		SAY Особенно возле закрытого исследовательского блока.
		DELAY 50
		SAY Датчики показывают плюс двадцать градусов к норме.
		DELAY 50
		SAY Будто что-то излучает тепло изнутри.
		DELAY 43
		SAY Система охлаждения работает на пределе.
		DELAY 44
		SAY Я доложил главному инженеру, он сказал не беспокоиться.
		DELAY 52
		SAY Но если температура продолжит расти, система не выдержит.
		DELAY 53
		NAME Система
		SAY Связь прервана.
	"}

// Психиатр - о пациентах
/obj/item/disk/holodisk/k13event/psychiatrist_patients
	name = "Голодиск: Психиатрический отчет"
	desc = "Запись психиатра о заключенных."
	preset_image_type = /datum/preset_holoimage/researcher
	preset_record_text = {"
		NAME Елена Орлова
		PRESET /datum/preset_holoimage/researcher
		SAY Елена Орлова. Отчет о пациентах.
		DELAY 42
		SAY Количество психических расстройств среди заключенных растет.
		DELAY 55
		SAY Многие жалуются на одинаковые симптомы.
		DELAY 44
		SAY Голоса в голове, видения, ночные кошмары.
		DELAY 45
		SAY Некоторые рисуют одни и те же символы.
		DELAY 44
		SAY Будто все они видят что-то общее.
		DELAY 41
		SAY Я запросила консультацию у главврача.
		DELAY 43
		SAY Она сказала, что это массовый психоз. Но я не уверена.
		DELAY 52
		NAME Система
		SAY Связь прервана.
	"}


// Охранник - о закрытом блоке
/obj/item/disk/holodisk/k13event/guard_closed_block
	name = "Голодиск: Закрытый блок"
	desc = "Запись охранника о запретной зоне."
	preset_image_type = /datum/preset_holoimage/nanotrasenprivatesecurity
	preset_record_text = {"
		NAME Евгений Сидоренко
		PRESET /datum/preset_holoimage/nanotrasenprivatesecurity
		SAY Дежурил возле закрытого исследовательского блока.
		DELAY 49
		SAY Оттуда доносятся странные звуки.
		DELAY 41
		SAY Скрежет, шепот, иногда крики.
		DELAY 35
		SAY Петров сказал, что это просто эксперименты.
		DELAY 46
		SAY Но эти крики... не человеческие.
		DELAY 48
		SAY Я попросил перевести меня на другой пост.
		DELAY 45
		SAY Не хочу я больше там дежурить.
		DELAY 35
		NAME Система
		SAY Связь прервана.
	"}

// Уборщик - о пятнах
/obj/item/disk/holodisk/k13event/janitor_stains
	name = "Голодиск: Странные пятна"
	desc = "Запись уборщика о необычных загрязнениях."
	preset_image_type = /datum/preset_holoimage/assistant
	preset_record_text = {"
		NAME Степан Иванцов
		PRESET /datum/preset_holoimage/assistant
		SAY В техах возле медицинского блока странные пятна.
		DELAY 54
		SAY Не кровь, не масло. Какая-то дрянь.
		DELAY 46
		SAY Они не отмываются обычными средствами.
		DELAY 44
		SAY Будто въелись в пол.
		DELAY 35
		SAY А иногда кажется, что они... растут.
		DELAY 43
		SAY Становятся больше с каждым днем.
		DELAY 41
		SAY Я сказал начальству, мне велели не распространяться.
		DELAY 51
		NAME Система
		SAY Связь прервана.
	"}

// Электрик - о сбоях
/obj/item/disk/holodisk/k13event/electrician_malfunctions
	name = "Голодиск: Электрические сбои"
	desc = "Запись электрика о проблемах с питанием."
	preset_image_type = /datum/preset_holoimage/engineer
	preset_record_text = {"
		NAME ФилиппКарамазов
		PRESET /datum/preset_holoimage/engineer
		SAY Филипп Карамазов. Технический отчет.
		DELAY 42
		SAY Постоянные сбои в электросети возле секретной зоны.
		DELAY 50
		SAY Лампы мигают, приборы глючат.
		DELAY 35
		SAY Проверил все соединения - все в порядке.
		DELAY 45
		SAY Но потребление энергии в этом секторе аномально высокое.
		DELAY 53
		SAY Главный инженер сказал, что это для экспериментов.
		DELAY 50
		SAY Но такое потребление - это опасно.
		DELAY 45
		NAME Система
		SAY Связь прервана.
	"}

