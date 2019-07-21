
ENT.Type 			= "anim"
ENT.Base 			= "tnt_turret_base"
ENT.PrintName	= "M60 Turret"
ENT.Category		= "Towers and Turrets"

ENT.Spawnable			= true
ENT.AdminSpawnable	= true
ENT.AutomaticFrameAdvance = true
ENT.AdminOnly = true
ENT.DoNotDuplicate = false

ENT.Turret = "tnt_m60"
ENT.TurretModel = "models/tnt/m60_turret.mdl"
ENT.TurretIdleSound = nil
ENT.TurretTurningSound = Sound("TNT_M60.Turning")
ENT.TurretShootSound = Sound("tnt/m60/m60-1.wav")
ENT.ImpactExplosionSound = ""
ENT.TurretReloadSound = Sound("tnt/m60/m60_reload1.wav")	-- Default level of the sound is 65

ENT.AimAttachment = 1	-- Used for aiming and effects
ENT.MuzzleScale = 1
ENT.MuzzleLightScale = 0.2
ENT.TracerType = "Tracer"
ENT.TracerCount = 5

ENT.ImpactParticle = nil
ENT.ImpactEffect = nil
ENT.ImpactScale = 0

ENT.SettleAngleRandom = false
ENT.CanReload = true

ENT.TurretHealth = 300
ENT.TurretRange = 2500
ENT.HitDamage = 20
ENT.BlastDamage = 0
ENT.BlastRadius = 0
ENT.DamageScale = 1
ENT.Spread = 0.01
ENT.ClipSize = 200
ENT.TakeAmmoPerShoot = 1
ENT.Cooldown = 0.1

ENT.EjectEffect = "RifleShellEject"
ENT.EjectOffset = -28

ENT.AimYawBone = "Bone001"
ENT.AimPitchBone = "Arm_02"	-- These two bones can be the same bone or different like this one
ENT.AimHeight = 12	-- The height of the gun
ENT.YawLimitLeft = 0
ENT.YawLimitRight = 0
ENT.PitchLimitUp = 275
ENT.PitchLimitDown = 85
ENT.ExistAngle = 90	-- It's 90 in this model
ENT.RecoilBone = "bolt"

ENT.AngularSpeed = 3.5
ENT.ReloadSpeed = 0.1
ENT.UpdateDelayLong = 2
ENT.UpdateDelayShort = 0.5

ENT.RecoilOffset = 80
ENT.RecoilRecoverPerThink = 20 -- Use a number that the result of 1 divide this number is still a rational number

ENT.HasDamagedState = false
ENT.FiresOffset = 0
ENT.FiresHeight = 0

ENT.DisplayOffset = -46