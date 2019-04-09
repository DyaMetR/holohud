--[[------------------------------------------------------------------
  CONFIGURATION MANAGEMENTS
  Main file where the HUD's configuration is managed
]]--------------------------------------------------------------------

if CLIENT then

  -- Namespace
  HOLOHUD.CONFIG = {};

  HOLOHUD.CONFIG.DataDir = "holohud"; -- Main data folder
  HOLOHUD.CONFIG.Signature = "< H0L-D4 >"; -- Console log signature

  -- Default
  HOLOHUD.CONFIG.Default = {
    ["holohud_enabled"] = 1,
    ["holohud_sway"] = 1,
    ["holohud_blur"] = 1,
    ["holohud_background_opacity"] = 1,
    ["holohud_blur_quality"] = 1,
    ["holohud_ca_enabled"] = 0,
    ["holohud_ca_distance"] = 1,
    ["holohud_death"] = 1,
    ["holohud_background_r"] = 0,
    ["holohud_background_g"] = 0,
    ["holohud_background_b"] = 0,
    ["holohud_autosave_enabled"] = 1,
    ["holohud_contextmenu"] = KEY_C
  }

  -- ConVars
  local values = {};
  for name, value in pairs(HOLOHUD.CONFIG.Default) do
    values[name] = CreateClientConVar(name, value, true);
  end

  --[[
    Returns whether the HUD is enabled
    @return {boolean} is HUD enabled
  ]]
  function HOLOHUD:IsHUDEnabled()
    return values.holohud_enabled:GetInt() >= 1;
  end

  --[[
    Returns the swaying multiplier
    @return {number} sway
  ]]
  function HOLOHUD:GetSwayMul()
    return values.holohud_sway:GetFloat();
  end

  --[[
    Returns the amount of background blur
    @return {number} blur
  ]]
  function HOLOHUD:GetBackgroundBlur()
    return values.holohud_blur:GetFloat();
  end

  --[[
    Returns the amount of background opacity
    @return {number} opacity
  ]]
  function HOLOHUD:GetBackgroundOpacity()
    return values.holohud_background_opacity:GetFloat();
  end

  --[[
    Returns the quality of the blur panels
    @return {number} quality
  ]]
  function HOLOHUD:GetBlurQuality()
    return values.holohud_blur_quality:GetFloat();
  end

  --[[
    Returns whether the chromatic aberration effect is enabled
    @return {boolean} true if enabled, false otherwise
  ]]
  function HOLOHUD:IsChromaticAberrationEnabled()
    return values.holohud_ca_enabled:GetInt() > 0;
  end

  --[[
    Returns the separation between the chromatic aberration layers
    @return {number} separation
  ]]
  function HOLOHUD:GetChromaticAberrationSeparation()
    return values.holohud_ca_distance:GetFloat();
  end

  --[[
    Returns whether the death animation is enabled
    @return {boolean} is death animation enabled
  ]]
  function HOLOHUD:IsDeathAnimationEnabled()
    return values.holohud_death:GetInt() >= 1;
  end

  --[[
    Returns the background colour for the panels
    @return {Color} background colour
  ]]
  function HOLOHUD:GetBackgroundColour()
    return Color(values.holohud_background_r:GetInt(), values.holohud_background_g:GetInt(), values.holohud_background_b:GetInt());
  end

  --[[
    Returns whether the auto saving feature is enabled
    @return {boolean} auto save enabled
  ]]
  function HOLOHUD:IsAutoSaveEnabled()
    return values.holohud_autosave_enabled:GetInt() > 0;
  end

  --[[
    Returns the key used to display all elements
    @return {KEY_} key
  ]]
  function HOLOHUD:GetContextMenuKey()
    return values.holohud_contextmenu:GetInt();
  end

  --[[
    Reset configuration to default
  ]]
  concommand.Add("holohud_reset", function(player, command, arguments)
    for name, value in pairs(HOLOHUD.CONFIG.Default) do
      RunConsoleCommand(name, value);
    end
  end);

end

HOLOHUD:IncludeFile("config/elements.lua"); -- Elements configuration
HOLOHUD:IncludeFile("config/menu.lua"); -- Extended configuration menu
HOLOHUD:IncludeFile("config/presets.lua"); -- Configuration snapshots
HOLOHUD:IncludeFile("config/fonts.lua"); -- Font configuration
