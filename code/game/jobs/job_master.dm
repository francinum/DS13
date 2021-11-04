var/global/datum/controller/occupations/job_master

#define GET_RANDOM_JOB 0
#define BE_ASSISTANT 1
#define RETURN_TO_LOBBY 2




/datum/controller/occupations
		//List of all jobs
	var/list/occupations = list()
		//Associative list of all jobs, by type
	var/list/occupations_by_type
	//Associative list of all jobs, by title
	var/list/occupations_by_title
		//Players who need jobs
	var/list/unassigned = list()
		//Debug info
	var/list/job_debug = list()
		//Cache of icons for job info window
	var/list/job_icons = list()

	proc/SetupOccupations(var/setup_titles = 0)
		occupations = list()
		occupations_by_type = list()
		occupations_by_title = list()
		var/list/all_jobs = list(/datum/job/assistant) | GLOB.using_map.allowed_jobs
		if(!all_jobs.len)
			log_debug("<span class='warning'>Error setting up jobs, no job datums found!</span>")
			return FALSE
		for(var/J in all_jobs)
			var/datum/job/job = decls_repository.get_decl(J)
			if(!job)	continue
			occupations += job
			occupations_by_type[job.type] = job
			occupations_by_title[job.title] = job
			job.current_positions = 0
			for(var/alt_title in job.alt_titles)
				occupations_by_title[alt_title] = job
			if(!setup_titles) continue
			if(job.department_flag & COM)
				GLOB.command_positions |= job.title
			if(job.department_flag & SPT)
				GLOB.support_positions |= job.title
			if(job.department_flag & SEC)
				GLOB.security_positions |= job.title
			if(job.department_flag & ENG)
				GLOB.engineering_positions += job.title
			if(job.department_flag & MED)
				GLOB.medical_positions |= job.title
			if(job.department_flag & SCI)
				GLOB.science_positions |= job.title
			if(job.department_flag & MIN)
				GLOB.mining_positions |= job.title
			if(job.department_flag & SUP)
				GLOB.supply_positions |= job.title
			if(job.department_flag & SRV)
				GLOB.service_positions |= job.title
			if(job.department_flag & CIV)
				GLOB.civilian_positions |= job.title
			if(job.department_flag & MSC)
				GLOB.nonhuman_positions |= job.title

		if(!GLOB.skills.len)
			decls_repository.get_decl(/decl/hierarchy/skill)
		if(!GLOB.skills.len)
			log_debug("<span class='warning'>Error setting up job skill requirements, no skill datums found!</span>")
			return FALSE
		return TRUE


	proc/Debug(var/text)
		if(!Debug2)	return FALSE
		job_debug.Add(text)
		return TRUE


	proc/GetJob(var/rank)
		if(!rank)	return null
		for(var/datum/job/J in occupations)
			if(!J)	continue
			if(J.title == rank)	return J
		return null

	proc/ShouldCreateRecords(var/rank)
		if(!rank) return FALSE
		var/datum/job/job = GetJob(rank)
		if(!job) return FALSE
		return job.create_record

	proc/GetPlayerAltTitle(mob/new_player/player, rank)
		return player.client.prefs.GetPlayerAltTitle(GetJob(rank))

	proc/CheckGeneralJoinBlockers(var/mob/dead/new_player/joining, var/datum/job/job)
		if(!istype(joining) || !joining.client || !joining.client.prefs)
			return FALSE
		if(!istype(job))
			log_debug("Job assignment error for [joining] - job does not exist or is of the incorrect type.")
			return FALSE
		if(!job.is_position_available())
			to_chat(joining, "<span class='warning'>Unfortunately, that job is no longer available.</span>")
			return FALSE
		if(!CONFIG_GET(flag/enter_allowed))
			to_chat(joining, "<span class='warning'>There is an administrative lock on entering the game!</span>")
			return FALSE
		if(SSticker.mode && SSticker.mode.explosion_in_progress)
			to_chat(joining, "<span class='warning'>The [station_name()] is currently exploding. Joining would go poorly.</span>")
			return FALSE
		return TRUE

	proc/CheckLatejoinBlockers(var/mob/dead/new_player/joining, var/datum/job/job)
		if(!CheckGeneralJoinBlockers(joining, job))
			return FALSE
		if(job.minimum_character_age && (joining.client.prefs.age < job.minimum_character_age))
			to_chat(joining, "<span class='warning'>Your character's in-game age is too low for this job.</span>")
			return FALSE
		if(!job.player_old_enough(joining.client))
			to_chat(joining, "<span class='warning'>Your player age (days since first seen on the server) is too low for this job.</span>")
			return FALSE
		if(!SSticker || SSticker.current_state != GAME_STATE_PLAYING)
			to_chat(joining, "<span class='warning'>The round is either not ready, or has already finished...</span>")
			return FALSE
		return TRUE

	proc/CheckUnsafeSpawn(var/mob/living/spawner, var/turf/spawn_turf)
		var/radlevel = SSradiation.get_rads_at_turf(spawn_turf)
		var/airstatus = IsTurfAtmosUnsafe(spawn_turf)
		if(airstatus || radlevel > 0)
			var/reply = tgui_alert(spawner, "Warning. Your selected spawn location seems to have unfavorable conditions. \
			You may die shortly after spawning. \
			Spawn anyway? More information: [airstatus] Radiation: [radlevel] Bq", "Atmosphere warning", list("Abort", "Spawn anyway"))
			if(reply != "Spawn anyway")
				return FALSE
			else
				// Let the staff know, in case the person complains about dying due to this later. They've been warned.
				log_and_message_admins("User [spawner] spawned at spawn point with dangerous atmosphere.")
		return TRUE

	proc/AssignRole(var/mob/dead/new_player/player, var/rank, var/latejoin = 0)
		Debug("Running AR, Player: [player], Rank: [rank], LJ: [latejoin]")
		if(player && player.mind && rank)
			var/datum/job/job = GetJob(rank)
			if(!job)
				return FALSE
			if(job.minimum_character_age && (player.client.prefs.age < job.minimum_character_age))
				return FALSE
			if(jobban_isbanned(player, rank))
				return FALSE
			if(!job.player_old_enough(player.client))
				return FALSE
			if(job.is_restricted(player.client.prefs))
				return FALSE

			var/position_limit = job.total_positions
			if(!latejoin)
				position_limit = job.spawn_positions
			if((job.current_positions < position_limit) || position_limit == -1)
				Debug("Player: [player] is now Rank: [rank], JCP:[job.current_positions], JPL:[position_limit]")
				player.mind.assigned_role = rank
				player.mind.role_alt_title = GetPlayerAltTitle(player, rank)
				unassigned -= player
				job.current_positions++
				return TRUE
		Debug("AR has failed, Player: [player], Rank: [rank]")
		return FALSE

	proc/FreeRole(var/rank)	//making additional slot on the fly
		var/datum/job/job = GetJob(rank)
		if(job && !job.is_position_available())
			job.make_position_available()
			return TRUE
		return FALSE

	proc/FindOccupationCandidates(datum/job/job, level, flag)
		Debug("Running FOC, Job: [job], Level: [level], Flag: [flag]")
		var/list/candidates = list()
		for(var/mob/dead/new_player/player in unassigned)
			if(jobban_isbanned(player, job.title))
				Debug("FOC isbanned failed, Player: [player]")
				continue
			if(!job.player_old_enough(player.client))
				Debug("FOC player not old enough, Player: [player]")
				continue
			if(job.minimum_character_age && (player.client.prefs.age < job.minimum_character_age))
				Debug("FOC character not old enough, Player: [player]")
				continue
			if(flag && !(flag in player.client.prefs.be_special_role))
				Debug("FOC flag failed, Player: [player], Flag: [flag], ")
				continue
			if(player.client.prefs.CorrectLevel(job,level))
				Debug("FOC pass, Player: [player], Level:[level]")
				candidates += player
		return candidates

	proc/GiveRandomJob(var/mob/dead/new_player/player)
		Debug("GRJ Giving random job, Player: [player]")
		for(var/datum/job/job in shuffle(occupations))
			if(!job)
				continue

			if(job.minimum_character_age && (player.client.prefs.age < job.minimum_character_age))
				continue

			if(istype(job, GetJob("Assistant"))) // We don't want to give him assistant, that's boring!
				continue

			if(job.is_restricted(player.client.prefs))
				continue

			if(job.title in GLOB.command_positions) //If you want a command position, select it!
				continue

			if(jobban_isbanned(player, job.title))
				Debug("GRJ isbanned failed, Player: [player], Job: [job.title]")
				continue

			if(!job.player_old_enough(player.client))
				Debug("GRJ player not old enough, Player: [player]")
				continue

			if((job.current_positions < job.spawn_positions) || job.spawn_positions == -1)
				Debug("GRJ Random job given, Player: [player], Job: [job]")
				AssignRole(player, job.title)
				unassigned -= player
				break

	proc/ResetOccupations()
		for(var/i in GLOB.new_player_list)
			var/mob/dead/new_player/player = i
			if(player?.mind)
				player.mind.assigned_role = null
				player.mind.set_special_role(null)
		SetupOccupations()
		unassigned = list()
		return


	///This proc is called before the level loop of DivideOccupations() and will try to select a head, ignoring ALL non-head preferences for every level until it locates a head or runs out of levels to check
	proc/FillHeadPosition()
		for(var/level = 1 to 3)
			for(var/command_position in GLOB.command_positions)
				var/datum/job/job = GetJob(command_position)
				if(!job)	continue
				var/list/candidates = FindOccupationCandidates(job, level)
				if(!candidates.len)	continue

				// Build a weighted list, weight by age.
				var/list/weightedCandidates = list()
				for(var/mob/V in candidates)
					// Log-out during round-start? What a bad boy, no head position for you!
					if(!V.client) continue
					var/age = V.client.prefs.age

					if(age < job.minimum_character_age) // Nope.
						continue

					switch(age)
						if(job.minimum_character_age to (job.minimum_character_age+10))
							weightedCandidates[V] = 3 // Still a bit young.
						if((job.minimum_character_age+10) to (job.ideal_character_age-10))
							weightedCandidates[V] = 6 // Better.
						if((job.ideal_character_age-10) to (job.ideal_character_age+10))
							weightedCandidates[V] = 10 // Great.
						if((job.ideal_character_age+10) to (job.ideal_character_age+20))
							weightedCandidates[V] = 6 // Still good.
						if((job.ideal_character_age+20) to INFINITY)
							weightedCandidates[V] = 3 // Geezer.
						else
							// If there's ABSOLUTELY NOBODY ELSE
							if(candidates.len == 1) weightedCandidates[V] = 1


				var/mob/dead/new_player/candidate = pickweight(weightedCandidates)
				if(AssignRole(candidate, command_position))
					return TRUE
		return FALSE


	///This proc is called at the start of the level loop of DivideOccupations() and will cause head jobs to be checked before any other jobs of the same level
	proc/CheckHeadPositions(var/level)
		for(var/command_position in GLOB.command_positions)
			var/datum/job/job = GetJob(command_position)
			if(!job)	continue
			var/list/candidates = FindOccupationCandidates(job, level)
			if(!candidates.len)	continue
			var/mob/dead/new_player/candidate = pick(candidates)
			AssignRole(candidate, command_position)
		return


