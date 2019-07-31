
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

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

	self.ActivatedTime = CurTime()
	self.LastShoot = CurTime()
	self:SetRounds(self.ClipSize)
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

local CT, target
local YawBoneIndex, YawBonePos, YawBoneAng, PitchBoneIndex, PitchBonePos, PitchBoneAng, BoneIndexT
local YawBonePos_w, YawBoneAng_w, PitchBonePos_w, PitchBoneAng_w
local aimpos_w, aimang_w, aimpos, aimang, ang_aim_y, ang_aim_p, yawDiff, pitchDiff, newpos, newang, YawClampDelta, PitchClampDelta
local RecoilBoneIndex, RecoilBonePos, RecoilBoneAng
local attpos, attang
local recoil, back
local p_AngDiff = { y = 0, p = 0 }
local p_YawBoneAng, p_PitchBoneAng = Angle(0, 0, 0), Angle(0, 0, 0)
local AngularSpeed, PitchSpeed = Angle(0, 0, 0), Angle(0, 0, 0)
local p_AngularSpeed, p_PitchSpeed = Angle(0, 0, 0), Angle(0, 0, 0)

function ENT:UpdateTransformation()

	YawBoneIndex = self.Entity:LookupBone(self.AimYawBone)
	YawBonePos_w, YawBoneAng_w = self.Entity:GetBonePosition(YawBoneIndex)
	PitchBoneIndex = self.Entity:LookupBone(self.AimPitchBone)
	PitchBonePos_w, PitchBoneAng_w = self.Entity:GetBonePosition(PitchBoneIndex)
	YawBonePos, YawBoneAng = self:TranslateCoordinateSystem(YawBonePos_w, YawBoneAng_w)
	PitchBonePos, PitchBoneAng = self:TranslateCoordinateSystem(PitchBonePos_w, PitchBoneAng_w)

	AngularSpeed = YawBoneAng - p_YawBoneAng
	PitchSpeed = PitchBoneAng - p_PitchBoneAng

end

function ENT:PostTransformation()

	p_YawBoneAng = YawBoneAng
	p_PitchBoneAng = PitchBoneAng
	p_AngularSpeed = AngularSpeed
	p_PitchSpeed = PitchSpeed

end

function ENT:TurningTurret(ct)

	self:ReloadAmmo(ct)
	if (self:GetReady() == true) and self.Owner:IsValid() and self.Owner:InVehicle() and (ct > self:GetReloadTime()) then

		-- Angles between the target and the bones
		aimpos_w = self:GetTracer().HitPos
		aimpos, aimang = self:TranslateCoordinateSystem(aimpos_w, Angle(0, 0, 0))
		ang_aim_y = (aimpos - YawBonePos):Angle()
		ang_aim_p = (aimpos - PitchBonePos):Angle()
		if ang_aim_p.x >= self.PitchLimitDown && ang_aim_p.x <= self.PitchLimitUp then
			if self.TurningLoop then
				self.TurningLoop:Stop()
			end
			return
		end

		-- The angle differences between them
		yawDiff = ang_aim_y - YawBoneAng
		pitchDiff = ang_aim_p - PitchBoneAng

		-- Make sure the turret don't turn like a maniac
		if math.abs(yawDiff.y) > 180 then
			yawDiff.y = -yawDiff.y/math.abs(yawDiff.y) * (360 - math.abs(yawDiff.y))
		end
		if math.abs(pitchDiff.x) > 180 then
			pitchDiff.x = -pitchDiff.x/math.abs(pitchDiff.x) * (360 - math.abs(pitchDiff.x))
		end

		-- throttle
		if p_AngDiff.y * yawDiff.y <= 0 then
			self.YawMotorThrottle = 0
		else
			self.YawMotorThrottle = Lerp(0.1, self.YawMotorThrottle, math.Clamp(math.abs(yawDiff.y) / self.RotateSpeed, 0, 1))
		end
		if p_AngDiff.p * pitchDiff.p <= 0 then
			self.PitchMotorThrottle = 0
		else
			self.PitchMotorThrottle = Lerp(0.1, self.PitchMotorThrottle, math.Clamp(math.abs(pitchDiff.x) / (self.RotateSpeed), 0, 1))
		end
		p_AngDiff.y = yawDiff.y
		p_AngDiff.p = pitchDiff.p

		local as = AngularSpeed
		if math.abs(as.y) <= 0.01 then
			as.y = self.YawMotorThrottle * self.RotateSpeed
			if p_AngularSpeed.y != 0 then
				as.y = math.min(as.y, math.abs(p_AngularSpeed.y) + self.RotateSpeed / 7.5)
			end
		else
			if math.abs(as.y) > 180 then
				as.y = -as.y/math.abs(as.y) * (360 - math.abs(as.y))
			end
		end
		as.y = math.abs(as.y)

		local ps = PitchSpeed
		if math.abs(ps.x) <= 0.01 then
			ps.x = self.PitchMotorThrottle * self.RotateSpeed * self.RotateSpeedRatio
			if p_PitchSpeed.x != 0 then
				ps.x = math.min(ps.x, math.abs(p_PitchSpeed.x) + self.RotateSpeed * self.RotateSpeedRatio / 10)
			end
		else
			if math.abs(ps.x) > 180 then
				ps.x = -ps.x/math.abs(ps.x) * (360 - math.abs(ps.x))
			end
		end
		ps.x = math.abs(ps.x)

		YawClampDelta = self.RotateSpeed * GetConVarNumber("host_timescale") * (as.y / self.RotateSpeed)
		PitchClampDelta = self.RotateSpeed * GetConVarNumber("host_timescale") * (ps.x / self.RotateSpeed)
		yawDiff.y = math.Clamp(yawDiff.y, -YawClampDelta, YawClampDelta) * self.YawMotorThrottle
		pitchDiff.x = math.Clamp(pitchDiff.x, -PitchClampDelta, PitchClampDelta) * self.PitchMotorThrottle

		-- Turning
		self.Entity:ManipulateBoneAngles(YawBoneIndex, Angle(0, YawBoneAng.y - self.ExistAngle + yawDiff.y, 0))
		self.Entity:ManipulateBoneAngles(PitchBoneIndex, Angle(PitchBoneAng.x + pitchDiff.x, 0, 0))

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

	attpos = self.Entity:GetAttachment(self.AimAttachment).Pos
	attang = self.Entity:GetAttachment(self.AimAttachment).Ang

	if (ct > (self.LastShoot + self.Cooldown)) then
		if self.Owner:KeyDown(GetConVarNumber("tnt_turret_fire")) then
			self:Shoot(ct, attpos, attang)
		end
	end

end
