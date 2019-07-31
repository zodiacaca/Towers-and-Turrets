
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

include("entities/tnt_att_m60/exclusive_effects.lua")


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

	self.LastShoot = CurTime()
	self:SetRounds(self.ClipSize)
	self.Reloaded = true
	self:SetReloadTime(CurTime())
	self.LoopDelay = 0
	self.Fires = 0
	self.Num = 0
	self.Explored = false
	self.PlanB = false
	self:SetReady(true)
	self.Owner = self:GetCreator()
	self:SetTurretOwner(self.Owner)

	self.YawMotorThrottle = 0
	self.PitchMotorThrottle = 0
	self.MinTheta = { x = 0, y = 0 }

	self:SetTrigger(true)	-- Touch

end

function ENT:GetTracer()

	local td = {}
		td.start = self.Owner:EyePos() + self.Owner:EyeAngles():Forward() * 256
		td.endpos = td.start + self.Owner:EyeAngles():Forward() * 30000
		td.filter = { self.Entity, self.Owner }
	local tr = util.TraceLine(td)

	return tr
end

function ENT:InitMeta()

	self.YawBoneIndex = nil
	self.YawBonePos = nil
	self.YawBoneAng = nil
	self.PitchBoneIndex = nil
	self.PitchBonePos = nil
	self.PitchBoneAng = nil

	self.YawBonePos_w = nil
	self.YawBoneAng_w = nil
	self.PitchBonePos_w = nil
	self.PitchBoneAng_w = nil

	self.AngularSpeed = Angle(0, 0, 0)
	self.PitchSpeed = Angle(0, 0, 0)

	self.AttPos = nil
	self.AttAng = nil

	self.RecoilBoneIndex = nil
	self.RecoilBonePos = nil
	self.RecoilBoneAng = nil

	self.AimPosition_w = nil
	self.AimAngle_w = nil
	self.AimPosition = nil
	self.AimAngle = nil

	self.AngleAimYaw = nil
	self.AngleAimPitch = nil
	self.YawDiff = nil
	self.PitchDiff = nil

	self.YawClampDelta = nil
	self.PitchClampDelta = nil

	self.p_AngDiff = { y = 0, p = 0 }
	self.p_YawBoneAng = Angle(0, 0, 0)
	self.p_PitchBoneAng = Angle(0, 0, 0)
	self.p_AngularSpeed = Angle(0, 0, 0)
	self.p_PitchSpeed = Angle(0, 0, 0)

end

function ENT:UpdateTransformation()

	self.YawBoneIndex = self.Entity:LookupBone(self.AimYawBone)
	self.YawBonePos_w, self.YawBoneAng_w = self.Entity:GetBonePosition(self.YawBoneIndex)
	self.PitchBoneIndex = self.Entity:LookupBone(self.AimPitchBone)
	self.PitchBonePos_w, self.PitchBoneAng_w = self.Entity:GetBonePosition(self.PitchBoneIndex)
	self.YawBonePos, self.YawBoneAng = self:TranslateCoordinateSystem(self.YawBonePos_w, self.YawBoneAng_w)
	self.PitchBonePos, self.PitchBoneAng = self:TranslateCoordinateSystem(self.PitchBonePos_w, self.PitchBoneAng_w)

	self.AngularSpeed = self.YawBoneAng - self.p_YawBoneAng
	self.PitchSpeed = self.PitchBoneAng - self.p_PitchBoneAng

end

function ENT:PostTransformation()

	self.p_YawBoneAng = self.YawBoneAng
	self.p_PitchBoneAng = self.PitchBoneAng
	self.p_AngularSpeed = self.AngularSpeed
	self.p_PitchSpeed = self.PitchSpeed

end

