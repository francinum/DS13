/obj/structure/closet/secure_closet/bar
	name = "bartender's closet"
	req_access = list(access_service)
	icon_state = "cabinetdetective_locked"
	icon_closed = "cabinetdetective"
	icon_locked = "cabinetdetective_locked"
	icon_opened = "cabinetdetective_open"
	icon_broken = "cabinetdetective_sparks"
	icon_off = "cabinetdetective_broken"

/obj/structure/closet/secure_closet/bar/WillContain()
	return list(
	/obj/item/reagent_containers/food/drinks/bottle/small/beer = 10,
	/obj/item/reagent_containers/food/drinks/bottle/marinerdescent,
	/obj/item/clothing/under/rank/bartender,
	/obj/item/clothing/shoes/black,
	/obj/item/radio/headset/headset_service
	)
