
game.AddParticles("particles/tnt_fx.pcf")

if ( CLIENT ) then
	language.Add( "tnt_m60", "M60 Turret" )
	language.Add( "tnt_s2_cannon_to", "Cannon Tower" )
	language.Add( "tnt_s2_cannon_tu", "Cannon Turret" )
	language.Add( "tnt_s2_cannon_ve", "Cannon Turret" )
	language.Add( "tnt_s2_lightning", "Lightning Tower" )
	language.Add( "tnt_towerbase", "Tower Base" )
end

CreateClientConVar("tnt_turret_fire", IN_JUMP, true)
CreateConVar("tnt_attack_player", 0, { FCVAR_ARCHIVE, FCVAR_NOTIFY })
CreateConVar("tnt_attack_owner", 0, { FCVAR_ARCHIVE, FCVAR_NOTIFY })

tntfriends = {
	"npc_monk",
	"npc_citizen",
	"npc_alyx",
	"npc_barney",
	"npc_kleiner",
	"npc_mossman",
	"npc_eli",
	"npc_gman",
	"npc_dog",
	"npc_magnusson",
	"npc_vortigaunt"
	}

tntfilter = {
	"bullseye_strider_focus",	-- Has some conflicts
	"npc_enemyfinder",
	"npc_helicopter",
	"npc_turret_floor"
	}

tntgunfilter = {
	"npc_strider",
	"npc_combinegunship"
	}

sound.Add({
	name = 			"TNT_Turret.Turning",
	channel =			CHAN_STATIC,
	volume =			1.0,
	level =				100,
	pitch =				100,
	sound = 			"tnt/turret_turning1.wav"
})

sound.Add({
	name = 			"TNT_Turret_ve.Turning",
	channel =			CHAN_STATIC,
	volume =			0.4,
	level =				100,
	pitch =				100,
	sound = 			"tnt/turret_turning2.wav"
})

sound.Add({
	name = 			"S2_Lightning.Idle",
	channel =			CHAN_STATIC,
	volume =			1.0,
	level =				60,
	pitch =				100,
	sound = 			"tnt/lightning/lightning_idle1.wav"
})

sound.Add({
	name = 			"TNT_M60.Turning",
	channel =			CHAN_STATIC,
	volume =			1.0,
	level =				90,
	pitch =				100,
	sound = 			"tnt/turret_turning1.wav"
})