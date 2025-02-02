--[[
	ddd
ddd
sssssssssssss	dd
--]]

CreateClientConVar( "csm_spawnalways", 0,  true, false )
CreateClientConVar( "csm_propradiosity", 4,  true, false )
CreateClientConVar( "csm_blobbyao", 0,  true, false )
CreateClientConVar( "csm_wakeprops", 1,  true, false )
CreateClientConVar(	"csm_spread", 0,  false, false)
CreateClientConVar(	"csm_spread_samples", 7,  true, false)
CreateClientConVar(	"csm_spread_radius", 0.5,  true, false)
CreateClientConVar(	"csm_spread_layers", 1,  true, false)
CreateClientConVar(	"csm_spread_layer_density", 0,  true, false)
CreateClientConVar(	"csm_localplayershadow", 0,  true, false)
CreateClientConVar(	"csm_localplayershadow_old", 0,  false, false)
CreateClientConVar(	"csm_further", 0,  true, false)
CreateClientConVar(	"csm_furthershadows", 1,  true, false)
CreateClientConVar(	"csm_sizescale", 1,  true, false)
CreateClientConVar(	"csm_perfmode", 0,  true, false)

local ConVarsDefault = {
	csm_spawnalways = "0",
	csm_propradiosity = "4",
	csm_blobbyao = "0",
	csm_wakeprops = "1",
	csm_spread = "0",
	csm_spread_samples = "7",
	csm_spread_radius = "0.5",
	csm_localplayershadow = "0",
	csm_further = "0",
	csm_furthershadows = "1",
	csm_sizescale = "1",
	csm_perfmode = "0",
}

hook.Add( "PopulateToolMenu", "CSMClient", function()
	spawnmenu.AddToolMenuOption( "Utilities", "User", "CSM_Client", "#CSM", "", "", function( panel )
		panel:ClearControls()
		panel:AddControl( "ComboBox", { MenuButton = 1, Folder = "presetCSM", Options = { [ "#preset.default" ] = ConVarsDefault }, CVars = table.GetKeys( ConVarsDefault ) } )

		panel:CheckBox( "CSM Enabled", "csm_enabled" )

		panel:CheckBox( "Performance mode.", "csm_perfmode")
		panel:ControlHelp( "Performance mode, when on CSM will only use 2 cascade rings, this will reduce perceived quality of nearby shadows." )

		panel:NumSlider( "Shadow Quality", "r_flashlightdepthres", 0, 8192 )
		panel:ControlHelp( "Shadow map resolution." )
		panel:NumSlider( "Shadow Filter", "r_projectedtexture_filter", 0, 10)
		panel:ControlHelp( "Default Source engine shadow filter, It's quite grainy, it's best you leave this at 0.10 unless you know what you're doing." )

		local combobox = panel:ComboBox( "Prop Radiosity", "csm_propradiosity" )
		combobox:AddChoice( "0: no radiosity", 0 )
		combobox:AddChoice( "1: radiosity with ambient cube (6 samples)", 1 )
		combobox:AddChoice( "2: radiosity with 162 samples", 2 )
		combobox:AddChoice( "3: 162 samples for static props, 6 samples for everything else (Garry's Mod Default)", 3 )
		combobox:AddChoice( "4: 162 samples for static props, leaf node for everything else (Real CSM Default)", 4 )
		panel:ControlHelp( "The radiosity for adding indirect lighting to the shading of props, this is what r_radiosity is set to when CSM is turned on." )
		panel:CheckBox( "Update and Wake Props", "csm_wakeprops" )
		panel:ControlHelp( "Wake up props after the radiosity setting changes.")

		panel:CheckBox( "Enable AO Like Blob Shadows", "csm_blobbyao" )
		panel:ControlHelp( "Enables blob shadows that are modified to look like AO." )



		panel:CheckBox( "Shadow Spread", "csm_spread" )
		panel:ControlHelp( "Simulates the penumbra of the sun, can also be used for multisampling on shadows." )
		panel:ControlHelp( "Notice: Enabling spread disables the near ring, shadows may look lower quality closer up." )
		panel:ControlHelp( "Notice: Spread is only on the second ring to avoid blowing up your computer." )
		panel:NumSlider( "Spread Radius", "csm_spread_radius", 0, 2)
		panel:ControlHelp( "Radius of the spread in degrees, real life value is 0.5, gm_construct uses an unrealistic value of 3, you should use 0.5." )

		panel:NumSlider( "Spread Samples", "csm_spread_samples", 2, 16, 0)
		panel:ControlHelp( "Alert! This doesn't work above 7 unless you launch gmod with extra shadow maps enabled!!!" )
		panel:ControlHelp( "Double Alert! Setting this too high may crash your game!" )

		panel:NumSlider( "Spread Circle Layers", "csm_spread_layers", 1, 5, 0)
		panel:ControlHelp( "Since circle packing in a circle is hard I settled on layers for circles to fill in the middle, 1 is softer but 2 is more accurate and might look harsher" )
		--panel:NumSlider( "Spread Circle Layer Density", "csm_spread_layer_density", 0, 1)
		--panel:ControlHelp( "How close each layer is, It's recommended to leave this at 0 but the option is here just in case" )

		panel:CheckBox( "Draw Firstperson Shadows (Experimental)", "csm_localplayershadow" )
		panel:ControlHelp( "See your own shadows in firstperson" )

		panel:NumSlider( "Size / Distance Scale", "csm_sizescale", 0, 5)
		panel:ControlHelp( "Cascade size multiplier to lower / raise view distance, this affects the perceived quality." )

		panel:CheckBox( "Enable further cascade for large maps", "csm_further")
		panel:ControlHelp( "Add a further cascade to increase shadow draw distance without sacrificing perceived quality" )
		panel:CheckBox( "Enable shadows on further cascade", "csm_furthershadows")
		panel:ControlHelp( "Enable shadows on the further cascade, ")


		-- Add stuff here
	end )
end )