function ENT:TurningTurret(ct)

	self:ReloadAmmo(ct)
	if (self:GetReady() == true) and self.Owner:IsValid() and self.Owner:InVehicle() and (ct > self:GetReloadTime()) then

		-- Angles between the target and the bones
		self.AimPosition_w = self:GetTracer().HitPos
		self.AimPosition, self.AimAngle = self:TranslateCoordinateSystem(self.AimPosition_w, Angle(0, 0, 0))
		self.AngleAimYaw = (self.AimPosition - self.YawBonePos):Angle()
		self.AngleAimPitch = (self.AimPosition - self.PitchBonePos):Angle()
		if self.AngleAimPitch.x >= self.PitchLimitDown && self.AngleAimPitch.x <= self.PitchLimitUp then
			if self.TurningLoop then
				self.TurningLoop:Stop()
			end
			return
		end

		-- The angle differences between them
		self.YawDiff = self.AngleAimYaw - self.YawBoneAng
		self.PitchDiff = self.AngleAimPitch - self.PitchBoneAng

		-- Make sure the turret don't turn like a maniac
		if math.abs(self.YawDiff.y) > 180 then
			self.YawDiff.y = -self.YawDiff.y/math.abs(self.YawDiff.y) * (360 - math.abs(self.YawDiff.y))
		end
		if math.abs(self.PitchDiff.x) > 180 then
			self.PitchDiff.x = -self.PitchDiff.x/math.abs(self.PitchDiff.x) * (360 - math.abs(self.PitchDiff.x))
		end
		if math.abs(self.YawDiff.y) < self.MinTheta.y then
			self.YawDiff.y = 0
		end
		if math.abs(self.PitchDiff.x) < self.MinTheta.x then
			self.PitchDiff.x = 0
		end

		-- throttle
		if self.p_AngDiff.y * self.YawDiff.y <= 0 then
			self.YawMotorThrottle = 0
		else
			self.YawMotorThrottle = Lerp(0.1, self.YawMotorThrottle, math.Clamp(math.abs(self.YawDiff.y) / self.RotateSpeed, 0, 1))
		end
		if self.p_AngDiff.p * self.PitchDiff.p <= 0 then
			self.PitchMotorThrottle = 0
		else
			self.PitchMotorThrottle = Lerp(0.1, self.PitchMotorThrottle, math.Clamp(math.abs(self.PitchDiff.x) / (self.RotateSpeed * self.RotateSpeedRatio), 0, 1))
		end
		self.p_AngDiff.y = self.YawDiff.y
		self.p_AngDiff.p = self.PitchDiff.p

		local as = self.AngularSpeed
		if math.abs(as.y) <= self.MinTheta.y then
			as.y = self.YawMotorThrottle * self.RotateSpeed
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
		self.YawDiff.y = math.Clamp(self.YawDiff.y, -self.YawClampDelta, self.YawClampDelta) * self.YawMotorThrottle
		if math.abs(self.YawDiff.y) > 0 and math.abs(self.YawDiff.y) < self.MinTheta.y then
			self.YawDiff.y = math.abs(self.YawDiff.y) / self.YawDiff.y * self.MinTheta.y
		end
		self.PitchDiff.x = math.Clamp(self.PitchDiff.x, -self.PitchClampDelta, self.PitchClampDelta) * self.PitchMotorThrottle
		if math.abs(self.PitchDiff.x) > 0 and math.abs(self.PitchDiff.x) < self.MinTheta.x then
			self.PitchDiff.x = math.abs(self.PitchDiff.x) / self.PitchDiff.x * self.MinTheta.x
		end

		-- Turning
		self.Entity:ManipulateBoneAngles(self.YawBoneIndex, Angle(0, self.YawBoneAng.y - self.ExistAngle + self.YawDiff.y, 0))
		self.Entity:ManipulateBoneAngles(self.PitchBoneIndex, Angle(self.PitchBoneAng.x + self.PitchDiff.x, 0, 0))

		-- self:TurningSound(ct)
		self:Aiming(ct)

	else

		if self.TurningLoop then self.TurningLoop:Stop() end

	end

end

function ENT:TurningSound(ct)

	if self.TurretTurningSound == nil then return end

	local ang = (self:GetTracer().HitPos - self.Entity:GetAttachment(self.AimAttachment).Pos):Angle()

	if self.TurningLoop then
		if math.abs(self.Entity:GetAttachment(self.AimAttachment).Ang.y - ang.y) > 1 then
			self.TurningLoop:Play()
			self.TurningLoop:ChangePitch(100 * GetConVarNumber("host_timescale"))
			self.LoopDelay = ct + 0.2
		elseif  ct > self.LoopDelay then
			self.TurningLoop:Stop()
		end
	else
		self.TurningLoop = CreateSound(self.Entity, self.TurretTurningSound)
	end

end

function ENT:Aiming(ct)

	if self.AimAttachment == nil then
		print("AimAttachment expected, got nil")
		return
	end

	self.AttPos = self.Entity:GetAttachment(self.AimAttachment).Pos
	self.AttAng = self.Entity:GetAttachment(self.AimAttachment).Ang

	if (ct > (self.LastShoot + self.Cooldown)) then
		if self.Owner:KeyDown(GetConVarNumber("tnt_turret_fire")) then
			self:Shoot(ct, self.AttPos, self.AttAng)
		end
	end

end

function ENT:ReloadAmmo(ct)

	if !self.Reloaded and (ct > self:GetReloadTime()) then
		self:SetRounds(self.ClipSize)
		self.Reloaded = true
	end

end
