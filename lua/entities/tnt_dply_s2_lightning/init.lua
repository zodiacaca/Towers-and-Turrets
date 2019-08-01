
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:PrecacheParticles()

	PrecacheParticleSystem("tnt_beam")
	PrecacheParticleSystem("tnt_beam_up")

end

function ENT:Think()

	if !self.Collided then
		local phys = self:GetPhysicsObject()
		if ( IsValid( phys ) ) then phys:AddVelocity( -self:GetUp() * 16 ) end
	end

	local CT = CurTime()

	if self.TowerIdleSound != nil then
		if self.LoopSound then
			if !(self:GetReady() == true) or !(CT > self:GetReloadTime()) then
				self.LoopSound:ChangeVolume(0.5, 0.5)
			else
				self.LoopSound:ChangeVolume(1, 0.5)
				self.LoopSound:ChangePitch(100 * GetConVarNumber("host_timescale"))
			end
		else
			self.LoopSound = CreateSound(self.Entity, Sound(self.TowerIdleSound))
			self.LoopSound:Play()
		end
	end

	self:TurningTurret(CT)
	self:Recoil(CT)
	self:ReloadAmmo(CT)

	self:NextThink(CurTime())

	return true
end

function ENT:TurningTurret(ct)

	if GetConVar("ai_disabled"):GetBool() then return end

	target = self:GetTargetA()

	if (self:GetReady() == true) and (ct > self:GetReloadTime()) and (target != nil) then

		if (ct > (self.LastShoot + self.Cooldown)) then
			util.ParticleTracerEx("tnt_beam_up", self.Entity:GetPos(), self.Entity:GetAttachment(1).Pos, true, self.Entity:EntIndex(), 2)
			if !self.Charged then
				self.ChargedTime = ct
				self.Charged = true
			end
			if (ct > (self.ChargedTime + 0.3)) then
				self:Shoot(ct, target)
				self.Charged = false
			end
		end

	end

end

local catchThem = {
	"rpg_missile",
	"npc_grenade_frag"
}

function ENT:GetTargetA()

	local targets = {}

	for k,v in pairs(ents.GetAll()) do
		if v:IsValid() && (table.HasValue(catchThem, string.lower(v:GetClass())) or v:IsNPC() or (v:IsPlayer() and !GetConVar("ai_ignoreplayers"):GetBool() and GetConVar("tnt_attack_player"):GetBool()) and v != self.Owner) then
			if !(table.HasValue(tntfriends, string.lower(v:GetClass())) || table.HasValue(tntfilter, string.lower(v:GetClass())) || string.find(v:GetClass(), "bullseye")) then
				if self.Entity:GetPos():Distance(v:GetPos()) < self.TowerRange then
					if v:IsLineOfSightClear(self.Entity:GetPos() + self:GetUp() * self.AimHeight) and v:Health() > 0 then
						local target = { ent = v, health = v:Health() }
						table.insert(targets, target)
					end
				end
			end
		end
	end

	if table.Count(targets) >= 1 then

		table.SortByMember(targets, "health", false)

		return targets[1].ent

	end

end

function ENT:Shoot(ct, t)

	if (self:GetRounds() >= self.TakeAmmoPerShoot) then

		self:SetRounds(self:GetRounds() - self.TakeAmmoPerShoot)

		local tower = self.Entity
		local pos = self.Entity:GetPos()
		local apos = self.Entity:GetAttachment(1).Pos
		local tpos = t:GetPos() + Vector(0, 0, 0.6 * t:OBBMaxs().z)
		local damage = self.HitDamage * self.DamageScale * math.Rand(0.9,1.3)
		local normal = (tpos - tower:GetAttachment(1).Pos):GetNormal()

		util.ParticleTracerEx("tnt_beam", pos, tpos, true, tower:EntIndex(), self.AimAttachment)

		if IsValid(t) then
			local Muzzle_Light = EffectData()
				Muzzle_Light:SetOrigin(apos)
			util.Effect("tnt_lightning_light", Muzzle_Light)
			timer.Simple(0.1, function()
				local dmg1 = DamageInfo()
					dmg1:SetDamageType(DMG_SHOCK)
					dmg1:SetDamage(damage)
					dmg1:SetAttacker(tower)
					dmg1:SetInflictor(tower)
					dmg1:SetDamagePosition(tpos)
					dmg1:SetDamageForce(normal * 5000)
				if IsValid(t) then
					t:TakeDamageInfo(dmg1)
				end
			end)
			sound.Play("tnt/lightning/lightning_shoot"..math.random(1,4)..".wav", apos, 80, 100 * GetConVarNumber("host_timescale"), 1)

			for k,v in pairs(ents.FindInSphere(tpos, self.BlastRadius)) do
				if IsValid(v) and (v:IsPlayer() or v:IsNPC()) then
					if !(v == t) then
						if v:IsLineOfSightClear(tpos) then
							timer.Simple(0.1, function()
							local dmg2 = DamageInfo()
								dmg2:SetDamageType(DMG_SHOCK)
								dmg2:SetDamage(damage * 0.5)
								dmg2:SetAttacker(tower)
								dmg2:SetInflictor(tower)
								dmg2:SetDamagePosition(v:GetPos() + Vector(0, 0 ,0.5 * t:OBBMaxs().z))
								dmg2:SetDamageForce((v:GetPos() - t:GetPos()):GetNormal() * 2500)
							v:TakeDamageInfo(dmg2)
							end)
							local id
							if t:GetClass() == "npc_combine_s" then
								id = 4
							elseif t:GetClass() == "npc_citizen" then
								id = 3
							else
								id = t:LookupAttachment("chest")
							end
							if id == nil then
								id = 0
							end
							util.ParticleTracerEx("tnt_beam", t:GetPos(), v:GetPos() + Vector(0, 0 ,0.5 * t:OBBMaxs().z), true, t:EntIndex(), id)
							sound.Play("tnt/lightning/lightning_chainbounce"..math.random(1,6)..".wav", v:GetPos() + Vector(0, 0 ,0.5 * t:OBBMaxs().z), 70, 100 * GetConVarNumber("host_timescale"), 1)
						end
					end
				end
			end

		end

		self.LastShoot = ct

	end

end

function ENT:Recoil(ct)

	RecoilBoneIndex = self.Entity:LookupBone(self.RecoilBone)
	RecoilBonePos, RecoilBoneAng = self.Entity:GetBonePosition(RecoilBoneIndex)

	recoil = (ct - self.LastShoot) * self.RecoilOffset * 2 + 1
	back = (self.RecoilOffset * 1/self.RecoilRecoverPerThink) - (ct - self.LastShoot - 1/self.RecoilRecoverPerThink) * (0.5 * self.RecoilOffset) * 2 + 1

	if (ct - self.LastShoot) < (3 * 1/self.RecoilRecoverPerThink) then
		if (ct - self.LastShoot) < 1/self.RecoilRecoverPerThink then
			self.Entity:ManipulateBoneScale(RecoilBoneIndex, Vector(-recoil, -recoil, -recoil))
		else
			self.Entity:ManipulateBoneScale(RecoilBoneIndex, Vector(-back, -back, -back))
		end
	end

end