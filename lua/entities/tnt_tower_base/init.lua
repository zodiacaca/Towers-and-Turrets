
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:SpawnFunction(ply, tr)

	if !tr.Hit then return end

	local td = {
		start = tr.HitPos,
		endpos = tr.HitPos + Vector(0, 0, 33000),
		filter = { self.Entity }
		}
	local skycheck = util.TraceLine(td)
	if !skycheck.HitSky then
		ply:EmitSound(Sound("buttons/button10.wav"))
		ply:ChatPrint("Not enough clearance above target position.")
		return
	end

	local trd = {
		start = tr.HitPos,
		endpos = tr.HitPos + Vector(0, 0, 3600),
		filter = { self.Entity }
		}
	local skyboxcheck = util.TraceLine(trd)
	if skyboxcheck.HitSky then
		ply:EmitSound(Sound("buttons/button10.wav"))
		ply:ChatPrint("Summoning a tower requires a map with a bigger skybox.")
		return
	end

	-- local count = 0
	-- for k,v in pairs(ents.GetAll()) do
	-- 	if !(v:GetClass() == "tnt_towerbase") && v:GetClass() == self.Tower then
	-- 		count = count + 1
	-- 	end
	-- end
	-- if count >= 10 then
	-- 	ply:EmitSound(Sound("buttons/button10.wav"))
	-- 	ply:ChatPrint("Maximum reached!")
	-- 	return false
	-- end

	local Pos = tr.HitPos
	if Pos.x >= 0 then
		if math.fmod(Pos.x, 80) >= 40 then
			Pos.x = math.floor(Pos.x/80) * 80 + 80
		else
			Pos.x = math.floor(Pos.x/80) * 80
		end
	else
		if math.fmod(math.abs(Pos.x),80) >= 40 then
			Pos.x = -math.floor(math.abs(Pos.x)/80) * 80 - 80
		else
			Pos.x = -math.floor(math.abs(Pos.x)/80) * 80
		end
	end
	if Pos.y >= 0 then
		if math.fmod(Pos.y, 80) >= 40 then
			Pos.y = math.floor(Pos.y/80) * 80 + 80
		else
			Pos.y = math.floor(Pos.y/80) * 80
		end
	else
		if math.fmod(math.abs(Pos.y), 80) >= 40 then
			Pos.y = -math.floor(math.abs(Pos.y)/80) * 80 - 80
		else
			Pos.y = -math.floor(math.abs(Pos.y)/80) * 80
		end
	end

	local ent = ents.Create(self.Tower)

	ent:SetPos(Pos + Vector(0, 0, 3600))
	ent:SetAngles(Angle(0, 0, 0))
	ent:Spawn()
	ent:Activate()

	return ent
end

/*---------------------------------------------------------
   Name: Initialize
---------------------------------------------------------*/
function ENT:Initialize()

	self:PrecacheParticles()

	local model = (self.TowerModel)

	self.Entity:SetModel(model)

	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:DrawShadow(false)

	local phys = self.Entity:GetPhysicsObject()
	if phys:IsValid() then
		-- phys:EnableGravity(false)
		-- phys:EnableCollisions(false)
		-- phys:EnableMotion(false)
		-- phys:EnableDrag(false)
		phys:Wake()
	end

	self.Entity:SetUseType(SIMPLE_USE)

	self:CreateIndicator()

	self:SetHealth(self.TowerHealth)

	if self.SettleAngleRandom then
		self.Entity:ManipulateBoneAngles(self.Entity:LookupBone(self.AimYawBone), Angle(0, math.random(0,360), 0))
	end

	self.YawMotorThrottle = 0
	self.PitchMotorThrottle = 0
	self.Collided = false
	self.LastTargetTime = CurTime()
	self.LastShoot = CurTime()
	self.UpdateDelay = self.UpdateDelayLong
	self:SetRounds(self.ClipSize)
	self.Reloaded = true
	self:SetReloadTime(CurTime())
	self.Fires = 0
	self.Num = 0
	for k,v in pairs(ents.GetAll()) do
		if (v.SettleAnim == true) then
			self.Num = self.Num + 1
		end
	end
	self.Explored = false
	self.PlanB = false
	self:SetReady(false)
	self.tOwner = self:GetCreator()
	self.TurningLoop = CreateSound(self.Entity, self.TowerTurningSound)

	self:SetTrigger(true)	-- Touch

end

function ENT:PrecacheParticles()

	if self.ImpactParticle != nil then
		PrecacheParticleSystem(self.ImpactParticle)
	end

end

