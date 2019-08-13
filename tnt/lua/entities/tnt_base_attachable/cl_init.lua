
include("shared.lua")

function ENT:Draw()

	self.Entity:DrawModel()

	-- self:Calibration()
	self:Display()

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
