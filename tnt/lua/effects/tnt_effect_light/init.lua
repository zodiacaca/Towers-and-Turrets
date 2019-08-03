
function EFFECT:Init(data)

	self.Start = data:GetOrigin()
	self.Scale = data:GetScale() or 1
	
	local dlight = DynamicLight()
	dlight.Pos = self.Start
	dlight.Size = 128 * self.Scale * math.random(0.95,1.05)
	dlight.DieTime = CurTime() + (0.4 * math.sqrt(self.Scale))
	dlight.r = math.Rand(229,249)
	dlight.g = math.Rand(149,169)
	dlight.b = 99
	dlight.Brightness = 0.75 * math.random(0.95,1.05)
	dlight.Decay = 1000

end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end