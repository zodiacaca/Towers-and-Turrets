
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:PrecacheParticles()

	PrecacheParticleSystem("tnt_beam")
	PrecacheParticleSystem("tnt_beam_up")

end

function ENT:TurningTurret(ct)

	if GetConVar("ai_disabled"):GetBool() then return end
	if !IsValid(self.NPCCube) then self.TurningLoop:Stop() return end

	self.Target = self:GetTargetA()

	if (self:GetReady() == true) and (ct > self:GetReloadTime()) and (self.Target != nil) then

		if (ct > (self.LastShoot + self.Cooldown)) then
			util.ParticleTracerEx("tnt_beam_up", self.Entity:GetPos(), self.Entity:GetAttachment(1).Pos, true, self.Entity:EntIndex(), 2)
			if !self.Charged then
				self.ChargedTime = ct
				self.Charged = true
			end
			if (ct > (self.ChargedTime + 0.3)) then
				self:Shoot(ct, self.Target)
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
		if v:IsValid() && (table.HasValue(catchThem, string.lower(v:GetClass())) or v:IsNPC() or (v:IsPlayer() and !GetConVar("ai_ignoreplayers"):GetBool() and GetConVar("tnt_attack_player"):GetBool()) and v != self.Owner) and v != self.NPCCube then
			if !(table.HasValue(tntfriends, string.lower(v:GetClass())) || table.HasValue(tntfilter, string.lower(v:GetClass())) || string.find(v:GetClass(), "bullseye")) then
				if self.Entity:GetPos():Distance(v:GetPos()) < self.TurretRange then
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

function ENT:Shoot(ct)

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
			self.ShockVictims = 0
			timer.Create("tnt_shock_delay"..self.Entity:EntIndex()..self.ShockVictims, 0.1, 1, function()
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
					if !(v == t) and v != self.NPCCube then
						if v:IsLineOfSightClear(tpos) then
							self.ShockVictims = self.ShockVictims + 1
							timer.Create("tnt_shock_delay"..self.Entity:EntIndex()..self.ShockVictims, 0.1, 1, function()
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

	else

		for id, ent in pairs(ents.FindInSphere(self:GetPos(), 128)) do
			if string.match(ent:GetClass(), "ammo", 0) then

				self:SetReloadTime(CurTime() + 1/self.ReloadSpeed)
				self:SetRounds(self.ClipSize)
				self.Entity:EmitSound(self.TurretReloadSound, 65, 100 * GetConVarNumber("host_timescale"))

				ent:Remove()

				break

			end
		end

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

function ENT:OnRemove()

	if self.LoopSound then
		self.LoopSound:Stop()
		self.LoopSound = nil
	end
	if self.TurningLoop then
		self.TurningLoop:Stop()
		self.TurningLoop = nil
	end
	if self.FireSound then
		self.FireSound:Stop()
		self.FireSound = nil
	end

	timer.Destroy("tower_ready_"..self:EntIndex())
	timer.Destroy("tnt_shoot_delay"..self.Entity:EntIndex())

	if IsValid(self.NPCCube) then
		self.NPCCube:Remove()
	end

	if self.ShockVictims then
		for i = 0, self.ShockVictims do
			timer.Destroy("tnt_shock_delay"..self.Entity:EntIndex()..self.ShockVictims)
		end
	end

end