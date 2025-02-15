// Returns the lowest turf available on a given Z-level

proc/get_base_turf(var/z_num)
	var/z = num2text(z_num)
	if(!GLOB.using_map.base_turf_by_z[z])
		GLOB.using_map.base_turf_by_z[z] = world.turf
	return GLOB.using_map.base_turf_by_z[z]

//An area can override the z-level base turf, so our solar array areas etc. can be space-based.
proc/get_base_turf_by_area(var/turf/T)
	var/area/A = T.loc
	if(A.base_turf)
		return A.base_turf
	return get_base_turf(T.z)

/client/proc/set_base_turf()
	set category = "Debug"
	set name = "Set Base Turf"
	set desc = "Set the base turf for a z-level."

	if(!check_rights(R_DEBUG)) return

	var/choice = input("Which Z-level do you wish to set the base turf for?") as num|null
	if(!choice)
		return

	var/new_base_path = input("Please select a turf path (cancel to reset to /turf/space).") as null|anything in typesof(/turf)
	if(!new_base_path)
		new_base_path = /turf/space
	GLOB.using_map.base_turf_by_z["[choice]"] = new_base_path
	message_admins("[key_name_admin(usr)] has set the base turf for z-level [choice] to [get_base_turf(choice)].")
	log_admin("[key_name(usr)] has set the base turf for z-level [choice] to [get_base_turf(choice)].")

// This is a typepath to just sit in baseturfs and act as a marker for other things.
/turf/baseturf_skipover
	name = "Baseturf skipover placeholder"
	desc = "This shouldn't exist"

/turf/baseturf_skipover/Initialize(mapload)
	.=..()
	crash_with("[src]([type]) was instanced which should never happen. Changing into the next baseturf down...")

/turf/baseturf_bottom
	name = "Z-level baseturf placeholder"
	desc = "Marker for z-level baseturf, usually resolves to space."
