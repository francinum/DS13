/obj/item/material/twohanded/baseballbat
	name = "bat"
	desc = "HOME RUN!"
	icon = 'icons/obj/weapons.dmi'
	icon_state = "metalbat0"
	base_icon = "metalbat"
	item_state = "metalbat"
	w_class = ITEM_SIZE_LARGE
	throwforce = 7
	attack_verb = list("smashed", "beaten", "slammed", "smacked", "struck", "battered", "bonked")
	hitsound = 'sound/weapons/genhit3.ogg'
	default_material = "wood"
	force_divisor = 0.9           // 22 when wielded with weight 20 (steel)
	unwielded_force_divisor = 0.6 // 15 when unwielded based on above.
	attack_cooldown_modifier = 1
	melee_accuracy_bonus = -10
	slot_flags = SLOT_BACK

//Predefined materials go here.
/obj/item/material/twohanded/baseballbat/metal/New(var/newloc)
	..(newloc,"steel")

/obj/item/material/twohanded/baseballbat/uranium/New(var/newloc)
	..(newloc,"uranium")

/obj/item/material/twohanded/baseballbat/gold/New(var/newloc)
	..(newloc,MATERIAL_GOLD)

/obj/item/material/twohanded/baseballbat/platinum/New(var/newloc)
	..(newloc,"platinum")

/obj/item/material/twohanded/baseballbat/diamond/New(var/newloc)
	..(newloc,MATERIAL_DIAMOND)