if (CLIENT) then
	function firstTimeCheck()
		if !(file.Read( "csm.txt", "DATA" ) == "two" ) and (file.Read( "csm.txt", "DATA" ) != "one" ) then
		--if true then
			--if not game.SinglePlayer() then return end
			--Derma_Message( "Hello! Welcome to the CSM addon! You should raise r_flashlightdepthres else the shadows will be blocky! Make sure you've read the FAQ for troubleshooting.", "CSM Alert!", "OK!" )
			local Frame = vgui.Create( "DFrame" )
			Frame:SetSize( 310, 200 )

			RunConsoleCommand("r_flashlightdepthres", "512") -- set it to the lowest of the low to avoid crashes

			Frame:Center()
			Frame:SetTitle( "CSM First Time Load!" )
			Frame:SetVisible( true )
			Frame:SetDraggable( false )
			Frame:ShowCloseButton( true )
			Frame:MakePopup()
			local label1 = vgui.Create( "DLabel", Frame )
			label1:SetPos( 15, 40 )
			label1:SetSize(	300, 20)
			label1:SetText( "Thanks for using Real CSM" )
			local label2 = vgui.Create( "DLabel", Frame )
			label2:SetPos( 15, 55 )
			label2:SetSize(	300, 20)
			label2:SetText( "would you like Real CSM to spawn when you load the game?" )
			local label3 = vgui.Create( "DLabel", Frame )
			label3:SetPos( 15, 70 )
			label3:SetSize(	300, 20)
			label3:SetText( "Refer to the F.A.Q for troubleshooting and help!" )

			local DermaCheckbox2 = vgui.Create( "DCheckBoxLabel", Frame )
			DermaCheckbox2:SetText("Performance Mode")
			DermaCheckbox2:SetPos( 8, 100 )				-- Set the position
			DermaCheckbox2:SetSize( 300, 30 )			-- Set the size

			DermaCheckbox2:SetConVar( "csm_perfmode" )

			local DermaCheckbox = vgui.Create( "DCheckBoxLabel", Frame )
			DermaCheckbox:SetText("Spawn on load")
			DermaCheckbox:SetPos( 8, 120 )				-- Set the position
			DermaCheckbox:SetSize( 300, 30 )			-- Set the size

			DermaCheckbox:SetConVar( "csm_spawnalways" )	-- Changes the ConVar when you slide

			local Button = vgui.Create("DButton", Frame)
			Button:SetText( "Continue" )
			Button:SetPos( 120, 155 )
			Button.DoClick = function()
				file.Write( "csm.txt", "one" )
				if (GetConVar( "csm_spawnalways" ):GetInt() == 1) then
					RunConsoleCommand("gmod_admin_cleanup")
				end

				Frame:Close()
			end
		end
	end

	--hook.Add( "PlayerFullLoad", "firstieCheck", firstTimeCheck)
	hook.Add( "InitPostEntity", "Ready", firstTimeCheck)
	--net.Receive( "PlayerSpawnedFully", firstTimeCheck())
end