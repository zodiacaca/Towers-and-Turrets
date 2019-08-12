
/*---------------------------------------------------------
Name: OnTakeDamage
---------------------------------------------------------*/
function ENT:OnTakeDamage(dmginfo)

	if dmginfo:GetDamageType() ~= DMG_SLASH then

	local dmgAmount = dmginfo:GetDamage()
	local dmgDice = math.Clamp(dmgAmount, 1, 30)
	local health = self:Health() - dmgAmount
	health = math.Clamp(health, 0, 10000)
	local dice = math.random(1,math.Round(30/dmgDice))

	self:SetHealth(health)

	if (self:Health() <= 0.6 * self.TurretHealth) and (dice == 1) then
		if self.Fires <= 3 then
			self:DamageEffect()
		end
	end

	if (self:Health() <= 0) then
		self:Explosion()
	end

	end

end

function ENT:DamageEffect()

	if !self.HasDamagedState then return end

	local a = 255 * (self:Health()/self.TurretHealth)
	self:SetColor(Color(a, a, a, 255))

	local rpos = math.random(-self.FiresOffset,self.FiresOffset)

	self.FireEffect = ents.Create( "env_fire_trail" )
	self.FireEffect:SetPos(self:GetPos() + (self:GetForward() * rpos) + (self:GetRight() * rpos) + (self:GetUp() * self.FiresHeight))
	self.FireEffect:Spawn()
	self.FireEffect:SetParent(self)

	if !self.FireSound then
	self.FireSound = CreateSound(self, "ambient/fire/fire_big_loop1.wav")
	else
	self.FireSound:Play()
	self.FireSound:ChangePitch(100 * GetConVarNumber("host_timescale"))
	end

	self.Fires = self.Fires + 1

end

function ENT:Explosion()

	if not IsValid(self.Entity) then
	self:Remove()
	return
	end

	if self.Explored then return end

	if self.HasBase then
	self:ExplosionEffect()
	end

	self.Explored = true

	self:Remove()

end

function ENT:ExplosionEffect()

	local pos = self.Entity:GetPos()

	local effectdata = EffectData()
	effectdata:SetEntity(self.Entity)
	effectdata:SetOrigin(self.Entity:GetPos())
	effectdata:SetScale(1.8)
	util.Effect("m9k_gdcw_tnt_tower_boom", effectdata)
	for i=1,1000 do
	local td = {
		start = pos,
		endpos = pos + Vector(math.Rand(-1,1), math.Rand(-1,1), math.Rand(-1,1)) * 256,
		filter = { self.Entity }
		}
	local ouchies = util.TraceLine(td)
	if IsValid(ouchies.Entity) then
		if !ouchies.Entity.Base == "tnt_base_deployable" then
			local dist = pos:Distance(ouchies.HitPos)
			dist = math.sqrt(dist)
			local dir = (ouchies.HitPos - pos):GetNormal()
			local dmg = DamageInfo()
				dmg:SetDamageType(DMG_SHOCK)
				dmg:SetDamage(90)
				dmg:SetAttacker(self.Entity)
				dmg:SetInflictor(self.Entity)
				dmg:SetFilter(self.Entity)
				dmg:SetDamagePosition(ouchies.HitPos)
				dmg:SetDamageForce((dir * 4 * 10^5)/dist)
			ouchies.Entity:TakeDamageInfo(dmg)
		end
	end
	end
	util.ScreenShake(pos, 800, 250, 0.75, 512)

	local ent = ents.Create("prop_physics")
	ent:SetModel("models/tnt/towers_razed"..math.random(1,2)..".mdl")
	ent:SetPos(self.Entity:GetPos())
	ent:SetAngles(Angle(0, math.random(0,360), 0))
	ent:Spawn()
	local phys = ent:GetPhysicsObject()
	if IsValid(phys) then
	phys:EnableCollisions(true)
	phys:EnableMotion(false)
	end

end