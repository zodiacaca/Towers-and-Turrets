
--[[ local f_list = {}
local List

local function PopulateList()

	List:Clear()
	List:ClearSelection()
    for k, _ in pairs(f_list) do
        List:AddLine(_)
    end
PrintTable(f_list)
end

local function tnt_panel()

	f_list = tntfriends

	local Frame = vgui.Create( "DFrame" )
	Frame:SetTitle( "Manage List" )
	Frame:SetPos( 5, 5 )
	Frame:SetSize( 300, 500 )
	Frame:SetVisible( true )
	Frame:SetDraggable( true )
	Frame:ShowCloseButton( true )
	Frame:MakePopup()
	
	List = vgui.Create( "DListView", Frame )
	List:SetPos( 25, 50 )
	List:SetSize( 250, 300 )
	List:AddColumn( "Friendly List" )
	List:SetMultiSelect( false )
	for k, v in pairs( f_list ) do
		List:AddLine( v )
	end
	
	local Button = vgui.Create( "DButton", Frame )
	Button:SetText( "Refresh List" )
	Button:SetTextColor( Color( 0, 0, 0 ) )
	Button:SetPos( 100, 380 )
	Button:SetSize( 100, 30 )
	Button.DoClick = function()
		PopulateList()
	end

end
concommand.Add("tnt_manage_list", tnt_panel) ]]

local function TNT2Options(panel)

	panel:AddControl( "Label", { Text = "Fire Key:" } )
	local key = {
		[1] = {"LClick", IN_ATTACK},
		[2] = {"RClick", IN_ATTACK2},
		[3] = {"Jump", IN_JUMP},
		[4] = {"Reload", IN_RELOAD},
		[5] = {"Sprint", IN_SPEED},
		[6] = {"Zoom", IN_ZOOM}
		}
	local ComboBox = vgui.Create("DComboBox")
		ComboBox:SetValue("Fire Key")
	for k,v in ipairs(key) do
		ComboBox:AddChoice(v[1], v[2])
	end
	for k,v in pairs(key) do
		if (GetConVarNumber("tnt_turret_fire") == v[2]) then
			ComboBox:ChooseOption(v[1])
		end
	end
	ComboBox.OnSelect = function(panel, index, value, data)
		RunConsoleCommand("tnt_turret_fire", data)
	end
	panel:AddItem(ComboBox)
	
	panel:AddControl( "CheckBox", { Label = "Attack players ? (*)", Command = "tnt_attack_player" } )
	
	panel:AddControl( "CheckBox", { Label = "Attack the owner ? (*)", Command = "tnt_attack_owner" } )

end

function TNTAddOptions()
	spawnmenu.AddToolMenuOption("Utilities", "Towers N Turrets", "TNTOptions", "Settings", "", "", TNT2Options)
end
hook.Add("PopulateToolMenu", "TNTAddOptions", TNTAddOptions)