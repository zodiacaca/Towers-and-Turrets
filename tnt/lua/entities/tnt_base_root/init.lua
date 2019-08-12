
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

include("sv_damage.lua")
include("sv_shoot.lua")
include("sv_interact.lua")
include("sv_remove.lua")
include("sv_cube.lua")

/*---------------------------------------------------------
   Name: Initialize
---------------------------------------------------------*/
function ENT:Initialize()

	self:PrecacheParticles()

	local model = (self.TurretModel)

	self.Entity:SetModel(model)

	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:DrawShadow(false)

	local phys = self.Entity:GetPhysicsObject()
	if phys:IsValid() then
		-- phys:EnableGravity(false)
		-- phys:EnableCollisions(false)
		-- phys:EnableMotion(false)
		-- phys:EnableDrag(false)
		phys:Wake()
	end

	self.Entity:SetUseType(SIMPLE_USE)

	self:SetHealth(self.TurretHealth)

	if self.SettleAngleRandom then
		self.Entity:ManipulateBoneAngles(self.Entity:LookupBone(self.AimYawBone), Angle(0, math.random(0,360), 0))
	end

	self:InitMeta()

	self.YawMotorThrottle = 0
	self.PitchMotorThrottle = 0
	self.MinTheta = { x = 0, y = 0 }
	self.Collided = false
	self.LastTargetTime = CurTime()
	self.LastShoot = CurTime()
	self.UpdateDelay = self.UpdateDelayLong
	self:SetRounds(self.ClipSize)
	self.Reloaded = true
	self:SetReloadTime(CurTime())
	self.Fires = 0
	self.Explored = false
	self.PlanB = false
	self.Owner = self:GetCreator()
	self.TurningLoop = CreateSound(self.Entity, self.TurretTurningSound)

	self:SetTrigger(true)	-- Touch

	if self.HasBase then
		self:SetReady(false)
		self:CreateIndicator()
	else
		self:SetReady(true)
		if !string.find(self.Turret, "ctrl") then
			self:CreateNPCCube()
		end
	end

end

function ENT:PrecacheParticles()

	if self.ImpactParticle != nil then
		PrecacheParticleSystem(self.ImpactParticle)
	end

end

/*---------------------------------------------------------
   Recive the new statistics from stool
---------------------------------------------------------*/
function ENT:SetDamageScale( scale )
	self.DamageScale = scale
end

function ENT:SetSpread( spread )
	self.Spread = spread/10
end

function ENT:SetTurretRange( range )
	self.TurretRange = range
end

function ENT:SetCooldown( cooldown )
	self.Cooldown = cooldown
end

function ENT:SetBlastRadius( radius )
	self.BlastRadius = radius
end

function ENT:SetTakeAmmoPerShoot( ammo )
	self.TakeAmmoPerShoot = ammo
end

function ENT:SetFriends( friend )
	table.insert(tntfriends, string.lower(friend))
end

local YawBoneIndex, YawBonePos, YawBoneAng, PitchBoneIndex, PitchBonePos, PitchBoneAng, TargetBoneIndex
local YawBonePos_w, YawBoneAng_w, PitchBonePos_w, PitchBoneAng_w
local AimPosition_w, AimAngle_w, AimPosition, AimAngle, AngleAimYaw, AngleAimPitch, YawDiff, PitchDiff, newpos, newang
local RecoilBoneIndex, RecoilBonePos, RecoilBoneAng
local AttPos, AttAng
local recoil, back

function ENT:InitMeta()

	self.YawClampDelta = nil
	self.PitchClampDelta = nil

	self.AngularSpeed = Angle(0, 0, 0)
	self.PitchSpeed = Angle(0, 0, 0)

	self.p_AngDiff = { y = 0, p = 0 }
	self.p_YawBoneAng = Angle(0, 0, 0)
	self.p_PitchBoneAng = Angle(0, 0, 0)
	self.p_AngularSpeed = Angle(0, 0, 0)
	self.p_PitchSpeed = Angle(0, 0, 0)

end

