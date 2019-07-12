
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")

function ENT:SpawnFunction( ply, tr )

	local count = 0
	for k,v in pairs(ents.GetAll()) do
		if v:GetClass() == self.Turret then
			count = count + 1
		end
	end
	if count >= 10 then
		ply:EmitSound(Sound("buttons/button10.wav"))
		ply:ChatPrint("Turret cap has been reached!")
		return false
	end

	if ( !tr.Hit ) then return end

	local SpawnPos = tr.HitPos + tr.HitNormal * 10
	local SpawnAng = ply:EyeAngles()
	SpawnAng.p = 0
	SpawnAng.y = SpawnAng.y + 180

	local ent = ents.Create( self.Turret )
		ent:SetCreator( ply )
		ent:SetPos( SpawnPos )
		ent:SetAngles( SpawnAng )
	ent:Spawn()
	ent:Activate()

	ent:DropToFloor()

	return ent
end

/*---------------------------------------------------------
   Name: Initialize
---------------------------------------------------------*/
function ENT:Initialize()

	self:PrecacheParticles()

	local model = (self.TurretModel)

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

	self:SetHealth(self.TurretHealth)

	if self.SettleAngleRandom then
		self.Entity:ManipulateBoneAngles(self.Entity:LookupBone(self.AimYawBone), Angle(0, math.random(0,360), 0))
	end

	self.YawMotorThrottle = 0
	self.PitchMotorThrottle = 0
	self.LastTargetTime = CurTime()
	self.LastShoot = CurTime()
	self.UpdateDelay = self.UpdateDelayLong
	self:SetRounds(self.ClipSize)
	self:SetReloadTime(CurTime())
	self.LoopDelay = 0
	self.Fires = 0
	self.Num = 0
	self.Explored = false
	self.PlanB = false
	self:SetReady(true)
	self.tOwner = self:GetCreator()
	self.TurningLoop = CreateSound(self.Entity, self.TurretTurningSound)

	self:SetTrigger(true)	-- Touch

end

function ENT:PrecacheParticles()

	if self.ImpactParticle != nil then
		PrecacheParticleSystem(self.ImpactParticle)
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

function ENT:SetTurretRange( range )
	self.TurretRange = range
end

function ENT:SetCooldown( cooldown )
	self.Cooldown = cooldown
end

function ENT:SetBlastRadius( radius )
	self.BlastRadius = radius
end

function ENT:SetFriends( friend )
	table.insert(tntfriends, string.lower(friend))
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

		if (self:Health() <= 0.6 * self.TurretHealth) and (dmginfo:GetDamage() > 30) and (dice == 1) then
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

	self.Explored = true

	self:Remove()

end

local CT, target
local YawBoneIndex, YawBonePos, YawBoneAng, PitchBoneIndex, PitchBonePos, PitchBoneAng, BoneIndexT
local YawBonePos_w, YawBoneAng_w, PitchBonePos_w, PitchBoneAng_w
local aimpos_w, aimang_w, aimpos, aimang, ang_aim_y, ang_aim_p, angdif_y, angdif_p, newpos, newang, clampDelta
local RecoilBoneIndex, RecoilBonePos, RecoilBoneAng
local attpos, attang
local recoil, back
local p_angdif = 0
local p_yaw = 0

/*---------------------------------------------------------
   Name: Think
---------------------------------------------------------*/
function ENT:Think()

	CT = CurTime()

	if self.TowerIdleSound != nil then
		if self.LoopSound then
			if !(self:GetReady() == true) or !(CT > self:GetReloadTime()) then
				self.LoopSound:ChangeVolume(0, 0.5)
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

	self:NextThink(CurTime())

	return true
end

function ENT:UpdateTarget(ct, target)

	if (ct - self.LastTargetTime) > self.UpdateDelay and !self.TurningLoop:IsPlaying() then

		self.LastTargetTime = ct

		if target == self.OldTarget then
			self.PlanB = !self.PlanB
		end

		self.OldTarget = target

	end

end

