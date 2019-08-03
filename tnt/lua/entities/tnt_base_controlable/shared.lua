
ENT.Type 			= "anim"
ENT.Base 			= "tnt_base_attachable"
ENT.PrintName	= "tnt_base_controlable"
ENT.Category		= "Towers and Turrets"

ENT.Spawnable			= false
ENT.AdminSpawnable	= false
ENT.AutomaticFrameAdvance = true	-- Animations will look smooth
ENT.AdminOnly = false
ENT.DoNotDuplicate = false

ENT.Turret = ""
ENT.TurretModel = ""
ENT.TurretIdleSound = nil
ENT.TurretTurningSound = Sound("TNT_Turret.Turning")
ENT.TurretShootSound = ""
ENT.ImpactExplosionSound = ""
ENT.TurretReloadSound = ""	-- Default level of the sound is 65

ENT.AimAttachment = 1	-- Used for aiming and effects
ENT.MuzzleScale = 1
ENT.MuzzleLightScale = 1
ENT.TracerType = "Tracer"
ENT.TracerCount = 1

ENT.ImpactParticle = nil
ENT.ImpactEffect = nil
ENT.ImpactScale = 0

ENT.SettleAnim = false
ENT.SettleAngleRandom = false
ENT.CanReload = true	-- not used, only literal meaning here

ENT.TurretHealth = 300
ENT.TurretRange = 4000
ENT.HitDamage = 20
ENT.BlastDamage = 0
ENT.BlastRadius = 0
ENT.DamageScale = 1
ENT.Spread = 0.01
ENT.ClipSize = 50
ENT.TakeAmmoPerShoot = 1
ENT.Cooldown = 1

ENT.EjectEffect = nil
ENT.EjectOffset = 0

ENT.AimYawBone = ""
ENT.AimPitchBone = ""	-- These two bones can be the same bone or different like this one
ENT.AimHeight = 64	-- The height of the gun
ENT.YawLimitLeft = 0
ENT.YawLimitRight = 0
ENT.PitchLimitUp = 275
ENT.PitchLimitDown = 85
ENT.ExistAngle = 90	-- It's 90 in this model
ENT.RecoilBone = nil

ENT.RotateSpeed = 3.5
ENT.RotateSpeedRatio = 0.75
ENT.ReloadSpeed = 0.1

ENT.RecoilOffset = 80
ENT.RecoilRecoverPerThink = 20 -- Use a number that the result of 1 divide this number is still a rational number

ENT.HasDamagedState = true
ENT.FiresOffset = 0
ENT.FiresHeight = 0

ENT.DisplayOffset = -46

function ENT:SetupDataTables()
	self:NetworkVar( "Bool", 0, "Ready" )
	self:NetworkVar( "Float", 1, "Rounds" )
	self:NetworkVar( "Float", 2, "ReloadTime" )
	self:NetworkVar( "Entity", 3, "TurretOwner" )
end