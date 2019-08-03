
function EFFECT:Init(data)

	self.Start = data:GetOrigin()
	
	local dlight = DynamicLight()
	dlight.Pos = self.Start
	dlight.Size = 1024 * math.random(0.9,1.15)
	dlight.DieTime = CurTime() + 0.4
	dlight.r = 255
	dlight.g = 255
	dlight.b = 255
	dlight.Brightness = 1.5
	dlight.Decay = 1000

end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end