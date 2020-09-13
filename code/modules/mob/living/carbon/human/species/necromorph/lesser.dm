/*
	Lesser Necromorph base code

	Lesser Necromorphs are not human, they use simple animal base.
	They come in one piece, and can't be dismembered.

	They should only be used for simple creatures, not for anything with multiple limbs or a humanoid shape

	Currently used for:
		Divider Arm
		Divider Leg
		Divider Head

	Planned future use:
		Swarmer
		The Swarm (DS3)
		Guardian Pod
		Guardian (premature form)
*/
/mob/living/simple_animal/necromorph
	min_gas = null
	max_gas = null
	harm_intent_damage = 5
	mass = 1
	density = FALSE
	var/lifespan = 10 MINUTES	//Minor necromorphs don't last forever, their health gradually ticks down
	stompable = TRUE

	mob_size = MOB_SMALL

	response_help   = "curiously touches"
	response_disarm = "frantically tries to clear off"
	response_harm   = "flails wildly at"

/mob/living/simple_animal/necromorph/Initialize()
	.=..()
	if (lifespan)
		var/time_per_tick = lifespan / max_health
		addtimer(CALLBACK(src, /mob/living/simple_animal/necromorph/proc/decay), time_per_tick)

//Take 1 point of lasting damage and queue another timer
/mob/living/simple_animal/necromorph/proc/decay()
	if (stat == DEAD)
		return
	adjustLastingDamage(1)


	if (stat == DEAD)
		return

	var/time_per_tick = lifespan / max_health
	addtimer(CALLBACK(src, /mob/living/simple_animal/necromorph/proc/decay), time_per_tick)

/mob/living/simple_animal/necromorph/is_necromorph()
	return TRUE





















//Parasite Extension: The mob latches onto another mob and periodically bites it for some constant damage
/datum/extension/mount/parasite
	var/damage = 5
	var/damage_chance = 30

/datum/extension/mount/parasite/on_mount()
	.=..()
	START_PROCESSING(SSprocessing, src)



	var/mob/living/biter = mountee
	spawn(0.5 SECONDS)
		if (!QDELETED(biter) && !QDELETED(src) && mountpoint && mountee)
			//Lets put the parasite somewhere nice looking on the mob
			var/new_rotation = rand(-90, 90)
			var/new_x = rand(-8, 8)
			var/new_y = rand(0, 12)
			var/matrix/M = matrix()
			M = M.Scale(0.75)
			M = M.Turn(new_rotation)

			animate(biter, transform = M, pixel_x = new_x, pixel_y = new_y, time = 5, flags = ANIMATION_END_NOW)



/datum/extension/mount/parasite/on_dismount()
	.=..()
	STOP_PROCESSING(SSprocessing, src)
	var/mob/living/biter = mountee
	if (biter)
		biter.animate_to_default()

/datum/extension/mount/parasite/proc/safety_check()
	var/mob/living/biter = mountee
	var/mob/living/victim = mountpoint

	if (!istype(biter) || QDELETED(biter))
		return FALSE

	if (!istype(victim) || QDELETED(victim))
		return FALSE

	//Biter must be able bodied and alive
	if (biter.incapacitated())
		return FALSE

	//Victim must not be dead yet
	if (victim.stat == DEAD)
		return FALSE

	//We must still be on them
	if (get_turf(victim) != get_turf(biter))
		return FALSE

	return TRUE

/datum/extension/mount/parasite/Process()
	if (!safety_check())
		dismount()
		return PROCESS_KILL

	var/mob/living/biter = mountee
	var/mob/living/victim = mountpoint

	//If the biter is being grabbed, it doesnt fall off, but it can't bite either
	if (biter.grabbed_by.len)
		return

	if(prob(damage_chance))


		biter.launch_strike(target = victim, damage = src.damage, used_weapon = biter, damage_flags = DAM_SHARP, armor_penetration = 5, damage_type = BRUTE, armor_type = "melee", target_zone = ran_zone(), difficulty = 100)
		playsound(biter, 'sound/weapons/bite.ogg', VOLUME_LOW, 1)
		biter.heal_overall_damage(damage*0.25)	//The biter heals itself by nomming
		victim.shake_animation(10)
		biter.set_click_cooldown(4 SECONDS) //It can't do normal attacks while attached
		return TRUE

	return FALSE