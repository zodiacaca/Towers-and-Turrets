
TOOL.Category = "Towers and Turrets"
TOOL.Name = "Turrets' Statistics"

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

	language.Add( "tool.tnt_tus.name", "Turrets' Statistics" )
	language.Add( "tool.tnt_tus.desc", "Set the properties of turrets" )
	language.Add( "tool.tnt_tus.left", "Set a turret to these statistics" )
	language.Add( "tool.tnt_tus.right", "Copy and print the infomation of the turret" )
	language.Add( "tool.tnt_tus.reload", "Aim at a turret to add an NPC to the friendly list" )
	language.Add( "tool.tnt_tus.reload_use", "Turn On/Off all the turrets" )

end

function TOOL:LeftClick( trace )

	if !trace.Entity:IsValid() or !trace.Entity.Base then return false end

	if ( CLIENT ) then return true end

	if trace.Entity.Base == "tnt_base_deployable" or trace.Entity.Base == "tnt_base_controlable" or trace.Entity.Base == "tnt_base_attachable" then

		local ds = self:GetClientNumber( "scale" )
		local s = self:GetClientNumber( "spread" )
		local r = self:GetClientNumber( "range" )
		local cd = self:GetClientNumber( "cooldown" )
		local br = self:GetClientNumber( "br" )
		local taps = self:GetClientNumber( "taps" )

		trace.Entity:SetDamageScale( ds )
		trace.Entity:SetSpread( s )
		trace.Entity:SetTurretRange( r )
		trace.Entity:SetCooldown( cd )
		trace.Entity:SetBlastRadius( br )
		trace.Entity:SetTakeAmmoPerShoot( taps )

		return true

	end

end

function TOOL:RightClick( trace )

	if !trace.Entity:IsValid() or !trace.Entity.Base then return false end

	if ( CLIENT ) then return true end

	if trace.Entity.Base == "tnt_base_deployable" or trace.Entity.Base == "tnt_base_controlable" or trace.Entity.Base == "tnt_base_attachable" then

		local ds  = trace.Entity.DamageScale
		local s  = trace.Entity.Spread * 10
		local r  = trace.Entity.TurretRange
		local cd  = trace.Entity.Cooldown
		local br  = trace.Entity.BlastRadius
		local taps  = trace.Entity.TakeAmmoPerShoot
		local ready  = tostring(trace.Entity:GetReady())

		trace.Entity:GetTurretOwner():ChatPrint( "Turret Ready is "..ready.."" )
		trace.Entity:GetTurretOwner():ChatPrint( "Damage Scale: "..ds.."" )
		trace.Entity:GetTurretOwner():ChatPrint( "Spread(*10): "..s.."" )
		trace.Entity:GetTurretOwner():ChatPrint( "Range: "..r.."" )
		trace.Entity:GetTurretOwner():ChatPrint( "Cooldown: "..cd.."" )
		trace.Entity:GetTurretOwner():ChatPrint( "Blast Radius: "..br.."" )
		trace.Entity:GetTurretOwner():ChatPrint( "Take Ammo Per Shoot: "..taps.."" )
		trace.Entity:GetTurretOwner():ConCommand( "tnt_tus_scale "..ds )
		trace.Entity:GetTurretOwner():ConCommand( "tnt_tus_spread "..s )
		trace.Entity:GetTurretOwner():ConCommand( "tnt_tus_range "..r )
		trace.Entity:GetTurretOwner():ConCommand( "tnt_tus_cooldown "..cd )
		trace.Entity:GetTurretOwner():ConCommand( "tnt_tus_br "..br )
		trace.Entity:GetTurretOwner():ConCommand( "tnt_tu_taps "..taps )

		return true

	end

end

TOOL.TracerEntity = {}
local stat = false
function TOOL:Reload( trace )

	if ( SERVER ) then

		if trace.Entity:GetTurretOwner():KeyDown(IN_USE) then

			for k,v in pairs(ents.GetAll()) do
				if v.Base == "tnt_base_deployable" or v.Base == "tnt_base_controlable" or v.Base == "tnt_base_attachable" then
					v:SetReady(stat)
				end
			end
			stat = !stat

		else

			if !trace.Entity:IsValid() then return false end

			if trace.Entity:IsNPC() then
				self.TracerEntity[1] = trace.Entity
			elseif self.TracerEntity[1] != nil then
				if trace.Entity.Base == "tnt_base_deployable" or trace.Entity.Base == "tnt_base_attachable" then
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

	CPanel:AddControl( "Slider", { Label = "DamageScale", Command = "tnt_tus_scale", Type = "Float", Min = 0, Max = 10 } )
	CPanel:AddControl( "Slider", { Label = "Spread(*10)", Command = "tnt_tus_spread", Type = "Float", Min = 0, Max = 1 } )
	CPanel:AddControl( "Slider", { Label = "Range", Command = "tnt_tus_range", Type = "Int", Min = 0, Max = 15000 } )
	CPanel:AddControl( "Slider", { Label = "Cooldown", Command = "tnt_tus_cooldown", Type = "Float", Min = 0.1, Max = 5 } )
	CPanel:AddControl( "Slider", { Label = "BlastRadius", Command = "tnt_tus_br", Type = "Int", Min = 0, Max = 256 } )
	CPanel:AddControl( "Slider", { Label = "TakeAmmoPerShoot", Command = "tnt_tus_taps", Type = "Float", Min = 0.1, Max = 1 } )

end