function ENT:CreateIndicator()

	local td = {
		start = self:GetPos(),
		endpos = self:GetPos() + Vector(0, 0, -33000),
		filter = { self.Entity }
		}
	local tr = util.TraceLine(td)

	if tr.Hit then
		local pos = tr.HitPos
		local ent = ents.Create( "tnt_indicator" )
		if ( IsValid( ent ) ) then
			ent:SetPos( pos )
			ent:SetAngles( Angle( 0, 0, 0 ) )
			ent:Spawn()
			ent:Activate()
		end
	end

end

/*---------------------------------------------------------
   Recive the new statistics from stool
---------------------------------------------------------*/
function ENT:SetDamageScale( scale )
	self.DamageScale = scale
end

function ENT:SetSpread( spread )
	self.Spread = spread/10
end

function ENT:SetTowerRange( range )
	self.TowerRange = range
end

function ENT:SetCooldown( cooldown )
	self.Cooldown = cooldown
end

function ENT:SetBlastRadius( radius )
	self.BlastRadius = radius
end

function ENT:SetTakeAmmoPerShoot( ammo )
	self.TakeAmmoPerShoot = ammo
end

function ENT:SetFriends( friend )
	table.insert(tntfriends, string.lower(friend))
end

/*---------------------------------------------------------
   Name: PhysicsCollide
---------------------------------------------------------*/
local poorbastards = {
	"npc_citizen",
	"npc_alyx",
	"npc_barney",
	"npc_kleiner",
	"npc_mossman",
	"npc_eli",
	"npc_gman",
	"npc_breen",
	"npc_monk",
	"npc_fassassin",
	"npc_combine_s",
	"npc_metropolice",
	"npc_zombine",
	"npc_poisonzombine"
	}
local vehicle = {
	"vehicle",
	"jeep",
	"car"
	}
function ENT:PhysicsCollide(data, phys)

	if not IsValid(self.Entity) then return end

	local angle = self.Entity:GetAngles()

	if !data.HitEntity:IsValid() then
		self:CollideEffect()
		if self.SettleAnim then
			local sequence = self:LookupSequence("settle")
			self:SetSequence(sequence)
			self:SetPlaybackRate(1)
			local time = self:SequenceDuration()
			timer.Create("tower_ready_"..self.Num.."", time, 1, function() self:SetReady(true) end)
		else
			self:SetReady(true)
		end
		self.Collided = true
		if math.abs(angle.r) < 45 then
			self.Entity:DrawShadow(false)
			phys:EnableMotion(false)
			phys:Sleep()
		end
	elseif data.HitEntity:IsValid() then
		if table.HasValue(poorbastards, string.lower(data.HitEntity:GetClass())) or data.HitEntity:IsPlayer() then
			if !self.Collided then
				local effectdata = EffectData()
					effectdata:SetOrigin(data.HitEntity:GetPos() + Vector(0, 0, -32))
					effectdata:SetScale(1.6)
				util.Effect("m9k_gdcw_tnt_blood_cloud", effectdata)
			end
		end

	for i=1,2 do
		if string.match(data.HitEntity:GetClass(), vehicle[i], 1) then
			return
		end
	end

	if !data.HitEntity:IsPlayer() and math.abs(angle.r) < 15 then
		if !self.Collided then
			SafeRemoveEntity(data.HitEntity)
			end
		end
	end

end

function ENT:CollideEffect()

	if self.Collided then return end

	local effectdata = EffectData()
		effectdata:SetEntity(self.Entity)		// Who done it?
		effectdata:SetOrigin(self.Entity:GetPos() + Vector(0, 0, -48))
		effectdata:SetScale(0.8)
		effectdata:SetMagnitude(50)			// Length of explosion trails
	util.Effect("m9k_gdcw_tnt_boom", effectdata)
	util.BlastDamage(self.Entity, self.Entity, self.Entity:GetPos(), 96, 200 )
	util.ScreenShake(self.Entity:GetPos(), 16, 250, 1, 512)
	sound.Play("tnt/tower_impact"..math.random(1,3)..".ogg", self.Entity:GetPos(), 150, math.Rand(80,120) * GetConVarNumber("host_timescale"), 1)

end

/*---------------------------------------------------------
   Name: OnTakeDamage
---------------------------------------------------------*/
function ENT:OnTakeDamage(dmginfo)

	if dmginfo:GetDamageType() ~= DMG_SLASH then

		local health = self:Health() - dmginfo:GetDamage()
		health = math.Clamp(health, 0, 10000)
		local dice = math.random(1,3)

		self:SetHealth(health)

		if (self:Health() <= 0.6 * self.TowerHealth) and (dmginfo:GetDamage() > 30) and (dice == 1) then
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

	local a = 255 * (self:Health()/self.TowerHealth)
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
			if !ouchies.Entity.Base == "tnt_tower_base" then
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

	self.Explored = true

	self:Remove()

