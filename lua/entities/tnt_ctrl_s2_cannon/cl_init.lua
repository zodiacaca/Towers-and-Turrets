
include("shared.lua")

killicon.Add( "tnt_ctrl_s2_cannon", "vgui/hud/tnt_cannon", Color( 255, 255, 255, 255 ) )

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

	local eyeAng = EyeAngles()
	eyeAng.p = 0
	eyeAng.y = eyeAng.y - 90
	eyeAng.r = 90

	local dist = tr.HitPos:Distance(EyePos())/500
	dist = math.Clamp(dist, 1, 20)
	local size = 64 * dist
	local surface_color = render.GetSurfaceColor(EyePos(), tr.HitPos + (tr.HitPos - EyePos()):GetNormal() * 128):Length()
	local color = 99/surface_color

	render.SetMaterial(Material("sprites/tnt_crosshair_01"))
	render.DrawSprite(tr.HitPos - (tr.HitPos - EyePos()):GetNormal() * 128, size * 2.5, size * 0.5, Color(color, color, color, 255))

	render.SetMaterial(Material("sprites/light_ignorez"))
	render.DrawSprite(tr.HitPos, 64, 64, Color(255, 0, 0, 255))

end