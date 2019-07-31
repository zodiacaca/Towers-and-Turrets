
ENT.Type 			= "anim"
ENT.Base 			= "tnt_base_deployable"
ENT.PrintName	= "Cannon Tower"
ENT.Category		= "Towers and Turrets"

ENT.Spawnable			= true
ENT.AdminSpawnable	= true
ENT.AutomaticFrameAdvance = true	-- Animations will look smooth
ENT.AdminOnly = false
ENT.DoNotDuplicate = false

ENT.Tower = "tnt_dply_s2_cannon"
ENT.TowerModel = "models/tnt/cannon_lv3.mdl"
ENT.TowerIdleSound = nil
ENT.TowerTurningSound = Sound("TNT_Turret.Turning")
ENT.TowerShootSound = Sound("tnt/cannon/tnt_cannon_fire1.wav")
ENT.ImpactExplosionSound = Sound("tnt/explosion1.ogg")
ENT.TowerReloadSound = Sound("tnt/cannon/tnt_cannon_reload1.wav")	-- Default level of the sound is 65

ENT.AimAttachment = 1	-- Used for aiming and effects
ENT.MuzzleScale = 1
ENT.MuzzleLightScale = 1
ENT.TracerCount = 0

ENT.ImpactParticle = "tnt_cannon_blast"
ENT.ImpactEffect = nil
ENT.ImpactScale = 0

ENT.SettleAnim = true
ENT.SettleAngleRandom = true
ENT.CanReload = true

ENT.TowerHealth = 600
ENT.TowerRange = 1200
ENT.HitDamage = 20
ENT.BlastDamage = 5
ENT.BlastRadius = 128
ENT.DamageScale = 1
ENT.Spread = 0.002
ENT.ClipSize = 60
ENT.TakeAmmoPerShoot = 1
ENT.Cooldown = 0.75

ENT.AimYawBone = "Slave_Main"
ENT.AimPitchBone = "Slave_Rotation_Upper"	-- These two bones can be the same bone or different like this one
ENT.AimHeight = 128	-- The height of the gun
ENT.YawLimitLeft = 0
ENT.YawLimitRight = 0
ENT.PitchLimitUp = 275	-- Actually it's 360-85
ENT.PitchLimitDown = 45
ENT.ExistAngle = 90	-- It's 90 in this model
ENT.RecoilBone = "Slave_Barrel_Mid"
ENT.RecoilBoneAdditional_1 = "Slave_Barrel_L"
ENT.RecoilBoneAdditional_2 = "Slave_Barrel_R"

ENT.RotateSpeed = 8
ENT.ReloadSpeed = 0.135
ENT.UpdateDelayLong = 4
ENT.UpdateDelayShort =0.5

ENT.RecoilOffset = 200
ENT.RecoilRecoverPerThink = 12.5 -- Use a number that the result of 1 divide this number is still a rational number

ENT.HasDamagedState = true
ENT.FiresOffset = 20
ENT.FiresHeight = 42