-- ENT.Time = 0
function ENT:TurningTurret(ct)

	if GetConVar("ai_disabled"):GetBool() then return end

	-- if ct > self.Time then
		-- self.Time = ct + 3
		-- local tbl = {
			-- ["tgt_time"] = self.LastTargetTime,
			-- ["delay"] = self.UpdateDelay,
			-- ["planB"] = self.PlanB,
			-- ["tgt"] = target,
			-- ["old_tgt"] = self.OldTarget,
			-- ["tgt = old_tgt"] = (target == self.OldTarget)
		-- }
		-- PrintTable(tbl)
	-- end

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
		angdif_y = ang_aim_y - YawBoneAng
		angdif_p = ang_aim_p - PitchBoneAng

		-- Make sure the turret don't turn like a maniac
		if math.abs(angdif_y.y) > 180 then
			angdif_y.y = -angdif_y.y/math.abs(angdif_y.y) * (360 - math.abs(angdif_y.y))
		end
		if math.abs(angdif_p.x) > 180 then
			angdif_p.x = -angdif_p.x/math.abs(angdif_p.x) * (360 - math.abs(angdif_p.x))
		end

		-- throttle
		local ratio = 0.25
		self.YawMotorThrottle = Lerp(0.2, self.YawMotorThrottle, math.Clamp(math.abs(angdif_y.y) / self.AngularSpeed, 0, 1))
		self.PitchMotorThrottle = Lerp(0.2, self.PitchMotorThrottle, math.Clamp(math.abs(angdif_p.x) / (self.AngularSpeed * ratio), 0, 1))

		-- Acceleration
		clampDelta = self.AngularSpeed * GetConVarNumber("host_timescale")
		angdif_y.y = math.Clamp(angdif_y.y, -clampDelta, clampDelta) * self.YawMotorThrottle
		angdif_p.x = math.Clamp(angdif_p.x, -clampDelta, clampDelta) * ratio * self.PitchMotorThrottle

		-- Turning
		self.Entity:ManipulateBoneAngles(YawBoneIndex, Angle(0, YawBoneAng.y - self.ExistAngle + angdif_y.y, 0))
		self.Entity:ManipulateBoneAngles(PitchBoneIndex, Angle(PitchBoneAng.x + angdif_p.x, 0, 0))
		-- print(angdif_p.x)
		self:TurningSound(ct, angdif_y.y)
		self:Aiming(ct)

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
				if self.Entity:GetPos():Distance(v:GetPos()) < self.TurretRange then
					if v:IsLineOfSightClear(self.Entity:GetPos() + self:GetUp() * self.AimHeight) and v:Health() > 0 then
						if IsValid(self.tOwner) then
							local target = { ent = v, health = v:Health(), dist = self.tOwner:GetPos():Distance(v:GetPos()) }
							table.insert(targets, target)
						else
							return v
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

		table.SortByMember(targets, "health", true)

		return targets[1].ent

	end

end

function ENT:GetTargetB()

	local targets = {}

	for k,v in pairs(ents.GetAll()) do
		if v:IsValid() && (v:IsNPC() or (v:IsPlayer() and !GetConVar("ai_ignoreplayers"):GetBool() and GetConVar("tnt_attack_player"):GetBool())) then
			if !(table.HasValue(tntfriends, string.lower(v:GetClass())) || table.HasValue(tntfilter, string.lower(v:GetClass())) || string.match(v:GetClass(), "bullseye")) then
				if self.Entity:GetPos():Distance(v:GetPos()) < self.TurretRange then
					if v:IsLineOfSightClear(self.Entity:GetPos() + self:GetUp() * self.AimHeight) and v:Health() > 0 then
						if IsValid(self.tOwner) then
							local target = { ent = v, health = v:Health(), dist = self.tOwner:GetPos():Distance(v:GetPos()) }
							table.insert(targets, target)
						else
							return v
						end
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

function ENT:TurningSound(ct, angdif)

	if self.TurretTurningSound == nil then return end

	if self.TurningLoop then
		if math.abs(p_angdif - angdif) > 0.05 then
			self.TurningLoop:Play()
			self.TurningLoop:ChangeVolume(math.Clamp(self.YawMotorThrottle, 0.35, 1))
			self.TurningLoop:ChangePitch(100 * GetConVarNumber("host_timescale"))
			self.LoopDelay = ct + 0.3
		elseif  ct > self.LoopDelay then
			self.TurningLoop:Stop()
		end
	else
		self.TurningLoop = CreateSound(self.Entity, self.TurretTurningSound)
	end
	p_angdif = angdif

end

function ENT:Aiming(ct)

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
				self:Shoot(ct, attpos, attang)
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

		local phys = self:GetPhysicsObject()
		if ( IsValid( phys ) ) then phys:AddVelocity( -ang:Forward() * (0.6 * self.BlastDamage + 3 * self.HitDamage)) end

		self.LastShoot = ct

	else

		self:SetReloadTime(CurTime() + 1/self.ReloadSpeed)
		self:SetRounds(self.ClipSize)
		self.Entity:EmitSound(self.TurretReloadSound, 65, 100 * GetConVarNumber("host_timescale"))

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

end