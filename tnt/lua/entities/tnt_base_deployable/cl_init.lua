
include("shared.lua")

surface.CreateFont("TNT_Font", {
	size = 72,
	weight = 0,
	blursize = 0,
	scanlines = 0,
	antialias = true,
	underline = false,
	italic = false,
	strikeout = false,
	symbol = false,
	rotary = false,
	shadow = false,
	additive = false,
	outline = false
	})

function ENT:Draw()

	self.Entity:DrawModel()

	-- self:Calibration()
	self:Display()

end

function ENT:Display()

	local display = {
		{ self:GetForward(), Angle(0, 90, 60) },
		{ -self:GetRight(), Angle(0, 180, 60) },
		{ -self:GetForward(), Angle(0, -90, 60) },
		{ self:GetRight(), Angle(0, 0, 60) }
	}

	local ply = LocalPlayer()

	if self.Entity:GetPos():Distance(ply:GetPos()) > 1024 then return end

	if !self:GetReady() or GetConVar("ai_disabled"):GetBool() then

		for k,v in pairs(display) do
			cam.Start3D2D(self:GetPos() + self:GetUp() * 39.2 + v[1] * 36, v[2], 0.05)
				local shade = (math.sin(CurTime() * 16) + 1.6) * 255
				draw.SimpleText("Standby", "TNT_Font", 0, 0, Color(255, 0, 0, shade), 1, 1)
			cam.End3D2D()
		end

		return
	end

	if (self:GetReloadTime() > CurTime()) then

		for k,v in pairs(display) do
			cam.Start3D2D(self:GetPos() + self:GetUp() * 39.2 + v[1] * 36, v[2], 0.05)
				local shade = (math.sin(CurTime() * 16) + 1.6) * 255
				draw.SimpleText("Reloading", "TNT_Font", 0, 0, Color(255, 99, 0, shade), 1, 1)
			cam.End3D2D()
		end

		return
	end

	if ply:KeyDown(IN_USE) or (self:GetRounds() <= (5 * self.TakeAmmoPerShoot)) then

		local facingang = (ply:GetPos() - self.Entity:GetPos()):Angle().y
		local dir, ang
		if (facingang >= 315 and facingang < 360) then
			dir = display[1][1]
			ang = display[1][2]
		elseif (facingang >= 0 and facingang < 45) then
			dir = display[1][1]
			ang = display[1][2]
		elseif facingang >= 45 and facingang < 135 then
			dir = display[2][1]
			ang = display[2][2]
		elseif facingang >= 135 and facingang < 225 then
			dir = display[3][1]
			ang = display[3][2]
		elseif facingang >= 225 and facingang < 315 then
			dir = display[4][1]
			ang = display[4][2]
		end

		local c
		if (self:GetRounds() > (5 * self.TakeAmmoPerShoot)) then
			c = Color(19, 255, 255, 255)
		else
			c = Color(255, 0, 0, 255)
		end

		cam.Start3D2D(self:GetPos() + self:GetUp() * 39.2 + dir * 36, ang, 0.05)
			draw.SimpleText("Ammo "..self:GetRounds(), "TNT_Font", 0, 0, c, 1, 1)
		cam.End3D2D()

	end

end