/** Proc DivideOccupations
 *  fills var "assigned_role" for all ready players.
 *  This proc must not have any side effect besides of modifying "assigned_role".
 **/
	proc/DivideOccupations()
		//Setup new player list and get the jobs list
		Debug("Running DO")
		SetupOccupations()

		//Holder for Triumvirate is stored in the SSticker, this just processes it
		if(GLOB.triai)
			for(var/datum/job/A in occupations)
				if(A.title == "AI")
					A.spawn_positions = 3
					break

		//Get the players who are ready
		for(var/i in GLOB.new_player_list)
			var/mob/dead/new_player/player = i
			if(player.ready && player.mind && !player.mind.assigned_role)
				unassigned += player

		Debug("DO, Len: [unassigned.len]")
		if(unassigned.len == 0)	return FALSE

		//Shuffle players and jobs
		unassigned = shuffle(unassigned)

		HandleFeedbackGathering()

		//People who wants to be assistants, sure, go on.
		Debug("DO, Running Assistant Check 1")
		var/datum/job/assist = new DEFAULT_JOB_TYPE ()
		var/list/assistant_candidates = FindOccupationCandidates(assist, 3)
		Debug("AC1, Candidates: [assistant_candidates.len]")
		for(var/mob/dead/new_player/player in assistant_candidates)
			Debug("AC1 pass, Player: [player]")
			AssignRole(player, "Assistant")
			assistant_candidates -= player
		Debug("DO, AC1 end")

		//Select one head
		Debug("DO, Running Head Check")
		FillHeadPosition()
		Debug("DO, Head Check end")

		//Other jobs are now checked
		Debug("DO, Running Standard Check")


		// New job giving system by Donkie
		// This will cause lots of more loops, but since it's only done once it shouldn't really matter much at all.
		// Hopefully this will add more randomness and fairness to job giving.

		// Loop through all levels from high to low
		var/list/shuffledoccupations = shuffle(occupations)
		// var/list/disabled_jobs = SSticker.mode.disabled_jobs  // So we can use .Find down below without a colon.
		for(var/level = 1 to 3)
			//Check the head jobs first each level
			CheckHeadPositions(level)

			// Loop through all unassigned players
			for(var/mob/dead/new_player/player in unassigned)

				// Loop through all jobs
				for(var/datum/job/job in shuffledoccupations) // SHUFFLE ME BABY
					if(!job || SSticker.mode.disabled_jobs.Find(job.title) )
						continue

					if(jobban_isbanned(player, job.title))
						Debug("DO isbanned failed, Player: [player], Job:[job.title]")
						continue

					if(!job.player_old_enough(player.client))
						Debug("DO player not old enough, Player: [player], Job:[job.title]")
						continue

					// If the player wants that job on this level, then try give it to him.
					if(player.client.prefs.CorrectLevel(job,level))

						// If the job isn't filled
						if((job.current_positions < job.spawn_positions) || job.spawn_positions == -1)
							Debug("DO pass, Player: [player], Level:[level], Job:[job.title]")
							AssignRole(player, job.title)
							unassigned -= player
							break

		// Hand out random jobs to the people who didn't get any in the last check
		// Also makes sure that they got their preference correct
		for(var/mob/dead/new_player/player in unassigned)
			if(player.client.prefs.alternate_option == GET_RANDOM_JOB)
				GiveRandomJob(player)

		Debug("DO, Standard Check end")

		Debug("DO, Running AC2")

		// For those who wanted to be assistant if their preferences were filled, here you go.
		for(var/mob/dead/new_player/player in unassigned)
			if(player.client.prefs.alternate_option == BE_ASSISTANT)
				Debug("AC2 Assistant located, Player: [player]")
				if(GLOB.using_map.flags & MAP_HAS_BRANCH)
					var/datum/mil_branch/branch = mil_branches.get_branch(player.get_branch_pref())
					AssignRole(player, branch.assistant_job)
				else
					AssignRole(player, "Assistant")

		//For ones returning to lobby
		for(var/mob/dead/new_player/player in unassigned)
			if(player.client.prefs.alternate_option == RETURN_TO_LOBBY)
				player.ready = 0
				player.new_player_panel_proc()
				unassigned -= player
		return TRUE

	proc/EquipCustomLoadout(var/mob/living/carbon/human/H, var/datum/job/job)

		if(!H || !H.client)
			return

		// Equip custom gear loadout, replacing any job items
		var/list/spawn_in_storage = list()
		var/list/loadout_taken_slots = list()
		if(H.client.prefs.Gear() && job.loadout_allowed)
			for(var/thing in H.client.prefs.Gear())
				var/datum/gear/G = GLOB.gear_datums[thing]
				if(G)
					if (!G.job_permitted(H, job))
						to_chat(H, "<span class='warning'>Your current species, job, branch or whitelist status does not permit you to spawn with [thing]!</span>")
						continue




					if(!G.slot || G.slot == slot_tie || (G.slot in loadout_taken_slots) || !G.spawn_on_mob(H, H.client.prefs.Gear()[G.display_name]))
						spawn_in_storage.Add(G)
					else
						loadout_taken_slots.Add(G.slot)

		// do accessories last so they don't attach to a suit that will be replaced
		if(H.char_rank && H.char_rank.accessory)
			for(var/accessory_path in H.char_rank.accessory)
				var/list/accessory_data = H.char_rank.accessory[accessory_path]
				if(islist(accessory_data))
					var/amt = accessory_data[1]
					var/list/accessory_args = accessory_data.Copy()
					accessory_args[1] = src
					for(var/i in 1 to amt)
						H.equip_to_slot_or_del(new accessory_path(arglist(accessory_args)), slot_tie)
				else
					for(var/i in 1 to (isnull(accessory_data)? 1 : accessory_data))
						H.equip_to_slot_or_del(new accessory_path(src), slot_tie)

		return spawn_in_storage

	/*
		Partially gutted by Nanako, this proc no longer handles equipment or items. IT still does setup of accounts and various nonphysical things
	*/
	proc/EquipRank(var/mob/living/carbon/human/H, var/rank, var/joined_late = 0, var/no_outfit = FALSE)
		if(!H)	return null

		var/datum/job/job = GetJob(rank)

		if(job)

			// Transfers the skill settings for the job to the mob
			H.skillset.obtain_from_client(job, H.client)

			//Equip job items.
			job.setup_account(H)

			// EMAIL GENERATION
			if(rank != "Robot" && rank != "AI")		//These guys get their emails later.
				var/domain
				var/desired_name
				if(H.char_branch && H.char_branch.email_domain)
					domain = H.char_branch.email_domain
				else
					domain = "ishimura.cec"
				desired_name = H.real_name
				ntnet_global.create_email(H, desired_name, domain)
			// END EMAIL GENERATION

		else
			to_chat(H, "Your job is [rank] and the game just can't handle it! Please report this bug to an administrator.")

		H.job = rank

		if(!joined_late || job.latejoin_at_spawnpoints)
			var/obj/S = get_roundstart_spawnpoint(rank)

			if(istype(S, /obj/effect/landmark/start) && istype(S.loc, /turf))
				H.forceMove(S.loc)
			else
				var/datum/spawnpoint/spawnpoint = get_spawnpoint_for(H.client, rank)
				H.forceMove(pick(spawnpoint.turfs))

			// Moving wheelchair if they have one
			if(H.buckled && istype(H.buckled, /obj/structure/bed/chair/wheelchair))
				H.buckled.forceMove(H.loc)
				H.buckled.set_dir(H.dir)

		// If they're head, give them the account info for their department
		if(H.mind && job.head_position)
			var/remembered_info = ""
			var/datum/money_account/department_account = department_accounts[job.department]

			if(department_account)
				remembered_info += "<b>Your department's account number is:</b> #[department_account.account_number]<br>"
				remembered_info += "<b>Your department's account pin is:</b> [department_account.remote_access_pin]<br>"
				remembered_info += "<b>Your department's account funds are:</b> T[department_account.money]<br>"

			H.mind.store_memory(remembered_info)

		var/alt_title = null
		if(H.mind)
			H.mind.assigned_role = rank
			alt_title = H.mind.role_alt_title

			switch(rank)
				if("Robot")
					return H.Robotize()
				if("AI")
					return H
				if("Captain")
					var/sound/announce_sound = (SSticker.current_state <= GAME_STATE_SETTING_UP)? null : sound('sound/misc/boatswain.ogg', volume=20)
					captain_announcement.Announce("All hands, Captain [H.real_name] on deck!", new_sound=announce_sound)



		if(istype(H)) //give humans wheelchairs, if they need them.
			var/obj/item/organ/external/l_foot = H.get_organ(BP_L_FOOT)
			var/obj/item/organ/external/r_foot = H.get_organ(BP_R_FOOT)
			if(!l_foot || !r_foot)
				var/obj/structure/bed/chair/wheelchair/W = new /obj/structure/bed/chair/wheelchair(H.loc)
				H.buckled = W
				H.update_lying_buckled_and_verb_status()
				W.set_dir(H.dir)
				W.buckled_mob = H
				W.add_fingerprint(H)

		to_chat(H, "<span class='infoplain'><B>You are [job.total_positions == 1 ? "the" : "a"] [alt_title ? alt_title : rank].</B></span>")

		if(job.supervisors)
			to_chat(H, "<span class='infoplain'><b>As the [alt_title ? alt_title : rank] you answer directly to [job.supervisors]. Special circumstances may change this.</b></span>")

		to_chat(H, "<span class='infoplain'><b>To speak on your department's radio channel use :h. For the use of other channels, examine your headset.</b></span>")

		if(job.req_admin_notify)
			to_chat(H, "<span class='infoplain'><b>You are playing a job that is important for Game Progression. If you have to disconnect, please notify the admins via adminhelp.</b></span>")

		//Gives glasses to the vision impaired
		if(H.disabilities & NEARSIGHTED)
			var/equipped = H.equip_to_slot_or_del(new /obj/item/clothing/glasses/regular(H), slot_glasses)
			if(equipped)
				var/obj/item/clothing/glasses/G = H.glasses
				G.prescription = 7

		BITSET(H.hud_updateflag, ID_HUD)
		BITSET(H.hud_updateflag, IMPLOYAL_HUD)
		BITSET(H.hud_updateflag, SPECIALROLE_HUD)
		return H

	proc/LoadJobs(jobsfile) //ran during round setup, reads info from jobs.txt -- Urist
		if(!CONFIG_GET(flag/load_jobs_from_txt))
			return FALSE

		var/list/jobEntries = file2list(jobsfile)

		for(var/job in jobEntries)
			if(!job)
				continue

			job = trim(job)
			if (!length(job))
				continue

			var/pos = findtext(job, "=")
			var/name = null
			var/value = null

			if(pos)
				name = copytext(job, 1, pos)
				value = copytext(job, pos + 1)
			else
				continue

			if(name && value)
				var/datum/job/J = GetJob(name)
				if(!J)	continue
				J.total_positions = text2num(value)
				J.spawn_positions = text2num(value)
				if(name == "AI" || name == "Robot")//I dont like this here but it will do for now
					J.total_positions = 0

		return TRUE


	proc/HandleFeedbackGathering()
		for(var/datum/job/job in occupations)
			var/tmp_str = "|[job.title]|"

			var/level1 = 0 //high
			var/level2 = 0 //medium
			var/level3 = 0 //low
			var/level4 = 0 //never
			var/level5 = 0 //banned
			var/level6 = 0 //account too young
			for(var/i in GLOB.new_player_list)
				var/mob/dead/new_player/player = i
				if(!(player.ready && player.mind && !player.mind.assigned_role))
					continue //This player is not ready
				if(jobban_isbanned(player, job.title))
					level5++
					continue
				if(!job.player_old_enough(player.client))
					level6++
					continue
				if(player.client.prefs.CorrectLevel(job, 1))
					level1++
				else if(player.client.prefs.CorrectLevel(job, 2))
					level2++
				else if(player.client.prefs.CorrectLevel(job, 3))
					level3++
				else level4++ //not selected

			tmp_str += "HIGH=[level1]|MEDIUM=[level2]|LOW=[level3]|NEVER=[level4]|BANNED=[level5]|YOUNG=[level6]|-"
			feedback_add_details("job_preferences",tmp_str)


