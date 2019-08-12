
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

	timer.Destroy("tower_ready_"..self:EntIndex())
	timer.Destroy("tnt_shoot_delay"..self.Entity:EntIndex())

	if IsValid(self.NPCCube) then
		self.NPCCube:Remove()
	end

end