end

local CT, target
local YawBoneIndex, YawBonePos, YawBoneAng, PitchBoneIndex, PitchBonePos, PitchBoneAng, BoneIndexT
local YawBonePos_w, YawBoneAng_w, PitchBonePos_w, PitchBoneAng_w
local aimpos_w, aimang_w, aimpos, aimang, ang_aim_y, ang_aim_p, yawDiff, pitchDiff, newpos, newang, clampDelta
local RecoilBoneIndex, RecoilBonePos, RecoilBoneAng
local attpos, attang
local recoil, back
local p_AngDiff = { y = 0, p = 0 }

/*---------------------------------------------------------
   Name: Think
---------------------------------------------------------*/
function ENT:Think()

	if !self.Collided then
		local phys = self:GetPhysicsObject()
		if ( IsValid( phys ) ) then phys:AddVelocity( -self:GetUp() * 16 ) end
	end

	CT = CurTime()

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

function ENT:UpdateTarget(ct, target)

	-- this target updating system is beyond my ability, it works and I don't really know the relationships between them
	if (ct - self.LastTargetTime) > self.UpdateDelay then

		self.LastTargetTime = ct

		if target == self.OldTarget then
			self.PlanB = !self.PlanB
		end

		self.OldTarget = target

	end

end

function ENT:TurningTurret(ct)

	if GetConVar("ai_disabled"):GetBool() then return end

	if self.PlanB then
		target = self:GetTargetB()
	else
		target = self:GetTargetA()
	end
	self:UpdateTarget(ct, target)

	if (self:GetReady() == true) and (ct > self:GetReloadTime()) and (target != nil) then

		-- Prepare the bones
		YawBoneIndex = self.Entity:LookupBone(self.AimYawBone)
		YawBonePos_w, YawBoneAng_w = self.Entity:GetBonePosition(YawBoneIndex)
		PitchBoneIndex = self.Entity:LookupBone(self.AimPitchBone)
		PitchBonePos_w, PitchBoneAng_w = self.Entity:GetBonePosition(PitchBoneIndex)
		YawBonePos, YawBoneAng = self:TranslateCoordinateSystem(YawBonePos_w, YawBoneAng_w)
		PitchBonePos, PitchBoneAng = self:TranslateCoordinateSystem(PitchBonePos_w, PitchBoneAng_w)

		-- Angles between the target and the bones
		BoneIndexT = target:LookupBone(target:GetBoneName(1))
		if BoneIndexT == nil then
			self.PlanB = !self.PlanB
			return
		end
		aimpos_w, aimang_w = target:GetBonePosition(BoneIndexT)
		aimpos, aimang = self:TranslateCoordinateSystem(aimpos_w, aimang_w)
		ang_aim_y = (aimpos - YawBonePos):Angle()
		ang_aim_p = (aimpos - PitchBonePos):Angle()
		if ang_aim_p.x >= self.PitchLimitDown && ang_aim_p.x <= self.PitchLimitUp then
			if self.TurningLoop then
				self.TurningLoop:Stop()
			end
			self.PlanB = !self.PlanB
			return
		end

		-- The angle differences between them
		yawDiff = ang_aim_y - YawBoneAng
		pitchDiff = ang_aim_p - PitchBoneAng

		-- Make sure the turret don't turn like a maniac
		if math.abs(yawDiff.y) > 180 then
			yawDiff.y = -yawDiff.y/math.abs(yawDiff.y) * (360 - math.abs(yawDiff.y))
		end
		if math.abs(pitchDiff.x) > 180 then
			pitchDiff.x = -pitchDiff.x/math.abs(pitchDiff.x) * (360 - math.abs(pitchDiff.x))
		end

		-- throttle
		local ratio = 0.25
		if p_AngDiff.y * yawDiff.y <= 0 then
			self.YawMotorThrottle = 0
		else
			self.YawMotorThrottle = Lerp(0.1, self.YawMotorThrottle, math.Clamp(math.abs(yawDiff.y) / self.AngularSpeed, 0, 1))
		end
		if p_AngDiff.p * pitchDiff.p <= 0 then
			self.PitchMotorThrottle = 0
		else
			self.PitchMotorThrottle = Lerp(0.1, self.PitchMotorThrottle, math.Clamp(math.abs(pitchDiff.x) / (self.AngularSpeed * ratio), 0, 1))
		end
		p_AngDiff.y = yawDiff.y
		p_AngDiff.p = pitchDiff.p

		clampDelta = self.AngularSpeed * GetConVarNumber("host_timescale")
		yawDiff.y = math.Clamp(yawDiff.y, -clampDelta, clampDelta) * self.YawMotorThrottle
		pitchDiff.x = math.Clamp(pitchDiff.x, -clampDelta, clampDelta) * ratio * self.PitchMotorThrottle

		-- Turning
		self.Entity:ManipulateBoneAngles(YawBoneIndex, Angle(0, YawBoneAng.y - self.ExistAngle + yawDiff.y, 0))
		self.Entity:ManipulateBoneAngles(PitchBoneIndex, Angle(PitchBoneAng.x + pitchDiff.x, 0, 0))
		-- print(pitchDiff.x)
		self:TurningSound()
		self:Aiming(ct, target)

	else

		self.YawMotorThrottle = 0
		self.PitchMotorThrottle = 0
		-- self:EliminateHesitation()
		self.UpdateDelay = self.UpdateDelayShort
		if self.TurningLoop then self.TurningLoop:Stop() end

	end

