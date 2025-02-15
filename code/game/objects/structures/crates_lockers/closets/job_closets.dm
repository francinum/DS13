/* Closets for specific jobs
 * Contains:
 *		Bartender
 *		Janitor
 *		Lawyer
 */

/*
 * Bartender
 */
/obj/structure/closet/gmcloset
	name = "formal closet"
	desc = "It's a storage unit for formal clothing."
	icon_state = "black"
	icon_closed = "black"

/obj/structure/closet/gmcloset/WillContain()
	return list(
		/obj/item/clothing/head/that = 2,
		/obj/item/radio/headset/headset_service = 2,
		/obj/item/clothing/head/hairflower,
		/obj/item/clothing/head/hairflower/pink,
		/obj/item/clothing/head/hairflower/yellow,
		/obj/item/clothing/head/hairflower/blue,
		/obj/item/clothing/under/sl_suit = 2,
		/obj/item/clothing/under/rank/bartender = 2,
		/obj/item/clothing/accessory/wcoat = 2,
		/obj/item/clothing/shoes/black = 2
	)

/*
 * Chef
 */
/obj/structure/closet/chefcloset
	name = "chef's closet"
	desc = "It's a storage unit for foodservice garments."
	icon_state = "black"
	icon_closed = "black"

/obj/structure/closet/chefcloset/WillContain()
	return list(
		/obj/item/clothing/under/waiter = 2,
		/obj/item/radio/headset/headset_service = 2,
		/obj/item/storage/box/mousetraps = 2,
		/obj/item/clothing/under/rank/chef,
		/obj/item/clothing/head/chefhat
	)

/*
 * Janitor
 */
/obj/structure/closet/jcloset
	name = "custodial closet"
	desc = "It's a storage unit for janitorial clothes and gear."
	icon_state = "mixed"
	icon_closed = "mixed"

/obj/structure/closet/jcloset/WillContain()
	return list(
		/obj/item/clothing/under/rank/janitor,
		/obj/item/radio/headset/headset_service,
		/obj/item/clothing/gloves/thick,
		/obj/item/flashlight,
		/obj/item/caution = 4,
		/obj/item/lightreplacer,
		/obj/item/storage/bag/trash,
		/obj/item/clothing/shoes/galoshes,
		/obj/item/clothing/accessory/solgov/specialty/janitor,
		/obj/item/reagent_containers/glass/rag,
		/obj/item/soap,
		/obj/item/mop,
		/obj/item/reagent_containers/glass/bucket,
		/obj/item/grenade/chem_grenade/cleaner,
		/obj/item/grenade/chem_grenade/cleaner,
		/obj/item/reagent_containers/spray/cleaner,
		/obj/item/rig_module/grenade_launcher/cleaner,
		/obj/item/rig_module/fabricator/wf_sign,
		/obj/random/tool)

/*
 * Lawyer
 */
/obj/structure/closet/lawcloset
	name = "legal closet"
	desc = "It's a storage unit for courtroom apparel and items."
	icon_state = "blue"
	icon_closed = "blue"

/obj/structure/closet/lawcloset/WillContain()
	return list(
		/obj/item/clothing/under/lawyer/female,
		/obj/item/clothing/under/lawyer/black,
		/obj/item/clothing/under/lawyer/bluesuit,
		/obj/item/clothing/suit/storage/toggle/suit/blue,
		/obj/item/clothing/suit/storage/toggle/suit/purple,
		/obj/item/clothing/shoes/brown,
		/obj/item/clothing/shoes/black
	)
