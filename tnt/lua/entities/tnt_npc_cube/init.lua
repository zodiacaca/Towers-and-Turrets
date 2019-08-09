
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )


ENT.m_iClass = CLASS_CITIZEN_REBEL -- NPC Class

AccessorFunc( ENT, "m_iClass", "NPCClass" )

function ENT:Initialize()

	self.Entity:SetModel("models/hunter/blocks/cube025x025x025.mdl")
	self.Entity:SetModelScale(0)
	self.Entity:SetModelScale(0.8, 0.5)
	self.Entity:SetSubMaterial(0, "debug/env_cubemap_model")
	self.Entity:SetHealth(100)

	self.Entity:PhysicsInit(SOLID_VPHYSICS)

	local phys = self.Entity:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end

	self.Entity:DrawShadow(false)

end

function ENT:OnTakeDamage(dmginfo)

	self:SetHealth(self:Health() - dmginfo:GetDamage())
	if self:Health() <= 0 then
		self:Remove()
	end

end

function ENT:OnRemove()

	ParticleEffect("tnt_cannon_blast", self:GetPos(), Angle(0, 0, 0), nil)

end

function ENT:Think()

end
