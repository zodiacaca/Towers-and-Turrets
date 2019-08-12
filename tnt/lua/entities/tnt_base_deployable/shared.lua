
ENT.Type 			= "anim"
ENT.Base 			= "tnt_base_root"
ENT.PrintName	= "tnt_base_deployable"
ENT.Category		= "Towers and Turrets"

ENT.Spawnable			= false
ENT.AdminSpawnable	= false
ENT.AutomaticFrameAdvance = true	-- Animations will look smooth
ENT.AdminOnly = false
ENT.DoNotDuplicate = false

ENT.Turret = ""
ENT.TurretModel = ""
ENT.HasBase = true
ENT.TurretIdleSound = nil
ENT.TurretTurningSound = Sound("TNT_Turret.Turning")
ENT.TurretShootSound = ""
ENT.ImpactExplosionSound = ""
ENT.TurretReloadSound = ""	-- Default level of the sound is 65

ENT.AimAttachment = 1	-- Used for aiming and effects
ENT.MuzzleScale = 1
ENT.MuzzleLightScale = 1
ENT.TracerType = "LaserTracer"
ENT.TracerCount = 1

ENT.ImpactParticle = nil
ENT.ImpactEffect = nil
ENT.ImpactScale = 0

ENT.SettleAngleRandom = false
ENT.CanReload = false

ENT.TurretHealth = 1000
ENT.TurretRange = 1200
ENT.HitDamage = 20
ENT.BlastDamage = 20
ENT.BlastRadius = 128
ENT.DamageScale = 1
ENT.Spread = 0.002
ENT.ClipSize = 30
ENT.TakeAmmoPerShoot = 1
ENT.Cooldown = 2

ENT.AimYawBone = ""
ENT.AimPitchBone = ""	-- These two bones can be the same bone or different like this one
ENT.AimHeight = 128	-- The height of the gun
ENT.YawLimitLeft = 0
ENT.YawLimitRight = 0
ENT.PitchLimitUp = 275	-- Actually it's 360-85
ENT.PitchLimitDown = 45
ENT.ExistAngle = 90	-- It's 90 in this model
ENT.RecoilBone = nil

ENT.RotateSpeed = 35
ENT.RotateSpeedRatio = 0.75
ENT.ReloadSpeed = 0.135
ENT.UpdateDelayLong = 4
ENT.UpdateDelayShort = 0.5

ENT.RecoilOffset = 200
ENT.RecoilRecoverPerThink = 12.5 -- Use a number that the result of 1 divide this number is still a rational number

ENT.HasDamagedState = false
ENT.FiresOffset = 20
ENT.FiresHeight = 42