end

function ENT:TranslateCoordinateSystem(pos, ang)

	newpos, newang = WorldToLocal(pos, ang, self.Entity:GetPos(), self.Entity:GetAngles())

	return newpos, newang
end

function ENT:EliminateHesitation()

	local targets = {}

	-- the hesitation delay equals to the short update delay time, so use a small number like 0.5, and it's not so necessary so leave it in the comments
	for k,v in pairs(ents.GetAll()) do
		if v:IsValid() && v:IsNPC() then
			if !(table.HasValue(tntfriends, string.lower(v:GetClass())) || table.HasValue(tntfilter, string.lower(v:GetClass())) || string.match(v:GetClass(), "bullseye")) then
				if self.Entity:GetPos():Distance(v:GetPos()) < self.TurretRange then
					if v:IsLineOfSightClear(self.Entity:GetPos() + self:GetUp() * self.AimHeight) and v:Health() > 0 then
						table.insert(targets, v)
					end
				end
			end
		end
	end

	if table.Count(targets) == 1 and self.OldTarget != nil then

		self.UpdateDelay = 0

	end

end

function ENT:GetTargetA()

	local targets = {}

	for k,v in pairs(ents.GetAll()) do
		if v:IsValid() && (v:IsNPC() or (v:IsPlayer() and !GetConVar("ai_ignoreplayers"):GetBool() and GetConVar("tnt_attack_player"):GetBool())) then
			if !(table.HasValue(tntfriends, string.lower(v:GetClass())) || table.HasValue(tntfilter, string.lower(v:GetClass())) || string.match(v:GetClass(), "bullseye")) then
				if self.Entity:GetPos():Distance(v:GetPos()) < self.TowerRange then
					if v:IsLineOfSightClear(self.Entity:GetPos() + self:GetUp() * self.AimHeight) and v:Health() > 0 then
						local target = { ent = v, health = v:Health() }
						table.insert(targets, target)
					end
				end
			end
		end
	end

	if table.Count(targets) > 0 then

		if table.Count(targets) != 1 then
			self.UpdateDelay = self.UpdateDelayLong
		end

		table.SortByMember(targets, "health", true)

		return targets[1].ent

	end

end

function ENT:GetTargetB()

	local targets = {}

	for k,v in pairs(ents.GetAll()) do
		if v:IsValid() && (v:IsNPC() or (v:IsPlayer() and !GetConVar("ai_ignoreplayers"):GetBool() and GetConVar("tnt_attack_player"):GetBool())) then
			if !(table.HasValue(tntfriends, string.lower(v:GetClass())) || table.HasValue(tntfilter, string.lower(v:GetClass())) || string.match(v:GetClass(), "bullseye")) then
				if self.Entity:GetPos():Distance(v:GetPos()) < self.TowerRange then
					if v:IsLineOfSightClear(self.Entity:GetPos() + self:GetUp() * self.AimHeight) and v:Health() > 0 then
						local target = { ent = v, health = v:Health() }
						table.insert(targets, target)
					end
				end
			end
		end
	end

	if table.Count(targets) > 0 then

		table.SortByMember(targets, "health", true)

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

function ENT:TurningSound()

	if self.TowerTurningSound == nil then return end

	if self.TurningLoop then
		if p_AngDiff.y != yawDiff.y then
			self.TurningLoop:Play()
			self.TurningLoop:ChangeVolume(math.Clamp(self.YawMotorThrottle, 0.2, 1))
			self.TurningLoop:ChangePitch(100 * GetConVarNumber("host_timescale"))
		else
			self.TurningLoop:Stop()
		end
	else
		self.TurningLoop = CreateSound(self.Entity, self.TowerTurningSound)
	end

