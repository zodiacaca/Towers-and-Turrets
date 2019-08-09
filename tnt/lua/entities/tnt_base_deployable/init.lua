
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
	-- 	if !(v:GetClass() == "tnt_towerbase") && v:GetClass() == self.Tower then
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

	local ent = ents.Create(self.Tower)
	ent:SetCreator(ply)
	ent:SetPos(Pos + Vector(0, 0, 3600))
	ent:SetAngles(Angle(0, 0, 0))
	ent:Spawn()
	ent:Activate()

	return ent
end
