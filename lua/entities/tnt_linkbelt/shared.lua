
ENT.Type			= "anim"
ENT.Base			= "base_anim"
ENT.PrintName	= "tnt linkbelt"
ENT.Spawnable	= false

if SERVER then

AddCSLuaFile()

function ENT:Initialize()

	local size = 1
 
    //Vectors
    local min=Vector(0 - size, 0 - size, 0 - size)
    local max=Vector(size, size, size)
 
    //Give it some kind of model
    self:SetModel("models/tnt/m60_belt.mdl")
 
    //Set physics box
    self:PhysicsInitBox(min,max)
 
    //Set bounding box - this will be used for triggers and determining if rendering is necessary(clientside)
    self:SetCollisionBounds(min,max)

	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:EnableCollisions(false)
		phys:Wake()
	end

	self.LifeTime = CurTime() + 5

end

function ENT:Think()

	if (CurTime() > self.LifeTime) then
		self:Remove()
	end

end

end

if CLIENT then

function ENT:Draw()

	self.Entity:DrawModel()

end

end