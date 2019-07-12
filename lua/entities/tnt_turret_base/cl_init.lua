
include("shared.lua")

function ENT:Draw()

	self.Entity:DrawModel()

	-- self:Calibration()
	self:Display()

end

function ENT:Calibration()

--[[ 	These codes below help you to calibrate the barrel.
	Forward direction is where the x axis aims in local.
	You should use local coordinates to adjust the attachment position too. ]]

	local td = {}
		td.start = self.Entity:GetAttachment(1).Pos
		td.endpos = self.Entity:GetAttachment(1).Pos + self.Entity:GetAttachment(1).Ang:Forward() * 10000
		td.filter = { self.Entity }
	local tr = util.TraceLine(td)

	render.SetMaterial(Material("cable/redlaser"))
	render.DrawBeam(self.Entity:GetAttachment(1).Pos, tr.HitPos, 10, 0, 1, Color(255, 255, 255, 255))

	local self_ang = self.Entity:GetAngles()
	self_ang:RotateAroundAxis(self_ang:Up(), (self.Entity:GetAttachment(1).Ang.y - self.Entity:GetAngles().y))

	local td2 = {}
		td2.start = self.Entity:GetPos()
		td2.endpos = self.Entity:GetPos() + self_ang:Forward() * 10000
		td2.filter = { self.Entity }
	local tr2 = util.TraceLine(td2)

	render.SetMaterial(Material("cable/redlaser"))
	render.DrawBeam(td2.start, tr2.HitPos, 10, 0, 1, Color(255, 255, 255, 255))

end

function ENT:Display()

	local pos = self.Entity:GetAttachment(self.AimAttachment).Pos
	local ang = self.Entity:GetAttachment(self.AimAttachment).Ang

	local offset_x = ang:Forward() * self.DisplayOffset
	local ang_y = ang.y
	ang:RotateAroundAxis(ang:Up(), -self.ExistAngle)
	local ang_x = ang.x
	local ang_z = ang.z
	local display_ang = Angle(ang_x, ang_y - self.ExistAngle, ang_z + 60)

	if (CurTime() < self:GetReloadTime()) then
		cam.Start3D2D(pos + offset_x, display_ang, 0.2)
			draw.SimpleText("Reloading", "Default", 0, 0, Color(255, 99, 0, 255), 1, 1)
		cam.End3D2D()
	elseif !self:GetReady() or GetConVar("ai_disabled"):GetBool() then
		cam.Start3D2D(pos + offset_x, display_ang, 0.2)
			draw.SimpleText("Standby", "Default", 0, 0, Color(255, 0, 0, 255), 1, 1)
		cam.End3D2D()
	end

end