
/*
	Component Species

	This is only used for creating a preference option to opt in/out of playing components
	its not actually assigned to anyone
*/
/datum/species/necromorph/divider_component
	name = SPECIES_NECROMORPH_DIVIDER_COMPONENT
	marker_spawnable = FALSE
	spawner_spawnable = FALSE
	preference_settable = TRUE




/*
	Component Mobs
*/
/mob/living/simple_animal/necromorph/divider_component
	max_health = 35
	icon = 'icons/mob/necromorph/divider/components.dmi'
	var/leap_windup_time = 0.8 SECOND
	var/leap_range = 6
	speed = 3

/mob/living/simple_animal/necromorph/divider_component/Initialize()
	.=..()
	add_modclick_verb(KEY_ALT, /mob/living/simple_animal/necromorph/divider_component/proc/leap)
	get_controlling_player()




/mob/living/simple_animal/necromorph/divider_component/proc/get_controlling_player()
	SSnecromorph.fill_vessel_from_queue(src, SPECIES_NECROMORPH_DIVIDER_COMPONENT)

/mob/living/simple_animal/necromorph/divider_component/proc/leap(var/atom/A)
	set name = "Leap Attack"
	set category = "Abilities"

	//Leap autotargets enemies within one tile of the clickpoint
	if (!isliving(A))
		A = autotarget_enemy_mob(A, 2, src, 999)


	if (!can_charge(A))
		return

	//Do a chargeup animation. Pulls back and then launches forwards
	//The time is equal to the windup time of the attack, plus 0.5 seconds to prevent a brief stop and ensure launching is a fluid motion
	var/vector2/pixel_offset = Vector2.DirectionBetween(src, A) * -16
	var/vector2/cached_pixels = get_new_vector(src.pixel_x, src.pixel_y)
	animate(src, pixel_x = src.pixel_x + pixel_offset.x, pixel_y = src.pixel_y + pixel_offset.y, time = (leap_windup_time - (0.3 SECONDS)), easing = BACK_EASING, flags = ANIMATION_PARALLEL)
	animate(pixel_x = cached_pixels.x, pixel_y = cached_pixels.y, time = 0.3 SECONDS)

	release_vector(pixel_offset)
	release_vector(cached_pixels)

	//Long shout when targeting mobs, normal when targeting objects
	/*
	if (ismob(A))
		H.play_species_audio(H, SOUND_SHOUT_LONG, 100, 1, 3)
	else
		H.play_species_audio(H, SOUND_SHOUT, 100, 1, 3)
	*/

	return leap_attack(A, _cooldown = 6 SECONDS, _delay = (leap_windup_time - (0.2 SECONDS)), _speed = 7, _maxrange = 6, _lifespan = 5 SECONDS)


















