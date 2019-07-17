
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")


function ENT:GetTargetA()

	local targets = {}

	for k,v in pairs(ents.GetAll()) do
		if v:IsValid() && (v:IsNPC() or (v:IsPlayer() and !GetConVar("ai_ignoreplayers"):GetBool() and GetConVar("tnt_attack_player"):GetBool())) then
			if !table.HasValue(tntfriends, string.lower(v:GetClass())) then
				if !(table.HasValue(tntgunfilter, string.lower(v:GetClass())) || table.HasValue(tntfilter, string.lower(v:GetClass())) || string.find(v:GetClass(), "bullseye")) then
					if self.Entity:GetPos():Distance(v:GetPos()) < self.TurretRange then
						if v:IsLineOfSightClear(self.Entity:GetPos() + self:GetUp() * self.AimHeight) and v:Health() > 0 then
							if IsValid(self.Owner) then
								local target = { ent = v, health = v:Health(), dist = self.Owner:GetPos():Distance(v:GetPos()) }
								table.insert(targets, target)
							else
								return v
							end
						end
					end
				end
			end
		end
	end

	if table.Count(targets) > 0 then

		if table.Count(targets) != 1 then
			self.UpdateDelay = self.UpdateDelayLong
		end

		table.SortByMember(targets, "dist", true)

		return targets[1].ent

	end

end

function ENT:GetTargetB()

	local targets = {}

	for k,v in pairs(ents.GetAll()) do
		if v:IsValid() && (v:IsNPC() or (v:IsPlayer() and !GetConVar("ai_ignoreplayers"):GetBool() and GetConVar("tnt_attack_player"):GetBool())) then
			if !table.HasValue(tntfriends, string.lower(v:GetClass())) then
				if !(table.HasValue(tntgunfilter, string.lower(v:GetClass())) || table.HasValue(tntfilter, string.lower(v:GetClass())) || string.find(v:GetClass(), "bullseye")) then
					if self.Entity:GetPos():Distance(v:GetPos()) < self.TurretRange then
						if v:IsLineOfSightClear(self.Entity:GetPos() + self:GetUp() * self.AimHeight) and v:Health() > 0 then
							if IsValid(self.Owner) then
								local target = { ent = v, health = v:Health(), dist = self.Owner:GetPos():Distance(v:GetPos()) }
								table.insert(targets, target)
							else
								return v
							end
						end
					end
				end
			end
		end
	end

	if table.Count(targets) > 0 then

		table.SortByMember(targets, "dist", true)

		if table.Count(targets) == 1 then

			if targets[1].ent != self.OldTarget then

				self.UpdateDelay = self.UpdateDelayLong
				return targets[1].ent

			end

		elseif targets[1].ent != self.OldTarget then

			self.UpdateDelay = self.UpdateDelayLong
			return targets[1].ent

		else

			self.UpdateDelay = self.UpdateDelayLong
			return targets[2].ent

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
	util.Effect("gdcw_tnt_muzzle_m60", Muzzle_FX)
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

	local ent = ents.Create( "tnt_linkbelt" )
	if ( IsValid( ent ) ) then
		ent:SetPos( p + a:Forward() * self.EjectOffset + a:Right() * 2)
		ent:SetAngles( a + Angle(0, 0, 0) )
		ent:Spawn()
		ent:Activate()

		local phys = ent:GetPhysicsObject()
		if ( IsValid( phys ) ) then
			phys:Wake() phys:AddAngleVelocity( Vector(math.Rand(-5,5), math.Rand(85,120), math.Rand(-45,45)) )
			phys:Wake() phys:AddVelocity( ent:GetRight() * 50 * math.Rand(0.6,1.4) )
		end
	end

	local Eject_FX = EffectData()
		Eject_FX:SetEntity(self.Entity)
		Eject_FX:SetOrigin(p + a:Forward() * self.EjectOffset)
		Eject_FX:SetNormal(a:Right())
		Eject_FX:SetScale(self.MuzzleScale)
		Eject_FX:SetAttachment(self.AimAttachment)
	util.Effect("gdcw_tnt_muzzle_m60_side", Eject_FX)

end
