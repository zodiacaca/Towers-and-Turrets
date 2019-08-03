
function EFFECT:Init(data)
	
	self.WeaponEnt = data:GetEntity()
	self.Attachment = data:GetAttachment()

	self.Position = self:GetTracerShootPos(data:GetOrigin(), self.WeaponEnt, self.Attachment)
	self.Scale = data:GetScale()
	self.Forward = data:GetNormal()
	self.Angle = self.Forward:Angle()
	self.Right = self.Angle:Right()

	local emitter = ParticleEmitter(self.Position)

		for i=0,4 do
		local particle = emitter:Add("particle/smokesprites_000"..math.random(1,9), self.Position)
		particle:SetVelocity(60*i*self.Forward*math.sqrt(self.Scale))
		particle:SetDieTime(math.Rand(0.2,0.3))
		particle:SetStartAlpha(math.Rand(20,25))
		particle:SetEndAlpha(0)
		particle:SetStartSize(math.Rand(3,4)*self.Scale)
		particle:SetEndSize(math.Rand(15,20)*self.Scale)
		particle:SetRoll(math.Rand(180,480))
		particle:SetRollDelta(math.Rand(-3,3))
		particle:SetColor(120,120,120)
		particle:SetAirResistance(150)
		end
		
		for i=-1,1 do
		local particle = emitter:Add("particle/smokesprites_000"..math.random(1,9), self.Position)
		particle:SetVelocity(80*i*self.Right*math.sqrt(self.Scale))
		particle:SetDieTime(math.Rand(0.2,0.3))
		particle:SetStartAlpha(math.Rand(20,25))
		particle:SetEndAlpha(5)
		particle:SetStartSize(math.Rand(4,6)*self.Scale)
		particle:SetEndSize(math.Rand(8,12)*self.Scale)
		particle:SetRoll(math.Rand(180,480))
		particle:SetRollDelta(math.Rand(-3,3))
		particle:SetColor(120,120,120)
		particle:SetAirResistance(150)
		end

	emitter:Finish()

end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end