end

function ENT:Aiming(ct, t)

	if self.AimAttachment == nil then
		print("AimAttachment expected, got nil")
		return
	end

	attpos = self.Entity:GetAttachment(self.AimAttachment).Pos
	attang = self.Entity:GetAttachment(self.AimAttachment).Ang

	local max = 16

	local td = {
		start = attpos,
		endpos = attpos + attang:Forward() * 33000,
		maxs = Vector(max, max, max),
		mins = Vector(-max, -max, -max),
		filter = { self.Entity }
		}
	local tr = util.TraceHull(td)

	if (ct > (self.LastShoot + self.Cooldown)) then
		if tr.Entity:IsValid() and ((!GetConVar("tnt_attack_owner"):GetBool() and !(tr.Entity == self.tOwner)) or GetConVar("tnt_attack_owner"):GetBool()) then
			timer.Simple(0.001, function()
				self:Shoot(ct, attpos, attang, t)
			end)
		end
	end

end

function ENT:Shoot(ct, pos, ang)

	if (self:GetRounds() >= self.TakeAmmoPerShoot) then

		self:SetRounds(self:GetRounds() - self.TakeAmmoPerShoot)

		local damagemod = 1
		if t:IsValid() and t:IsPlayer() then
			damagemod = 0.1
		end

		local dice = math.Rand(0.9,1.15)
		local damage = self.BlastDamage * self.DamageScale * dice * damagemod

		self:MuzzleEffects(pos, ang)
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
					util.Effect("tnt_effect_light", effectdata2)
					util.BlastDamage(self.Entity, self.Entity, tracedata.HitPos, self.BlastRadius, damage)
					sound.Play(self.ImpactExplosionSound, tracedata.HitPos, 100, 100 * GetConVarNumber("host_timescale"), 1)
					util.ScreenShake(tracedata.HitPos, 0.2 * damage, 1 * damage, 0.75, 1 * self.BlastRadius)
				end
			end

		self.Entity:FireBullets(bullet)

		sound.Play(self.TowerShootSound, pos, 100, math.Rand(95,105) * GetConVarNumber("host_timescale"), 1 )

		self.LastShoot = ct

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

function ENT:Recoil(ct)

	if self.RecoilBone == nil then return end

	RecoilBoneIndex = self.Entity:LookupBone(self.RecoilBone)
	RecoilBonePos, RecoilBoneAng = self.Entity:GetBonePosition(RecoilBoneIndex)

	recoil = (ct - self.LastShoot) * self.RecoilOffset
	back = (self.RecoilOffset * 1/self.RecoilRecoverPerThink) - (ct - self.LastShoot - 1/self.RecoilRecoverPerThink) * (0.5 * self.RecoilOffset)

	if (ct - self.LastShoot) < (3 * 1/self.RecoilRecoverPerThink) then
		if (ct - self.LastShoot) < 1/self.RecoilRecoverPerThink then
			self.Entity:ManipulateBonePosition(RecoilBoneIndex, Vector(-recoil, 0, 0))
		else
			self.Entity:ManipulateBonePosition(RecoilBoneIndex, Vector(-back, 0, 0))
		end
	end

end

function ENT:ReloadAmmo(ct)

	if !self.Reloaded and (ct > self:GetReloadTime()) then
		self:SetRounds(self.ClipSize)
		self.Reloaded = true
	end

end

/*---------------------------------------------------------
   Name: Touch
---------------------------------------------------------*/
function ENT:StartTouch(ent)

	if !self.CanReload then return end

	if (self:GetReady() == false) then return end

	if (string.match(ent:GetClass(), "ammo", 0) || string.match(ent:GetClass(), "sent_ball", 0)) && (self:GetRounds() < self.ClipSize) then

		self:SetReloadTime(CurTime() + 1/self.ReloadSpeed)
		SafeRemoveEntity(ent)
		self.Entity:EmitSound(self.TowerReloadSound, 65, 100 * GetConVarNumber("host_timescale"))
		self.Reloaded = false

	end

end

function ENT:EndTouch(ent)
end

function ENT:Touch(ent)
end

/*---------------------------------------------------------
   Name: Use
---------------------------------------------------------*/
function ENT:Use()

	self:SetReady(!self:GetReady())

end

/*---------------------------------------------------------
   Name: OnRemove
---------------------------------------------------------*/
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

	timer.Destroy("tower_ready_"..self.Num.."")

end