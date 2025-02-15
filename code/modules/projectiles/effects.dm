/obj/effect/projectile
	icon = 'icons/effects/projectiles.dmi'
	icon_state = "bolt"
	plane = GAME_PLANE
	layer = LIGHTING_SECONDARY_LAYER //Muzzle flashes would be above the lighting plane anyways.
	//Standard compiletime light vars aren't working here, so we've made some of our own.
	light_range = 2
	light_power = 0.5
	light_color = "#ff00dc"

	mouse_opacity = 0
	var/lifespan = 3.5

	var/list/random_iconstate

	can_block_movement = FALSE //Incorporeal

/obj/effect/projectile/Initialize()
	.= ..()
	//We need a tiny sleep for random icons to be setup
	if (random_iconstate)
		icon_state = pick(random_iconstate)


	if (lifespan)
		animate(src, alpha = 0, time = lifespan, flags = ANIMATION_END_NOW)
		QDEL_IN(src,lifespan)


/obj/effect/projectile/proc/set_transform(var/matrix/M)
	if(istype(M))
		transform = M

//----------------------------
// Laser beam
//----------------------------
/obj/effect/projectile/laser/
	light_color = COLOR_RED_LIGHT

/obj/effect/projectile/laser/tracer
	icon_state = "beam"

/obj/effect/projectile/laser/muzzle
	icon_state = "muzzle_laser"

/obj/effect/projectile/laser/impact
	icon_state = "impact_laser"

//----------------------------
// Blue laser beam
//----------------------------
/obj/effect/projectile/laser/blue
	light_color = COLOR_BLUE_LIGHT

/obj/effect/projectile/laser/blue/tracer
	icon_state = "beam_blue"

/obj/effect/projectile/laser/blue/muzzle
	icon_state = "muzzle_blue"

/obj/effect/projectile/laser/blue/impact
	icon_state = "impact_blue"

//----------------------------
// Omni laser beam
//----------------------------
/obj/effect/projectile/laser/omni
	light_color = COLOR_LUMINOL

/obj/effect/projectile/laser/omni/tracer
	icon_state = "beam_omni"

/obj/effect/projectile/laser/omni/muzzle
	icon_state = "muzzle_omni"

/obj/effect/projectile/laser/omni/impact
	icon_state = "impact_omni"

//----------------------------
// Xray laser beam
//----------------------------
/obj/effect/projectile/laser/xray
	light_color = "#00cc00"

/obj/effect/projectile/laser/xray/tracer
	icon_state = "xray"

/obj/effect/projectile/laser/xray/muzzle
	icon_state = "muzzle_xray"

/obj/effect/projectile/laser/xray/impact
	icon_state = "impact_xray"

//----------------------------
// Heavy laser beam
//----------------------------
/obj/effect/projectile/laser/heavy
	light_power = 0.8

/obj/effect/projectile/laser/heavy/tracer
	icon_state = "beam_heavy"

/obj/effect/projectile/laser/heavy/muzzle
	icon_state = "muzzle_beam_heavy"

/obj/effect/projectile/laser/heavy/impact
	icon_state = "impact_beam_heavy"

//----------------------------
// Pulse laser beam
//----------------------------
/obj/effect/projectile/laser/pulse
	light_power = 0.7
	light_color = COLOR_DEEP_SKY_BLUE

/obj/effect/projectile/laser/pulse/tracer
	icon_state = "u_laser"


/obj/effect/projectile/laser/pulse/muzzle
	icon_state = "muzzle_u_laser"

/obj/effect/projectile/laser/pulse/impact
	icon_state = "impact_u_laser"

//----------------------------
// Pulse rifle effects
//----------------------------
/obj/effect/projectile/pulse/muzzle
	icon_state = "muzzle_pulse"
	light_power = 0.7
	light_color = COLOR_DEEP_SKY_BLUE

/obj/effect/projectile/pulse/impact
	icon_state = "pulse_hit"

//----------------------------
// Shotgun effects
//----------------------------

/obj/effect/projectile/shotgun/impact
	icon_state = "shotgun_hit"

//----------------------------
// divet effects
//----------------------------

/obj/effect/projectile/divet/impact
	icon_state = "divet_hit"

//----------------------------
// Treye beam
//----------------------------
/obj/effect/projectile/trilaser/
	light_color = COLOR_LUMINOL

/obj/effect/projectile/trilaser/tracer
	icon_state = "plasmacutter"

/obj/effect/projectile/trilaser/muzzle
	icon_state = "muzzle_plasmacutter"

/obj/effect/projectile/trilaser/impact
	icon_state = "impact_plasmacutter"




//----------------------------
// Emitter beam
//----------------------------
/obj/effect/projectile/laser/emitter
	light_color = "#00cc00"

/obj/effect/projectile/laser/emitter/tracer
	icon_state = "emitter"

/obj/effect/projectile/laser/emitter/muzzle
	icon_state = "muzzle_emitter"

/obj/effect/projectile/laser/emitter/impact
	icon_state = "impact_emitter"

//----------------------------
// Stun beam
//----------------------------
/obj/effect/projectile/stun/
	light_color = COLOR_YELLOW

/obj/effect/projectile/stun/tracer
	icon_state = "stun"

/obj/effect/projectile/stun/muzzle
	icon_state = "muzzle_stun"

/obj/effect/projectile/stun/impact
	icon_state = "impact_stun"

//----------------------------
// Bullet
//----------------------------
/obj/effect/projectile/bullet/muzzle
	icon_state = "muzzle_bullet"
	light_range = 5
	light_color = COLOR_MUZZLE_FLASH


//----------------------------
// Biological projectiles
//----------------------------
/obj/effect/projectile/bio/muzzle
	light_range = 0
	light_power = 0
	light_color = COLOR_MUZZLE_FLASH
	icon = 'icons/effects/effects.dmi'
	icon_state = "spray"
	color = "#c3933f"
	alpha = 255





//----------------------------
// Acid Bolts
//----------------------------
/obj/effect/projectile/acid/impact
	icon_state = "impact_acid_1"
	light_color = "#ff00dc"
	light_power = 0
	light_range = 0
	lifespan = 12
	random_iconstate = list("impact_acid_1","impact_acid_2","impact_acid_3","impact_acid_4")

/obj/effect/projectile/acid/impact/set_transform(var/matrix/M)
	M *= default_scale
	.=..()


/obj/effect/projectile/acid/impact/small
	default_scale = 0.75
