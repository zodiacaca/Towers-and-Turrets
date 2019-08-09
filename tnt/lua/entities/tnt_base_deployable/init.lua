
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:SpawnFunction(ply, tr)

	if !tr.Hit then return end

	local td = {
		start = tr.HitPos,
		endpos = tr.HitPos + Vector(0, 0, 33000),
		filter = { self.Entity }
		}
	local skycheck = util.TraceLine(td)
	if !skycheck.HitSky then
		ply:EmitSound(Sound("buttons/button10.wav"))
		ply:ChatPrint("Not enough clearance above target position.")
		return
	end

	local trd = {
		start = tr.HitPos,
		endpos = tr.HitPos + Vector(0, 0, 3600),
		filter = { self.Entity }
		}
	local skyboxcheck = util.TraceLine(trd)
	if skyboxcheck.HitSky then
		ply:EmitSound(Sound("buttons/button10.wav"))
		ply:ChatPrint("Summoning a tower requires a map with a bigger skybox.")
		return
	end

	-- local count = 0
	-- for k,v in pairs(ents.GetAll()) do
	-- 	if !(v:GetClass() == "tnt_towerbase") && v:GetClass() == self.Turret then
	-- 		count = count + 1
	-- 	end
	-- end
	-- if count >= 10 then
	-- 	ply:EmitSound(Sound("buttons/button10.wav"))
	-- 	ply:ChatPrint("Maximum reached!")
	-- 	return false
	-- end

	local Pos = tr.HitPos
	if Pos.x >= 0 then
		if math.fmod(Pos.x, 80) >= 40 then
			Pos.x = math.floor(Pos.x/80) * 80 + 80
		else
			Pos.x = math.floor(Pos.x/80) * 80
		end
	else
		if math.fmod(math.abs(Pos.x),80) >= 40 then
			Pos.x = -math.floor(math.abs(Pos.x)/80) * 80 - 80
		else
			Pos.x = -math.floor(math.abs(Pos.x)/80) * 80
		end
	end
	if Pos.y >= 0 then
		if math.fmod(Pos.y, 80) >= 40 then
			Pos.y = math.floor(Pos.y/80) * 80 + 80
		else
			Pos.y = math.floor(Pos.y/80) * 80
		end
	else
		if math.fmod(math.abs(Pos.y), 80) >= 40 then
			Pos.y = -math.floor(math.abs(Pos.y)/80) * 80 - 80
		else
			Pos.y = -math.floor(math.abs(Pos.y)/80) * 80
		end
	end

	local ent = ents.Create(self.Turret)
	ent:SetCreator(ply)
	ent:SetPos(Pos + Vector(0, 0, 3600))
	ent:SetAngles(Angle(0, 0, 0))
	ent:Spawn()
	ent:Activate()

	return ent
end

function ENT:CreateIndicator()

	local td = {
		start = self:GetPos(),
		endpos = self:GetPos() + Vector(0, 0, -33000),
		filter = { self.Entity }
		}
	local tr = util.TraceLine(td)

	if tr.Hit then
		local pos = tr.HitPos
		local ent = ents.Create( "tnt_indicator" )
		if ( IsValid( ent ) ) then
			ent:SetPos( pos )
			ent:SetAngles( Angle( 0, 0, 0 ) )
			ent:Spawn()
			ent:Activate()
		end
	end

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
		self:CreateNPCCube()
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

function ENT:CollideEffect()

	if self.Collided then return end

	local effectdata = EffectData()
		effectdata:SetEntity(self.Entity)		// Who done it?
		effectdata:SetOrigin(self.Entity:GetPos() + Vector(0, 0, -48))
		effectdata:SetScale(0.8)
		effectdata:SetMagnitude(50)			// Length of explosion trails
	util.Effect("m9k_gdcw_tnt_boom", effectdata)
	util.BlastDamage(self.Entity, self.Entity, self.Entity:GetPos(), 96, 200 )
	util.ScreenShake(self.Entity:GetPos(), 16, 250, 1, 512)
	sound.Play("tnt/tower_impact"..math.random(1,3)..".ogg", self.Entity:GetPos(), 150, math.Rand(80,120) * GetConVarNumber("host_timescale"), 1)

end

