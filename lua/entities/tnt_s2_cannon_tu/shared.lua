
ENT.Type 			= "anim"
ENT.Base 			= "tnt_turret_base"
ENT.PrintName	= "Cannon Turret"
ENT.Category		= "Towers N Turrets"

ENT.Spawnable			= true
ENT.AdminSpawnable	= true
ENT.AutomaticFrameAdvance = true	-- Animations will look smooth
ENT.AdminOnly = true
ENT.DoNotDuplicate = true

ENT.Turret = "tnt_s2_cannon_tu"
ENT.TurretModel = "models/tnt/cannon_turret_lv1.mdl"
ENT.TurretIdleSound = nil
ENT.TurretTurningSound = Sound("TNT_Turret.Turning")
ENT.TurretShootSound = Sound("tnt/cannon/tnt_cannon_fire2.wav")
ENT.ImpactExplosionSound = Sound("tnt/explosion1.ogg")
ENT.TurretReloadSound = ""	-- Default level of the sound is 65

ENT.AimAttachment = 1	-- Used for aiming and effects
ENT.MuzzleScale = 1
ENT.MuzzleLightScale = 1
ENT.TracerCount = 5

ENT.ImpactParticle = "tnt_cannon_blast"
ENT.ImpactEffect = nil
ENT.ImpactScale = 0

ENT.SettleAngleRandom = false
ENT.CanReload = false

ENT.TurretHealth = 600
ENT.TurretRange = 4000
ENT.HitDamage = 30
ENT.BlastDamage = 48
ENT.BlastRadius = 128
ENT.DamageScale = 1
ENT.Spread = 0.002
ENT.ClipSize = 1
ENT.TakeAmmoPerShoot = 0
ENT.Cooldown = 2

ENT.EjectEffect = nil
ENT.EjectOffset = 0

ENT.AimYawBone = "Slave_Main"
ENT.AimPitchBone = "Slave_Rotation_Upper"	-- These two bones can be the same bone or different like this one
ENT.AimHeight = 45	-- The height of the gun
ENT.YawLimitLeft = 0
ENT.YawLimitRight = 0
ENT.PitchLimitUp = 275
ENT.PitchLimitDown = 45
ENT.ExistAngle = 90	-- It's 90 in this model
ENT.RecoilBone = "Slave_Barrel"

ENT.AngularSpeed = 8
ENT.ReloadSpeed = 0
ENT.UpdateDelayLong = 4
ENT.UpdateDelayShort = 0.5

ENT.RecoilOffset = 200
ENT.RecoilRecoverPerThink = 12.5 -- Use a number that the result of 1 divide this number is still a rational number

ENT.HasDamagedState = true
ENT.FiresOffset = 15
ENT.FiresHeight = 16

ENT.DisplayOffset = -72