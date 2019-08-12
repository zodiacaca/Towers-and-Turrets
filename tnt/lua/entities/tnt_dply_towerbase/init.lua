
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
	self.TurningLoop = CreateSound(self.Entity, self.TurretTurningSound)

	self:SetTrigger(true)	-- Touch

  self:CreateIndicator()
	self:SetReady(true)

end

local poorbastards = {
	"npc_citizen",
	"npc_alyx",
	"npc_barney",
	"npc_kleiner",
	"npc_mossman",
	"npc_eli",
	"npc_gman",
	"npc_breen",
	"npc_monk",
	"npc_fassassin",
	"npc_combine_s",
	"npc_metropolice",
	"npc_zombine",
	"npc_poisonzombine"
	}
local vehicle = {
	"vehicle",
	"jeep",
	"car"
	}
function ENT:PhysicsCollide(data, phys)

	if not IsValid(self.Entity) then return end

	local angle = self.Entity:GetAngles()

	if !data.HitEntity:IsValid() then
		self:CollideEffect()
		if self.SettleAnim then
			local sequence = self:LookupSequence("settle")
			self:SetSequence(sequence)
			self:SetPlaybackRate(1)
			local time = self:SequenceDuration()
			timer.Create("tower_ready_"..self:EntIndex(), time, 1, function() self:SetReady(true) end)
		else
			self:SetReady(true)
		end
		self.Collided = true
		if math.abs(angle.r) < 45 then
			self.Entity:DrawShadow(false)
			phys:EnableMotion(false)
			phys:Sleep()
		end
	elseif data.HitEntity:IsValid() then
		if table.HasValue(poorbastards, string.lower(data.HitEntity:GetClass())) or data.HitEntity:IsPlayer() then
			if !self.Collided then
				local effectdata = EffectData()
					effectdata:SetOrigin(data.HitEntity:GetPos() + Vector(0, 0, -32))
					effectdata:SetScale(1.6)
				util.Effect("m9k_gdcw_tnt_blood_cloud", effectdata)
			end
		end

	for i=1,2 do
		if string.match(data.HitEntity:GetClass(), vehicle[i], 1) then
			return
		end
	end

	if !data.HitEntity:IsPlayer() and math.abs(angle.r) < 15 then
		if !self.Collided then
			SafeRemoveEntity(data.HitEntity)
			end
		end
	end

end

function ENT:UpdateTransformation()
end

function ENT:PostTransformation()
end