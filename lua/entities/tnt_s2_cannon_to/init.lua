
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")


local RecoilBoneIndex_ex1, RecoilBonePos_ex1, RecoilBoneAng_ex1, RecoilBoneIndex_ex2, RecoilBonePos_ex2, RecoilBoneAng_ex2

function ENT:Recoil(ct)

	RecoilBoneIndex = self.Entity:LookupBone(self.RecoilBone)
	RecoilBonePos, RecoilBoneAng = self.Entity:GetBonePosition(RecoilBoneIndex)
	RecoilBoneIndex_ex1 = self.Entity:LookupBone(self.RecoilBoneAdditional_1)
	RecoilBonePos_ex1, RecoilBoneAng_ex1 = self.Entity:GetBonePosition(RecoilBoneIndex_ex1)
	RecoilBoneIndex_ex2 = self.Entity:LookupBone(self.RecoilBoneAdditional_2)
	RecoilBonePos_ex2, RecoilBoneAng_ex2 = self.Entity:GetBonePosition(RecoilBoneIndex_ex2)

	recoil = (ct - self.LastShoot) * self.RecoilOffset
	back = (self.RecoilOffset * 1/self.RecoilRecoverPerThink) - (ct - self.LastShoot - 1/self.RecoilRecoverPerThink) * (0.5 * self.RecoilOffset)

	if (ct - self.LastShoot) < (3 * 1/self.RecoilRecoverPerThink) then
		if (ct - self.LastShoot) < 1/self.RecoilRecoverPerThink then

			self.Entity:ManipulateBonePosition(RecoilBoneIndex, Vector(-recoil, 0, 0))
			self.Entity:ManipulateBonePosition(RecoilBoneIndex_ex1, Vector(-recoil, 0, 0))
			self.Entity:ManipulateBonePosition(RecoilBoneIndex_ex2, Vector(-recoil, 0, 0))

		else

			self.Entity:ManipulateBonePosition(RecoilBoneIndex, Vector(-back, 0, 0))
			self.Entity:ManipulateBonePosition(RecoilBoneIndex_ex1, Vector(-back, 0, 0))
			self.Entity:ManipulateBonePosition(RecoilBoneIndex_ex2, Vector(-back, 0, 0))

		end
	end

end

function ENT:Shoot(ct, pos, ang, t)

	if (self:GetRounds() >= self.TakeAmmoPerShoot) then

		self:SetRounds(self:GetRounds() - self.TakeAmmoPerShoot)

		local damagemod = 1
		if t:IsValid() and t:IsPlayer() then
			damagemod = 0.2
		end

		local dice = math.Rand(0.9,1.15)
		local damage = self.BlastDamage * self.DamageScale * dice * damagemod

		local Muzzle_FX = EffectData()
			Muzzle_FX:SetEntity(self.Entity)
			Muzzle_FX:SetOrigin(pos)
			Muzzle_FX:SetNormal(ang:Forward())
			Muzzle_FX:SetScale(self.MuzzleScale)
			Muzzle_FX:SetAttachment(self.AimAttachment)
		util.Effect("gdcw_tnt_muzzle_cannon", Muzzle_FX)
		local Muzzle_Light = EffectData()
			Muzzle_Light:SetOrigin(pos)
			Muzzle_Light:SetScale(self.MuzzleLightScale)
		util.Effect("tnt_effect_light", Muzzle_Light)
		util.ScreenShake(pos, 0.04 * damage, 0.5 * damage, 0.75, 2 * self.BlastRadius)

		for i=1,3 do

			local bullet = {}
				bullet.Num 		= 1
				bullet.Src 		= self.Entity:GetAttachment(i+1).Pos			-- Source
				bullet.Dir 		= self.Entity:GetAttachment(i+1).Ang:Forward()			-- Dir of bullet
				bullet.Spread 	= Vector(self.Spread, self.Spread, 0)		-- Aim Cone
				bullet.Tracer	= 0									-- Show a tracer on every x bullets3
				bullet.Force	= self.HitDamage * 0.75									-- Amount of force to give to phys objects
				bullet.Damage	= self.HitDamage * self.DamageScale * dice * damagemod
				bullet.AmmoType = "Pistol"
				bullet.Callback	= function(attacker, tracedata, dmginfo)
					ParticleEffect(self.ImpactParticle, tracedata.HitPos, Angle(0, 0, 0), nil)
					local Impact_Light = EffectData()
						Impact_Light:SetOrigin(tracedata.HitPos)
					util.Effect("tnt_effect_light", Impact_Light)
					util.BlastDamage(self.Entity, self.Entity, tracedata.HitPos, self.BlastRadius, damage)
					-- sound.Play(self.ImpactExplosionSound, tracedata.HitPos, 100, 100 * GetConVarNumber("host_timescale"), 1)
					util.ScreenShake(tracedata.HitPos, 0.2 * damage, 1 * damage, 0.75, 1 * self.BlastRadius)
				end

			self.Entity:FireBullets(bullet)

		end

		sound.Play(self.TowerShootSound, pos, 90, math.Rand(95,105) * GetConVarNumber("host_timescale"), 1)

		self.LastShoot = ct

	end

end
