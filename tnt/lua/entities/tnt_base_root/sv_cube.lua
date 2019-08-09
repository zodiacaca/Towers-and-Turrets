
ENT.NPCCubeOffset = 64
ENT.NPCCubeRadius = 32
ENT.NPCCubeCycle = 2

function ENT:CreateNPCCube()

	self.NPCCube = ents.Create( "tnt_npc_cube" )
	if ( IsValid( self.NPCCube ) ) then
		self.NPCCube:SetPos( self:GetPos() + self:GetForward() * self.NPCCubeRadius + self:GetUp() * self.NPCCubeOffset )
		self.NPCCube:SetAngles( Angle( self:GetAngles().x, self:GetAngles().y, self:GetAngles().z ) )
		self.NPCCube:Spawn()
		self.NPCCube:Activate()
	end

end

function ENT:RotateNPCCube(ct)

	if IsValid(self.NPCCube) then
		local theta = ct * 2 * math.pi / self.NPCCubeCycle
		self.NPCCube:SetPos( self:GetPos() + self:GetForward() * self.NPCCubeRadius * math.cos(theta) + self:GetRight() * self.NPCCubeRadius * math.sin(theta) + self:GetUp() * self.NPCCubeOffset )
		local ang = Angle( self:GetAngles().x, self:GetAngles().y, self:GetAngles().z )
		ang:RotateAroundAxis( self:GetUp(), ct * 360 * 2 / self.NPCCubeCycle )
		self.NPCCube:SetAngles( ang )
	end

end

