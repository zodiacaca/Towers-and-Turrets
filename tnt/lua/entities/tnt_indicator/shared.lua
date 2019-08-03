
ENT.Type			= "anim"
ENT.Base			= "base_anim"
ENT.PrintName	= "tnt indicator"
ENT.Spawnable	= false
ENT.AdminOnly = true
ENT.DoNotDuplicate = false
ENT.DisableDuplicator = true


if SERVER then

AddCSLuaFile()

function ENT:Initialize()

	self.Entity:SetModel("models/hunter/blocks/cube025x025x025.mdl")
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:DrawShadow(false)

	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:EnableGravity(false)
		phys:EnableCollisions(false)
		phys:EnableDrag(false)
		phys:Wake()
	end

	self.flashlight = ents.Create( "env_projectedtexture" )

	self.flashlight:SetParent( self.Entity )

	-- The local positions are the offsets from parent..
	self.flashlight:SetLocalPos( Vector( 0, 0, 128 ) )
	self.flashlight:SetLocalAngles( Angle( 90, 0, 0) )

	-- Looks like only one flashlight can have shadows enabled!
	self.flashlight:SetKeyValue( "enableshadows", 0 )
	self.flashlight:SetKeyValue( "farz", 1024 )
	self.flashlight:SetKeyValue( "nearz", 0.1 )
	self.flashlight:SetKeyValue( "lightfov", 90 )

	local c = Color( 255, 0, 0 )
	local b = 200
	self.flashlight:SetKeyValue( "lightcolor", Format( "%i %i %i 255", c.r * b, c.g * b, c.b * b ) )

	self.flashlight:Spawn()

	self.flashlight:Input( "SpotlightTexture", NULL, NULL, "effects/tnt_indicate_01" )

	self.StartTime = CurTime()
	self.MaxTime = CurTime() + 10
	self.Emitted = false
	self.CanTool = false

end

function ENT:PhysicsUpdate(ph)

	if not IsValid(self.Entity) then return end

	ph:SetAngles(Angle(0, (self.StartTime - CurTime()) * 90, 0))

end

function ENT:Think()

	local td = {
		start = self:GetPos(),
		endpos = self:GetPos() + Vector(0, 0, 2048),
		filter = { self.Entity }
		}
	local tr = util.TraceLine(td)
	if IsValid(tr.Entity) then
		if !self.Emitted then
			sound.Play("tnt/tower_entry"..math.random(1,2)..".ogg", tr.HitPos, 150, math.Rand(80,120) * GetConVarNumber("host_timescale"), 1)
			self.Emitted = true
		end
	end
	if tr.Fraction < 0.5 then
		SafeRemoveEntity( self )
		return
	end

	if (CurTime() > self.MaxTime) then
		SafeRemoveEntity(self)
		return
	end

	self:UpdateLight()

	self:NextThink(CurTime())

	return true
end

function ENT:UpdateLight()

	if ( !IsValid( self.flashlight ) ) then return end

	self.flashlight:Input( "FOV", NULL, NULL, 90/( CurTime() - self.StartTime + 1 )^1.2 )

end

end

if CLIENT then

function ENT:Draw()
end

end