/*---------------------------------------------------------
   Name: Think
---------------------------------------------------------*/
function ENT:Think()

	if self.HasBase and !self.Collided then
		local phys = self:GetPhysicsObject()
		if ( IsValid( phys ) ) then phys:AddVelocity( -self:GetUp() * 16 ) end
	end

	local CT = CurTime()

	if self.TurretIdleSound != nil then
		if self.LoopSound then
			if !(self:GetReady() == true) or !(CT > self:GetReloadTime()) then
				self.LoopSound:ChangeVolume(0, 0.5)
			else
				self.LoopSound:ChangeVolume(1, 0.5)
				self.LoopSound:ChangePitch(100 * GetConVarNumber("host_timescale"))
			end
		else
			self.LoopSound = CreateSound(self.Entity, Sound(self.TurretIdleSound))
			self.LoopSound:Play()
		end
	end

	self:UpdateTransformation()
	self:TurningTurret(CT)
	self:Recoil(CT)
	self:ReloadAmmo(CT)
	self:PostTransformation()

	self:RotateNPCCube(CT)

	self:NextThink(CurTime())

	return true
end

function ENT:UpdateTransformation()

	YawBoneIndex = self.Entity:LookupBone(self.AimYawBone)
	YawBonePos_w, YawBoneAng_w = self.Entity:GetBonePosition(YawBoneIndex)
	PitchBoneIndex = self.Entity:LookupBone(self.AimPitchBone)
	PitchBonePos_w, PitchBoneAng_w = self.Entity:GetBonePosition(PitchBoneIndex)
	YawBonePos, YawBoneAng = self:TranslateCoordinateSystem(YawBonePos_w, YawBoneAng_w)
	PitchBonePos, PitchBoneAng = self:TranslateCoordinateSystem(PitchBonePos_w, PitchBoneAng_w)

	self.AngularSpeed = YawBoneAng - self.p_YawBoneAng
	self.PitchSpeed = PitchBoneAng - self.p_PitchBoneAng

end

function ENT:PostTransformation()

	self.p_YawBoneAng = YawBoneAng
	self.p_PitchBoneAng = PitchBoneAng
	self.p_AngularSpeed = self.AngularSpeed
	self.p_PitchSpeed = self.PitchSpeed

end