/**
 *  Return appropriate /datum/spawnpoint for given client and rank
 *
 *  Spawnpoint will be the one set in preferences for the client, unless the
 *  preference is not set, or the preference is not appropriate for the rank, in
 *  which case a fallback will be selected.
 */
/datum/controller/occupations/proc/get_spawnpoint_for(var/client/C, var/rank, var/datum/preferences/prefs, var/check_safety = FALSE)

	if(!C)
		CRASH("Null client passed to get_spawnpoint_for() proc!")

	var/mob/H = C.mob
	if (!prefs)
		prefs = C.prefs
	var/desired_spawnpoint = prefs.spawnpoint
	var/datum/spawnpoint/current_spawnpoint

	if(desired_spawnpoint == DEFAULT_SPAWNPOINT_ID)
		desired_spawnpoint = GLOB.using_map.default_spawn

	if(desired_spawnpoint)
		if(!(desired_spawnpoint in GLOB.using_map.allowed_spawns))
			if(H)
				to_chat(H, "<span class='warning'>Your chosen spawnpoint ([desired_spawnpoint]) is unavailable for the current map. Spawning you at one of the enabled spawn points instead. To resolve this error head to your character's setup and choose a different spawn point.</span>")
			current_spawnpoint = null
		else
			current_spawnpoint = spawntypes()[desired_spawnpoint]


	if(current_spawnpoint && !current_spawnpoint.check_job_spawning(rank))
		if(H)
			to_chat(H, "<span class='warning'>Your chosen spawnpoint ([current_spawnpoint.display_name]) is unavailable for your chosen job ([rank]). Spawning you at another spawn point instead.</span>")
		current_spawnpoint = null

	//Lets check if its safe
	if (check_safety && current_spawnpoint)
		if(!current_spawnpoint.is_safe(H))
			current_spawnpoint = null

	if(!current_spawnpoint)
		// Step through all spawnpoints and pick first appropriate for job
		for(var/spawntype in GLOB.using_map.allowed_spawns)
			var/datum/spawnpoint/candidate = spawntypes()[spawntype]
			if(candidate.check_job_spawning(rank))

				//If its not safe, move on
				if (check_safety && !candidate.is_safe(H))
					continue

				current_spawnpoint = candidate
				break

	if(!current_spawnpoint)
		// Pick at random from all the (wrong) spawnpoints, just so we have one
		warning("Could not find an appropriate spawnpoint for job [rank].")
		current_spawnpoint = spawntypes()[pick(GLOB.using_map.allowed_spawns)]

	return current_spawnpoint

/datum/controller/occupations/proc/GetJobByType(var/job_type)
	return occupations_by_type[job_type]

/datum/controller/occupations/proc/get_roundstart_spawnpoint(var/rank)
	var/list/loc_list = list()
	for(var/obj/effect/landmark/start/sloc in landmarks_list)
		if(sloc.name != rank)	continue
		if(locate(/mob/living) in sloc.loc)	continue
		loc_list += sloc
	if(loc_list.len)
		return pick(loc_list)
	else
		return locate("start*[rank]") // use old stype
