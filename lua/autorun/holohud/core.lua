--[[------------------------------------------------------------------
  CORE
  The core file of the HUD, where the other files are included and the
  default HUD is hid
]]--------------------------------------------------------------------

-- Inner systems
HOLOHUD:IncludeFile("core/gamemode.lua");
HOLOHUD:IncludeFile("core/config.lua");

-- Util
HOLOHUD:IncludeFile("util/death.lua");
HOLOHUD:IncludeFile("util/sway.lua");
HOLOHUD:IncludeFile("util/fonts.lua");
HOLOHUD:IncludeFile("util/highlight.lua");
HOLOHUD:IncludeFile("util/intersect.lua");
HOLOHUD:IncludeFile("util/icons.lua");
HOLOHUD:IncludeFile("util/hazards.lua");
HOLOHUD:IncludeFile("util/texture.lua");
HOLOHUD:IncludeFile("util/bind_press.lua");

-- Default data
HOLOHUD:IncludeFile("data/fonts.lua");
HOLOHUD:IncludeFile("data/weapons.lua");
HOLOHUD:IncludeFile("data/ammo.lua");
HOLOHUD:IncludeFile("data/hazards.lua");
HOLOHUD:IncludeFile("data/items.lua");
HOLOHUD:IncludeFile("data/killicons.lua");

-- Components
HOLOHUD:IncludeFile("components/numbers.lua");
HOLOHUD:IncludeFile("components/flash.lua");
HOLOHUD:IncludeFile("components/panel.lua");
HOLOHUD:IncludeFile("components/fragment_panel.lua");
HOLOHUD:IncludeFile("components/bar.lua");
HOLOHUD:IncludeFile("components/heartrate.lua");
HOLOHUD:IncludeFile("components/progress_icons.lua");

-- Weapon selector (requires the HUD element to exist)
HOLOHUD:IncludeFile("elements/default/weapon_selector.lua");
HOLOHUD:IncludeFile("util/weapon_switcher.lua");

-- Default HUD elements
HOLOHUD:IncludeFile("elements/default/damage.lua");
HOLOHUD:IncludeFile("elements/default/health.lua");
HOLOHUD:IncludeFile("elements/default/ammunition.lua");
HOLOHUD:IncludeFile("elements/default/hazards.lua");
HOLOHUD:IncludeFile("elements/default/compass.lua");
HOLOHUD:IncludeFile("elements/default/pickup.lua");
HOLOHUD:IncludeFile("elements/default/ping.lua");
HOLOHUD:IncludeFile("elements/default/target_health.lua");
HOLOHUD:IncludeFile("elements/default/killfeed.lua");
HOLOHUD:IncludeFile("elements/default/clock.lua");
HOLOHUD:IncludeFile("elements/default/player_count.lua");
HOLOHUD:IncludeFile("elements/default/prop_count.lua");
HOLOHUD:IncludeFile("elements/default/speedometer.lua");
HOLOHUD:IncludeFile("elements/default/entity_info.lua");
HOLOHUD:IncludeFile("elements/default/auxpower.lua");
HOLOHUD:IncludeFile("elements/default/welcome.lua");


-- Load add-ons
local files, directories = file.Find("autorun/holohud/add-ons/*.lua", "LUA");
for _, file in pairs(files) do
  HOLOHUD:IncludeFile("add-ons/"..file);
end

if CLIENT then

	--[[
	  Loads the configuration.
	  @void
	]]--
	local function initialize()
		-- header and version
		print(" --------- H0L-D4 --------- \n  Version " .. HOLOHUD.Version.Major .. "." .. HOLOHUD.Version.Minor);
		if HOLOHUD.Version.Patch > 0 then print("  " .. HOLOHUD.Version.Patch .. " patches were issued for this version."); end

		-- elements
		if not table.IsEmpty(HOLOHUD.ELEMENTS.Elements) then
			print("\n  > " .. table.Count(HOLOHUD.ELEMENTS.Elements) .. " HUD elements found. Loading user configuration...");
			HOLOHUD.ELEMENTS:LoadUserConfiguration();
			HOLOHUD.ELEMENTS:GenerateDefaultHUDHideList();
		else
			print("\n  > No HUD elements found. What did you do this time?");
		end

		-- load font configuration
		HOLOHUD.CONFIG.FONTS:LoadCurrentFont()

		-- presets
		if HOLOHUD.CONFIG.PRESETS:HasPresets() then
			print("\n  > Scanning configuration presets...");
			HOLOHUD.CONFIG.PRESETS:LoadPresets();
		else
			print("\n  > No user generated presets available.")
		end

		-- fonts
		if HOLOHUD.CONFIG.FONTS:HasFontPresets() then
			print("\n  > Scanning font configuration presets...");
			HOLOHUD.CONFIG.FONTS:LoadFontPresets();
		else
			print("\n  > No font presets available.");
		end

		-- footer
		print("\n  > All set. Have fun!\n -------------------------- ");
	end

	-- initialize configuration
	initialize();

	-- print welcome message
	hook.Add("Initialize", "holohud_welcome", function() HOLOHUD:ResetWelcomeAnimation(); end);

  -- Draw HUD ConVar
  local cl_drawhud = GetConVar("cl_drawhud");

  -- Draw HUD
  hook.Add("HUDPaint", "holohud_draw", function()
    if (HOLOHUD:IsHUDEnabled() and cl_drawhud:GetBool()) then HOLOHUD.ELEMENTS:DrawElements(); end
  end);

  -- Hide default HUD
  hook.Add( "HUDShouldDraw", "holohud_hide_default_hud", function( name )
    if ( HOLOHUD:IsHUDEnabled() and HOLOHUD.ELEMENTS.DefaultHUDHideElements[ name ] and cl_drawhud:GetBool() ) then return false end;
  end );

end
