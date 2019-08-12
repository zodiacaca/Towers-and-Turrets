

TOOL.Category = "Towers and Turrets"
TOOL.Name = "[Cleanup]"

TOOL.Information = {
	{ name = "left_use", icon2 = "gui/e.png" },
	{ name = "right_use", icon2 = "gui/e.png" }
}

if CLIENT then

	language.Add( "tool.tnt_cleanup.name", "Cleanup" )
	language.Add( "tool.tnt_cleanup.desc", "" )
	language.Add( "tool.tnt_cleanup.left_use", "Remove all the towers" )
	language.Add( "tool.tnt_cleanup.right_use", "Remove all the turrets" )

end

function TOOL:LeftClick( trace )

	if ( CLIENT ) or !self:GetCreator():KeyDown(IN_USE) then return end

	if !self:GetCreator():IsAdmin() then
		self:GetCreator():ChatPrint("You need to be an admin to use this tool.")
		return
	end

	local Selected = 0
	for k,v in pairs(ents.GetAll()) do
		if v.Base == "tnt_base_deployable" then
			Selected = Selected + 1
			self:DoRemoveEntity(v)
		end
	end
	self:GetCreator():PrintMessage( HUD_PRINTTALK, "".. Selected .." towers were removed." )

	return true
end

function TOOL:RightClick( trace )

	if ( CLIENT ) or !self:GetCreator():KeyDown(IN_USE) then return end

	if !self:GetCreator():IsAdmin() then
		self:GetCreator():ChatPrint("You need to be an admin to use this tool.")
		return
	end

	local Selected = 0
	for k,v in pairs(ents.GetAll()) do
		if v.Base == "tnt_base_attachable" then
			Selected = Selected + 1
			self:DoRemoveEntity(v)
		end
	end
	self:GetCreator():PrintMessage( HUD_PRINTTALK, "".. Selected .." turrets were removed." )

	return true
end

function TOOL:DoRemoveEntity(ent)

	if ( !IsValid( ent ) || ent:IsPlayer() ) then return false end

	-- Nothing for the client to do here
	if ( CLIENT ) then return true end

	-- Remove all constraints (this stops ropes from hanging around)
	constraint.RemoveAll( ent )

	-- Remove it properly in 1 second
	timer.Simple( 1, function() if ( IsValid( ent ) ) then ent:Remove() end end )

	-- Make it non solid
	ent:SetNotSolid( true )
	ent:SetMoveType( MOVETYPE_NONE )
	ent:SetNoDraw( true )

	-- Send Effect
	local ed = EffectData()
	ed:SetEntity( ent )
	util.Effect( "entity_remove", ed, true, true )

end

function TOOL:Reload( trace )
	return false
end

function TOOL.BuildCPanel( CPanel )

	CPanel:AddControl( "Header", { Description = "Remove towers and turrets" } )

end