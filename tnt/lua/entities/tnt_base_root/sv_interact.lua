
/*---------------------------------------------------------
   Name: Touch
---------------------------------------------------------*/
function ENT:StartTouch(ent)

	if !self.CanReload then return end

	if (self:GetReady() == false) then return end

	if (string.match(ent:GetClass(), "ammo", 0) || string.match(ent:GetClass(), "sent_ball", 0)) && (self:GetRounds() < self.ClipSize) then

		self:SetReloadTime(CurTime() + 1/self.ReloadSpeed)
		SafeRemoveEntity(ent)
		self.Entity:EmitSound(self.TurretReloadSound, 65, 100 * GetConVarNumber("host_timescale"))
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
