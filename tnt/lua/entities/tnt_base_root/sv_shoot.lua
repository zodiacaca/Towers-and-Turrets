
function ENT:Aiming(ct)

	if self.AimAttachment == nil then
		print("AimAttachment expected, got nil")
		return
	end

	AttPos = self.Entity:GetAttachment(self.AimAttachment).Pos
	AttAng = self.Entity:GetAttachment(self.AimAttachment).Ang

	local max = 16

	local td = {
		start = AttPos,
		endpos = AttPos + AttAng:Forward() * 33000,
		maxs = Vector(max, max, max),
		mins = Vector(-max, -max, -max),
		filter = { self.Entity }
		}
	local tr = util.TraceHull(td)

	if (ct > (self.LastShoot + self.Cooldown)) then
		if tr.Entity:IsValid() and ((!GetConVar("tnt_attack_owner"):GetBool() and !(tr.Entity == self:GetTurretOwner())) or GetConVar("tnt_attack_owner"):GetBool()) then
			timer.Create("tnt_shoot_delay"..self.Entity:EntIndex(), math.random(0.003, 0.006), 1, function()
				self:Shoot(ct, AttPos, AttAng)
			end)
		end
	end

end

function ENT:Shoot(ct, pos, ang)

	if (self:GetRounds() >= self.TakeAmmoPerShoot) then

		self:SetRounds(self:GetRounds() - self.TakeAmmoPerShoot)

		local dice = math.Rand(0.9,1.15)
		local damage = self.BlastDamage * self.DamageScale * dice

		self:MuzzleEffects(pos, ang)
		self:EjectCasing(pos, ang)
		util.ScreenShake(pos, 0.02 * damage, 0.05 * damage, 0.75, 2 * self.BlastRadius)

		local bullet = {}
			bullet.Num 		= 1
			bullet.Src 		= pos			-- Source
			bullet.Dir 		= ang:Forward()			-- Dir of bullet
			bullet.Spread 	= Vector(self.Spread, self.Spread, 0)		-- Aim Cone
			bullet.Tracer	= self.TracerCount									-- Show a tracer on every x bullets
			bullet.Force	= self.HitDamage * 0.75									-- Amount of force to give to phys objects
			bullet.Damage	= self.HitDamage * self.DamageScale * dice
			bullet.AmmoType = "Pistol"
			bullet.TracerName = self.TracerType
			bullet.Callback	= function(attacker, tracedata, dmginfo)
				if !tracedata.HitSky and self.BlastDamage != 0 and self.BlastRadius != 0 then
					if self.ImpactParticle != nil then
						ParticleEffect(self.ImpactParticle, tracedata.HitPos, Angle(0, 0, 0), nil)
					end
					if self.ImpactEffect != nil then
						local Impact_FX = EffectData()
							Impact_FX:SetEntity(self.Entity)
							Impact_FX:SetOrigin(tracedata.HitPos)
							Impact_FX:SetScale(self.ImpactScale)
						util.Effect(self.ImpactEffect, Impact_FX)
					end
					local Impact_Light = EffectData()
						Impact_Light:SetOrigin(tracedata.HitPos)
					util.Effect("tnt_effect_light", Impact_Light)
					util.BlastDamage(self.Entity, self.Entity, tracedata.HitPos, self.BlastRadius, damage)
					sound.Play(self.ImpactExplosionSound, tracedata.HitPos, 100, 100 * GetConVarNumber("host_timescale"), 1)
					util.ScreenShake(tracedata.HitPos, 0.2 * damage, 1 * damage, 0.75, 1 * self.BlastRadius)
				end
			end

		self.Entity:FireBullets(bullet)

		sound.Play(self.TurretShootSound, pos, 100, math.Rand(95,105) * GetConVarNumber("host_timescale"), 1 )

		if !self.HasBase then
			local phys = self:GetPhysicsObject()
			if ( IsValid( phys ) ) then phys:AddVelocity( -ang:Forward() * (0.6 * self.BlastDamage + 3 * self.HitDamage)) end
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

function ENT:MuzzleEffects(p, a)

	local Muzzle_FX = EffectData()
		Muzzle_FX:SetEntity(self.Entity)
		Muzzle_FX:SetOrigin(p)
		Muzzle_FX:SetNormal(a:Forward())
		Muzzle_FX:SetScale(self.MuzzleScale)
		Muzzle_FX:SetAttachment(self.AimAttachment)
	util.Effect("gdcw_tnt_muzzle_cannon", Muzzle_FX)
	local Muzzle_Light = EffectData()
		Muzzle_Light:SetOrigin(p)
		Muzzle_Light:SetScale(self.MuzzleLightScale)
	util.Effect("tnt_effect_light", Muzzle_Light)

end

function ENT:EjectCasing(p, a)

	if self.EjectEffect != nil then
		local ShellEject = EffectData()
			ShellEject:SetOrigin(p + a:Forward() * self.EjectOffset)
			ShellEject:SetAngles(a + Angle(60, -120, 0))
		util.Effect(self.EjectEffect, ShellEject)
	end

end

function ENT:Recoil(ct)

	if self.RecoilBone == nil then return end

	RecoilBoneIndex = self.Entity:LookupBone(self.RecoilBone)
	RecoilBonePos, RecoilBoneAng = self.Entity:GetBonePosition(RecoilBoneIndex)

  local TimeCount = ct - self.LastShoot
  local BaseTime = 1 / self.RecoilRecoverPerThink
  local MovementTime = 3 * BaseTime
	recoil = TimeCount * self.RecoilOffset
	back = (self.RecoilOffset * BaseTime) - (TimeCount - BaseTime) * (0.5 * self.RecoilOffset)

	if TimeCount < MovementTime then
		if TimeCount < BaseTime then
			self.Entity:ManipulateBonePosition(RecoilBoneIndex, Vector(-recoil, 0, 0))
		else
			self.Entity:ManipulateBonePosition(RecoilBoneIndex, Vector(-back, 0, 0))
    end
    -- insert here, less calculation
    if self.ExPitchBone != nil then
      local sway = -math.cos(TimeCount * 20) * 0.5 * (MovementTime - TimeCount)
      self.Entity:ManipulateBoneAngles(self.Entity:LookupBone(self.ExPitchBone), Angle(self.ExPitchBoneAng.x + sway, 0, 0))
    end
  end

end

function ENT:ReloadAmmo(ct)

	if !self.Reloaded and (ct > self:GetReloadTime()) then
		self:SetRounds(self.ClipSize)
		self.Reloaded = true
	end

end
