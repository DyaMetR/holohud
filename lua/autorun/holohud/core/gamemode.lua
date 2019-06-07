--[[------------------------------------------------------------------
  GAMEMODE OVERRIDE
  HUD configuration presets based on a certain gamemode

  It does not necessarily requires you to play something that's not
  sandbox in order to use this. In fact, you can just replace 'sandbox'
  so it applies everywhere else.

  This is to enable (and restrict) certain configurations or even HUD
  elements to certain gamemodes (like the DarkRP and TTT modules).
]]--------------------------------------------------------------------

if CLIENT then

  -- *** Add font override

  -- Namespace
  HOLOHUD.GAMEMODE = {};

  local DEFAULT_GAMEMODE = "sandbox";

  HOLOHUD.GAMEMODE.GamemodeElementOverride = {}; -- Determines which elements must be shown in which gamemode
  HOLOHUD.GAMEMODE.GamemodeConfigOverride = {}; -- Determines a forced configuration based on gamemode
  local elementsOverriden = {}; -- Cache to find overriden elements

  --[[
    Returns whether the current gamemode overrides an element
    @param {string} element
    @return {boolean} is overriden
  ]]
  function HOLOHUD.GAMEMODE:IsElementOverriden(element)
    local gamemode = GAMEMODE_NAME or DEFAULT_GAMEMODE;
    local override = HOLOHUD.GAMEMODE.GamemodeElementOverride[gamemode];
    return (elementsOverriden[element] and (override == nil or not override.elements[element]));
  end

  --[[
    Returns whether an element's configuration parameter is overriden
    @param {string} element
    @param {string} config
    @return {boolean} is overriden
  ]]
  function HOLOHUD.GAMEMODE:IsConfigOverriden(element, config)
    local gamemode = GAMEMODE_NAME or DEFAULT_GAMEMODE;
    local override = HOLOHUD.GAMEMODE.GamemodeConfigOverride[gamemode];
    return override ~= nil and override[element] and override[element].config[config] ~= nil;
  end

  --[[
    Returns whether an element has its default configuration forced
    @param {string} element
    @return {boolean} is forced
  ]]
  function HOLOHUD.GAMEMODE:IsDefaultForced(element)
    local gamemode = GAMEMODE_NAME or DEFAULT_GAMEMODE;
    local override = HOLOHUD.GAMEMODE.GamemodeConfigOverride[gamemode];
    return override ~= nil and override[element].forceDefault;
  end

  --[[
    Returns the value of an overriden configuration param
    @param {string} element
    @param {string} config
    @return {any} value
  ]]
  function HOLOHUD.GAMEMODE:GetElementOverridenConfig(element, config)
    local gamemode = GAMEMODE_NAME or DEFAULT_GAMEMODE;
    local override = HOLOHUD.GAMEMODE.GamemodeConfigOverride[gamemode];
    if (override == nil or override[element] == nil or override[element].config[config] == nil) then return nil; end
    return override[element].config[config];
  end

  --[[
    Ties an element or group of elements to a single gamemode
    @param {string} gamemode
    @param {string|table} element (or elements if table)
  ]]
  local function AddElementOverride(gamemode, element)
    if (HOLOHUD.GAMEMODE.GamemodeElementOverride[gamemode] == nil) then HOLOHUD.GAMEMODE:SetElementOverride(gamemode, {[element] = true}, false); end
    if (HOLOHUD.GAMEMODE.GamemodeElementOverride[gamemode].whitelist) then return; end
    if (type(element) == "string" ) then
      HOLOHUD.GAMEMODE.GamemodeElementOverride[gamemode].elements[element] = true;
      elementsOverriden[element] = true;
    elseif (type(element) == "table") then
      for _, name in pairs(elements) do
        HOLOHUD.GAMEMODE.GamemodeElementOverride[gamemode].elements[name] = true;
        elementsOverriden[element] = true;
      end
    end
  end

  --[[
    Ties an element or a group of elements to a gamemode or a set of gamemodes
    @param {string|table} gamemode (or gamemodes if table)
    @param {string|table} element (or elements if table)
    @void
  ]]
  function HOLOHUD.GAMEMODE:AddElementOverride(gamemode, elements)
    if (type(gamemode) == "table") then
      for _, name in pairs(gamemode) do
        AddElementOverride(name, elements);
      end
    elseif (type(gamemode) == "string") then
      AddElementOverride(gamemode, elements);
    end
  end

  --[[
    Adds an element restriction to a certain gamemode.
    You can either disable certain elements, or even provide a whitelist so
    only certain elements will work.
    @param {string} gamemode
    @param {table} element list
    @param {boolean} is an override whitelist
  ]]
  function HOLOHUD.GAMEMODE:SetElementOverride(gamemode, elements, whitelist)
    if (whitelist == nil) then whitelist = false; end
    if (whitelist or HOLOHUD.GAMEMODE.GamemodeElementOverride[gamemode] == nil) then HOLOHUD.GAMEMODE.GamemodeElementOverride[gamemode] = {elements = {}, whitelist = whitelist}; end
    for i, element in pairs(elements) do
      local key, value = element, whitelist;
      if (type(element) == "boolean") then key = i; value = element; end
      HOLOHUD.GAMEMODE.GamemodeElementOverride[gamemode].elements[key] = value;
      elementsOverriden[element] = true;
    end
  end

  --[[
    Adds a configuration override for an element
    @param {string} gamemode
    @param {string} element
    @param {table} configuration parameters
    @param {boolean} should force default configuration for non-mentioned parameters
    @void
  ]]
  function HOLOHUD.GAMEMODE:AddConfigOverride(gamemode, element, config, forceDefault)
    if (HOLOHUD.GAMEMODE.GamemodeConfigOverride[gamemode] == nil) then HOLOHUD.GAMEMODE.GamemodeConfigOverride[gamemode] = {}; end
    if (HOLOHUD.GAMEMODE.GamemodeConfigOverride[gamemode][element] ~= nil) then
      table.insert(HOLOHUD.GAMEMODE.GamemodeConfigOverride[gamemode][element].config, config);
      HOLOHUD.GAMEMODE.GamemodeConfigOverride[gamemode][element].forceDefault = forceDefault;
    else
      HOLOHUD.GAMEMODE.GamemodeConfigOverride[gamemode][element] = {config = config, forceDefault = forceDefault};
    end
  end

end
