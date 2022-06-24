/datum/admin_secret_item/admin_secret/show_game_mode
	name = "Show Game Mode"

/datum/admin_secret_item/admin_secret/show_game_mode/can_execute(var/mob/user)
	if(!SSticker)
		return 0
	return ..()

/datum/admin_secret_item/admin_secret/show_game_mode/execute(var/mob/user)
	. = ..()
	if(!.)
		return
	if (SSticker.mode) tgui_alert(user, "The game mode is [SSticker.mode.name]")
	else tgui_alert(user, "For some reason there's a ticker, but not a game mode")
