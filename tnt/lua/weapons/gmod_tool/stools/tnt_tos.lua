
TOOL.Category = "Towers and Turrets"
TOOL.Name = "Towers' Statistics"

TOOL.ClientConVar[ "scale" ] = "1"
TOOL.ClientConVar[ "spread" ] = "0.1"
TOOL.ClientConVar[ "range" ] = "1000"
TOOL.ClientConVar[ "cooldown" ] = "2"
TOOL.ClientConVar[ "br" ] = "128"
TOOL.ClientConVar[ "taps" ] = "1"

TOOL.Information = {
	{ name = "left" },
	{ name = "right" },
	{ name = "reload" },
	{ name = "reload_use", icon2 = "gui/e.png" }
}

if CLIENT then

	language.Add( "tool.tnt_tos.name", "Towers' Statistics" )
	language.Add( "tool.tnt_tos.desc", "Set the properties of towers" )
	language.Add( "tool.tnt_tos.left", "Set a tower to these statistics" )
	language.Add( "tool.tnt_tos.right", "Copy and print the infomation of the tower" )
	language.Add( "tool.tnt_tos.reload", "Aim at a tower to add an NPC to the friendly list" )
	language.Add( "tool.tnt_tos.reload_use", "Turn On/Off all the towers" )

end

function TOOL:LeftClick( trace )

	if !trace.Entity:IsValid() or !trace.Entity.Base or trace.Entity.Base != "tnt_base_deployable" then return false end

	if ( CLIENT ) then return true end

	local ds = self:GetClientNumber( "scale" )
	local s = self:GetClientNumber( "spread" )
	local r = self:GetClientNumber( "range" )
	local cd = self:GetClientNumber( "cooldown" )
	local br = self:GetClientNumber( "br" )
	local taps = self:GetClientNumber( "taps" )

	trace.Entity:SetDamageScale( ds )
	trace.Entity:SetSpread( s )
	trace.Entity:SetTowerRange( r )
	trace.Entity:SetCooldown( cd )
	trace.Entity:SetBlastRadius( br )
	trace.Entity:SetTakeAmmoPerShoot( taps )

	return true
end

function TOOL:RightClick( trace )

	if !trace.Entity:IsValid() or !trace.Entity.Base or trace.Entity.Base != "tnt_base_deployable" then return false end

	if ( CLIENT ) then return true end

	local ds  = trace.Entity.DamageScale
	local s  = trace.Entity.Spread * 10
	local r  = trace.Entity.TowerRange
	local cd  = trace.Entity.Cooldown
	local br  = trace.Entity.BlastRadius
	local taps  = trace.Entity.TakeAmmoPerShoot

	self:GetOwner():ChatPrint( "Damage Scale: "..ds.."" )
	self:GetOwner():ChatPrint( "Spread(*10): "..s.."" )
	self:GetOwner():ChatPrint( "Range: "..r.."" )
	self:GetOwner():ChatPrint( "Cooldown: "..cd.."" )
	self:GetOwner():ChatPrint( "Blast Radius: "..br.."" )
	self:GetOwner():ChatPrint( "Take Ammo Per Shoot: "..taps.."" )
	self:GetOwner():ConCommand( "tnt_tos_scale "..ds )
	self:GetOwner():ConCommand( "tnt_tos_spread "..s )
	self:GetOwner():ConCommand( "tnt_tos_range "..r )
	self:GetOwner():ConCommand( "tnt_tos_cooldown "..cd )
	self:GetOwner():ConCommand( "tnt_tos_br "..br )
	self:GetOwner():ConCommand( "tnt_tos_taps "..taps )

	return true
end

TOOL.TracerEntity = {}
local stat = false
function TOOL:Reload( trace )

	if ( SERVER ) then

		if self:GetOwner():KeyDown(IN_USE) then

			for k,v in pairs(ents.GetAll()) do
				if v.Base == "tnt_base_deployable" then
					v:SetReady(stat)
				end
			end
			stat = !stat

		else

			if !trace.Entity:IsValid() then return false end

			if trace.Entity:IsNPC() then
				self.TracerEntity[1] = trace.Entity
			elseif self.TracerEntity[1] != nil then
				if trace.Entity.Base == "tnt_base_deployable" then
					trace.Entity:SetFriends( self.TracerEntity[1]:GetClass())
					print(self.TracerEntity[1]:GetClass())
				end
			else
				return false
			end

		end

	end

	return true
end

function TOOL.BuildCPanel( CPanel )

	CPanel:AddControl( "Slider", { Label = "DamageScale", Command = "tnt_tos_scale", Type = "Float", Min = 0, Max = 10 } )
	CPanel:AddControl( "Slider", { Label = "Spread(*10)", Command = "tnt_tos_spread", Type = "Float", Min = 0, Max = 1 } )
	CPanel:AddControl( "Slider", { Label = "Range", Command = "tnt_tos_range", Type = "Int", Min = 0, Max = 15000 } )
	CPanel:AddControl( "Slider", { Label = "Cooldown", Command = "tnt_tos_cooldown", Type = "Float", Min = 0.1, Max = 5 } )
	CPanel:AddControl( "Slider", { Label = "BlastRadius", Command = "tnt_tos_br", Type = "Int", Min = 0, Max = 256 } )
	CPanel:AddControl( "Slider", { Label = "TakeAmmoPerShoot", Command = "tnt_tos_taps", Type = "Float", Min = 0.1, Max = 1 } )

end