-- ENT.Time = 0
function ENT:TurningTurret(ct)

	if GetConVar("ai_disabled"):GetBool() then return end
	if !IsValid(self.NPCCube) then self.TurningLoop:Stop() return end

	-- if ct > self.Time then
		-- self.Time = ct + 3
		-- local tbl = {
			-- ["tgt_time"] = self.LastTargetTime,
			-- ["delay"] = self.UpdateDelay,
			-- ["planB"] = self.PlanB,
			-- ["tgt"] = self.Target,
			-- ["old_tgt"] = self.OldTarget,
			-- ["tgt = old_tgt"] = (self.Target == self.OldTarget)
		-- }
		-- PrintTable(tbl)
	-- end

	if self.PlanB then
		self.Target = self:GetTargetB()
	else
		self.Target = self:GetTargetA()
	end
	self:UpdateTarget(ct, self.Target)

	if (self:GetReady() == true) and (ct > self:GetReloadTime()) and (self.Target != nil) then

		-- Angles between the target and the bones
		TargetBoneIndex = self.Target:LookupBone(self.Target:GetBoneName(1))
		if TargetBoneIndex == nil then
			self.PlanB = !self.PlanB
			return
		end
		AimPosition_w, AimAngle_w = self.Target:GetBonePosition(TargetBoneIndex)
		AimPosition, AimAngle = self:TranslateCoordinateSystem(AimPosition_w, AimAngle_w)
		AngleAimYaw = (AimPosition - YawBonePos):Angle()
		AngleAimPitch = (AimPosition - PitchBonePos):Angle()
		if AngleAimPitch.x >= self.PitchLimitDown && AngleAimPitch.x <= self.PitchLimitUp then
			if self.TurningLoop then
				self.TurningLoop:Stop()
			end
			self.PlanB = !self.PlanB
			return
		end

		-- The angle differences between them
		YawDiff = AngleAimYaw - YawBoneAng
		PitchDiff = AngleAimPitch - PitchBoneAng

		-- Make sure the turret don't turn like a maniac
		if math.abs(YawDiff.y) > 180 then
			YawDiff.y = -YawDiff.y/math.abs(YawDiff.y) * (360 - math.abs(YawDiff.y))
		end
		if math.abs(PitchDiff.x) > 180 then
			PitchDiff.x = -PitchDiff.x/math.abs(PitchDiff.x) * (360 - math.abs(PitchDiff.x))
		end
		if math.abs(YawDiff.y) < self.MinTheta.y then
			YawDiff.y = 0
		end
		if math.abs(PitchDiff.x) < self.MinTheta.x then
			PitchDiff.x = 0
		end

		-- throttle
		if self.p_AngDiff.y * YawDiff.y <= 0 then
			self.YawMotorThrottle = 0
		else
			self.YawMotorThrottle = Lerp(0.1, self.YawMotorThrottle, math.Clamp(math.abs(YawDiff.y) / self.RotateSpeed, 0, 1))
		end
		if self.p_AngDiff.p * PitchDiff.p <= 0 then
			self.PitchMotorThrottle = 0
		else
			self.PitchMotorThrottle = Lerp(0.1, self.PitchMotorThrottle, math.Clamp(math.abs(PitchDiff.x) / (self.RotateSpeed * self.RotateSpeedRatio), 0, 1))
		end
		self.p_AngDiff.y = YawDiff.y
		self.p_AngDiff.p = PitchDiff.p

		local as = self.AngularSpeed
		if math.abs(as.y) <= self.MinTheta.y then	-- vehicle shaking
			as.y = self.YawMotorThrottle * self.RotateSpeed	-- ManipulateBone updates every 2 Think
			if self.p_AngularSpeed.y != 0 then
				as.y = math.min(as.y, math.abs(self.p_AngularSpeed.y) + self.RotateSpeed / 7.5)
			end
		else
			if math.abs(as.y) > 180 then
				as.y = -as.y/math.abs(as.y) * (360 - math.abs(as.y))
			end
		end
		as.y = math.abs(as.y)

		local ps = self.PitchSpeed
		if math.abs(ps.x) <= self.MinTheta.x then
			ps.x = self.PitchMotorThrottle * self.RotateSpeed * self.RotateSpeedRatio
			if self.p_PitchSpeed.x != 0 then
				ps.x = math.min(ps.x, math.abs(self.p_PitchSpeed.x) + self.RotateSpeed * self.RotateSpeedRatio / 10)
			end
		else
			if math.abs(ps.x) > 180 then
				ps.x = -ps.x/math.abs(ps.x) * (360 - math.abs(ps.x))
			end
		end
		ps.x = math.abs(ps.x)

		self.MinTheta.y = math.Clamp(self.YawMotorThrottle * 0.5, 0.05, 1)
		self.MinTheta.x = math.Clamp(self.PitchMotorThrottle * 0.5, 0.05, 1)
		self.YawClampDelta = self.RotateSpeed * GetConVarNumber("host_timescale") * (as.y / self.RotateSpeed)
		self.PitchClampDelta = self.RotateSpeed * GetConVarNumber("host_timescale") * (ps.x / self.RotateSpeed)
		YawDiff.y = math.Clamp(YawDiff.y, -self.YawClampDelta, self.YawClampDelta) * self.YawMotorThrottle
		if math.abs(YawDiff.y) > 0 and math.abs(YawDiff.y) < self.MinTheta.y then
			YawDiff.y = math.abs(YawDiff.y) / YawDiff.y * self.MinTheta.y
		end
		PitchDiff.x = math.Clamp(PitchDiff.x, -self.PitchClampDelta, self.PitchClampDelta) * self.PitchMotorThrottle
		if math.abs(PitchDiff.x) > 0 and math.abs(PitchDiff.x) < self.MinTheta.x then
			PitchDiff.x = math.abs(PitchDiff.x) / PitchDiff.x * self.MinTheta.x
		end

		-- Turning
		self.Entity:ManipulateBoneAngles(YawBoneIndex, Angle(0, YawBoneAng.y - self.ExistAngle + YawDiff.y, 0))
		self.Entity:ManipulateBoneAngles(PitchBoneIndex, Angle(PitchBoneAng.x + PitchDiff.x, 0, 0))
		-- print(PitchDiff.x)
		self:TurningSound()
		self:Aiming(ct)

	else

		self.YawMotorThrottle = 0
		self.PitchMotorThrottle = 0
		-- self:EliminateHesitation()
		self.UpdateDelay = self.UpdateDelayShort
		if self.TurningLoop then self.TurningLoop:Stop() end

	end

end

function ENT:TranslateCoordinateSystem(pos, ang)

	newpos, newang = WorldToLocal(pos, ang, self.Entity:GetPos(), self.Entity:GetAngles())

	return newpos, newang
end

function ENT:TurningSound()

	if self.TurretTurningSound == nil then return end

	if self.TurningLoop then
		if self.p_AngDiff.y != YawDiff.y then
			self.TurningLoop:Play()
			self.TurningLoop:ChangeVolume(math.Clamp(self.YawMotorThrottle, 0.5, 1))
			self.TurningLoop:ChangePitch(100 * GetConVarNumber("host_timescale"))
		else
			self.TurningLoop:Stop()
		end
	else
		self.TurningLoop = CreateSound(self.Entity, self.TurretTurningSound)
	end

end
