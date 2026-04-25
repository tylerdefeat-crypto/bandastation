// MARK: Airlock

/obj/machinery/door/airlock/vault/quest
	name = "запертая дверь"
	desc = "Закрытая на особый доступ дверь. Похоже, она неразрушима. Вероятно вам стоит найти доступ, подходящий для её открытия. Взломать её не выйдет."
	resistance_flags = INDESTRUCTIBLE

/obj/machinery/door/airlock/vault/quest/screwdriver_act(mob/living/user, obj/item/tool)
	return ITEM_INTERACT_SKIP_TO_ATTACK

/obj/machinery/door/airlock/vault/quest/emag_act(mob/user, obj/item/card/emag/emag_card)
	return FALSE

/obj/machinery/door/airlock/vault/quest/alpha
	name = "запертая дверь АЛЬФА"
	req_access = list("katorga_alpha")

/obj/machinery/door/airlock/vault/quest/beta
	name = "запертая дверь БЕТА"
	req_access = list("katorga_beta")

/obj/machinery/door/airlock/vault/quest/gamma
	name = "запертая дверь ГАММА"
	req_access = list("katorga_gamma")

/obj/machinery/door/airlock/vault/quest/delta
	name = "запертая дверь ДЕЛЬТА"
	req_access = list("katorga_delta")

/obj/machinery/door/airlock/vault/quest/epsilon
	name = "запертая дверь ЭПСИЛОН"
	req_access = list("katorga_epsilon")

/obj/machinery/door/airlock/vault/quest/zeta
	name = "запертая дверь ЗЭТА"
	req_access = list("katorga_zeta")

// MARK: Console

/obj/machinery/computer/terminal/katorga
	name = "терминал выдачи доступа"
	desc = "Терминал, позволяющий получить доступ местной системы безопасности. Позволяет открыть дверь, соответствующую букве алфавита. Проведите своей картой по консоли для получения доступа."
	upperinfo = "Система выдачи доступов"
	content = list("Убедитесь, что ни один из заключённых не имеет доступа к консоли. Консоль выдачи доступов должна охраняться как минимум одним охранником категории Дельта. В случае допущения несанкционированного доступа к консоли незамедлительно активировать протокол локдауна.")
	resistance_flags = INDESTRUCTIBLE

	var/access_to_grant = null

/obj/machinery/computer/terminal/katorga/screwdriver_act(mob/living/user, obj/item/tool)
	return ITEM_INTERACT_SKIP_TO_ATTACK

/obj/machinery/computer/terminal/katorga/item_interaction(mob/living/user, obj/item/item, list/modifiers)
	var/obj/item/card/id/card = item
	if(!istype(card))
		return ITEM_INTERACT_BLOCKING
	if(access_to_grant in card.access)
		balloon_alert(user, "Доступ уже выдан")
		return ITEM_INTERACT_BLOCKING
	card.access.Add(access_to_grant)
	balloon_alert(user, "Доступ обновлён!")
	return ITEM_INTERACT_SUCCESS

/obj/machinery/computer/terminal/katorga/alpha
	name = "терминал выдачи доступа АЛЬФА"
	access_to_grant = "katorga_alpha"

/obj/machinery/computer/terminal/katorga/beta
	name = "терминал выдачи доступа БЕТА"
	access_to_grant = "katorga_beta"

/obj/machinery/computer/terminal/katorga/gamma
	name = "терминал выдачи доступа ГАММА"
	access_to_grant = "katorga_gamma"

/obj/machinery/computer/terminal/katorga/delta
	name = "терминал выдачи доступа ДЕЛЬТА"
	access_to_grant = "katorga_delta"

/obj/machinery/computer/terminal/katorga/epsilon
	name = "терминал выдачи доступа ЭПСИЛОН"
	access_to_grant = "katorga_epsilon"

/obj/machinery/computer/terminal/katorga/zeta
	name = "терминал выдачи доступа ЗЭТА"
	access_to_grant = "katorga_zeta"
