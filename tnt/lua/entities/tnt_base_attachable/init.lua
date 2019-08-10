
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:SpawnFunction( ply, tr )

	local count = 0
	for k,v in pairs(ents.GetAll()) do
		if v:GetClass() == self.Turret then
			count = count + 1
		end
	end
	if count >= 10 then
		ply:EmitSound(Sound("buttons/button10.wav"))
		ply:ChatPrint("Maximum reached!")
		return false
	end

	if ( !tr.Hit ) then return end

	local SpawnPos = tr.HitPos + tr.HitNormal * 10
	local SpawnAng = ply:EyeAngles()
	SpawnAng.p = 0
	SpawnAng.y = SpawnAng.y + 180

	local ent = ents.Create( self.Turret )
		ent:SetCreator( ply )
		ent:SetPos( SpawnPos )
		ent:SetAngles( SpawnAng )
	ent:Spawn()
	ent:Activate()

	ent:DropToFloor()

	return ent
end
