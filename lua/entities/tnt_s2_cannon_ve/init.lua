
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

local p_aimpos = Vector(0, 0, 0)

function ENT:TurningTurret(ct)

	if (self:GetReady() == true) and self.Owner:IsValid() and self.Owner:InVehicle() then

		-- Prepare the bones
		YawBoneIndex = self.Entity:LookupBone(self.AimYawBone)
		YawBonePos_w, YawBoneAng_w = self.Entity:GetBonePosition(YawBoneIndex)
		PitchBoneIndex = self.Entity:LookupBone(self.AimPitchBone)
		PitchBonePos_w, PitchBoneAng_w = self.Entity:GetBonePosition(PitchBoneIndex)
		YawBonePos, YawBoneAng = self:TranslateCoordinateSystem(YawBonePos_w, YawBoneAng_w)
		PitchBonePos, PitchBoneAng = self:TranslateCoordinateSystem(PitchBonePos_w, PitchBoneAng_w)

		-- Angles between the target and the bones
		aimpos_w = self:GetTracer().HitPos
		if math.abs((p_aimpos - aimpos_w):Length()) > 512 then
			self.ActivatedTime = ct
		end
		p_aimpos = aimpos_w
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
		angdif_y = ang_aim_y - YawBoneAng
		angdif_p = ang_aim_p - PitchBoneAng

		-- Make sure the turret don't turn like a maniac
		if math.abs(angdif_y.y) > 180 then
			angdif_y.y = -angdif_y.y/math.abs(angdif_y.y) * (360 - math.abs(angdif_y.y))
		end
		if math.abs(angdif_p.x) > 180 then
			angdif_p.x = -angdif_p.x/math.abs(angdif_p.x) * (360 - math.abs(angdif_p.x))
		end

		-- Acceleration
		local clampDelta = math.sqrt(ct - self.ActivatedTime) * self.AngularSpeed * GetConVarNumber("host_timescale")
		angdif_y.y = math.Clamp(angdif_y.y, -clampDelta, clampDelta)
		angdif_p.x = math.Clamp(angdif_p.x, -clampDelta, clampDelta)

		-- Turning
		self.Entity:ManipulateBoneAngles(YawBoneIndex, Angle(0, YawBoneAng.y - self.ExistAngle + angdif_y.y, 0))
		self.Entity:ManipulateBoneAngles(PitchBoneIndex, Angle(PitchBoneAng.x + angdif_p.x, 0, 0))

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
