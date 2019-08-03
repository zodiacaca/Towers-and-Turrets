
include("shared.lua")


function ENT:Draw()

	self.Entity:DrawModel()

	-- self:Calibration()
	self:LaserDot()
	self:Display()

end

function ENT:LaserDot()

	if !(self:GetReady() == true) then return end
	if LocalPlayer() != self:GetTurretOwner() then return end
	if !self:GetTurretOwner():InVehicle() then return end

	local td = {}
		td.start = self.Entity:GetAttachment(1).Pos
		td.endpos = self.Entity:GetAttachment(1).Pos + self.Entity:GetAttachment(1).Ang:Forward() * 33000
		td.filter = { self.Entity }
	local tr = util.TraceLine(td)

	render.SetMaterial(Material("sprites/light_ignorez"))
	render.DrawSprite(tr.HitPos, 64, 64, Color(255, 0, 0, 255))

end