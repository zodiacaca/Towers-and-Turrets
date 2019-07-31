
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

include("exclusive_effects.lua")


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
