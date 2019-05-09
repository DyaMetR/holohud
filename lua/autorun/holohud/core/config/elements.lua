--[[------------------------------------------------------------------
  ELEMENTS CONFIGURATION
  Add configuration parameters for drawable elements

  An element has a configuration table which will contain and determine both
  the structure of the different available paremeters and its default values.

  In order to build a configuration parameter you can either use:

    HOLOHUD.ELEMENTS:BuildConfigParam("Parameter full name", any_default_value, minimum_value (optional), maximum_value (optional))

  Or simply follow the parameter table structure:

    { name = "Parameter full name", value = any_default_value, maxValue = optional, minValue = optional }

]]--------------------------------------------------------------------

if CLIENT then

  -- Namespace
  HOLOHUD.ELEMENTS = {};

  -- Parameters
  local CONFIG_DIR = HOLOHUD.CONFIG.DataDir .. "/elements";
  local DATA_EXTENSION = ".dat";
  local DATA_DIR = "DATA";
  local AUTO_SAVE_TIME = 1;
  local TIMER_PREFIX = "holohud_autosave_element_";

  -- Data containers
  HOLOHUD.ELEMENTS.Elements = {}; -- Elements default configuration
  HOLOHUD.ELEMENTS.ElementData = {}; -- Elements user generated configuration (loaded from disk)
  local elementConfig = {}; -- Actual configuration taking in account overrides

  --[[
    Adds a HUD element with its default configuration
    @param {string} id
    @param {string} title
    @param {string} subtitle
    @param {table|nil} hide default elements
    @param {table} default configuration
    @param {function|nil} drawing function
    @param {boolean|nil} enabled by default
    @param {boolean|nil} should work on all gamemodes, if false a gamemode override must be added
    @void
  ]]
  function HOLOHUD.ELEMENTS:AddElement(id, title, subtitle, hideElements, defaultConfig, drawFunction, enabled)
    if (enabled == nil) then enabled = true; end
    HOLOHUD.ELEMENTS.Elements[id] = {
      title = title, subtitle = subtitle, hide = hideElements, enabled = enabled,
      config = defaultConfig, drawFunction = drawFunction,
      configProxy = function(param) return HOLOHUD.ELEMENTS:ConfigValue(id, param); end 
    };
  end

  --[[
    Returns whether an element exists
    @param {string} id
    @return {boolean} true if exists, false otherwise
  ]]
  function HOLOHUD.ELEMENTS:ElementExists(id)
    return HOLOHUD.ELEMENTS.Elements ~= nil;
  end

  --[[
    Returns whether an element has user data
    @param {string} id
    @return {boolean} true if has, false otherwise
  ]]
  function HOLOHUD.ELEMENTS:ElementHasUserData(id)
    return HOLOHUD.ELEMENTS.ElementData[id] ~= nil;
  end

  --[[
    Gets a HUD element's loaded data or default configuration
    @param {string} id
    @return {table} element data
  ]]
  function HOLOHUD.ELEMENTS:GetElement(id)
    return HOLOHUD.ELEMENTS.Elements[id];
  end

  --[[
    Returns all available HUD elements
    @return {table} elements
  ]]
  function HOLOHUD.ELEMENTS:GetElements()
    return HOLOHUD.ELEMENTS.Elements;
  end

  --[[
    Returns the user generated data for a HUD element
    @param {string} id
    @return {table} data
  ]]
  function HOLOHUD.ELEMENTS:GetElementData(id)
    return HOLOHUD.ELEMENTS.ElementData[id];
  end

  --[[
    Returns the whole table of element data
    @return {table} data
  ]]
  function HOLOHUD.ELEMENTS:GetElementsData()
    return HOLOHUD.ELEMENTS.ElementData;
  end

  --[[
    Returns a list of HUD elements to hide
    @return {table} hide
  ]]
  function HOLOHUD.ELEMENTS:DefaultHUDHideElements()
    local hide = {};
    for id, element in pairs(HOLOHUD.ELEMENTS:GetElements()) do
      if (HOLOHUD.ELEMENTS:IsElementEnabled(id)) then
        if (element.hide ~= nil) then
          if type(element.hide) == "string" then
            hide[element.hide] = true;
          elseif type(element.hide) == "table" then
            for _, subElement in pairs(element.hide) do
              hide[subElement] = true;
            end
          end
        end
      end
    end
    return hide;
  end

  --[[
    Returns the whole element's default configuration
    @param {string} id
    @return {table} default configuration
  ]]
  function HOLOHUD.ELEMENTS:GetElementDefaultConfig(id)
    if (not HOLOHUD.ELEMENTS:ElementExists(id)) then return nil; end
    return HOLOHUD.ELEMENTS:GetElement(id).config;
  end

  --[[
    Returns either default or user generated configuration of an element
    @param {string} id
    @return {table} config
  ]]
  function HOLOHUD.ELEMENTS:GetElementUserConfigParam(id, param)
    if (not HOLOHUD.ELEMENTS:ElementHasUserData(id) or HOLOHUD.ELEMENTS:GetElementData(id).config[param] == nil) then return HOLOHUD.ELEMENTS:GetElement(id).config[param].value; end
    return HOLOHUD.ELEMENTS:GetElementData(id).config[param].value;
  end

  --[[
    Returns an element's filtered configuration parameter value
    This takes in account configuration override
    @param {string} id
    @param {string} param
    @return {any} value
  ]]
  function HOLOHUD.ELEMENTS:ConfigValue(id, param)
    if (HOLOHUD.GAMEMODE:IsConfigOverriden(id, param)) then return HOLOHUD.GAMEMODE:GetElementOverridenConfig(id, param); end
    if (HOLOHUD.GAMEMODE:IsDefaultForced(id)) then return HOLOHUD.ELEMENTS:GetElementDefaultConfig(id)[param].value; end
    return HOLOHUD.ELEMENTS:GetElementUserConfigParam(id, param);
  end

  --[[
    Returns whether an element is enabled
    @param {string} id
    @return {boolean} true if enabled, false otherwise
  ]]
  function HOLOHUD.ELEMENTS:IsElementEnabled(id)
    if (not HOLOHUD.ELEMENTS:ElementHasUserData(id)) then return HOLOHUD.ELEMENTS:GetElement(id).enabled; end
    return not HOLOHUD.GAMEMODE:IsElementOverriden(id) and HOLOHUD.ELEMENTS:GetElementData(id).enabled;
  end

  --[[
    Returns an element's size if this was provided previously
    @param {string} element id
    @return {number} w
    @return {number} h
  ]]
  function HOLOHUD.ELEMENTS:GetElementSize(id)
    if (not HOLOHUD.ELEMENTS:ElementExists(id)) then return 0, 0; end
    return HOLOHUD.ELEMENTS:GetElement(id).w or 0, HOLOHUD.ELEMENTS:GetElement(id).h or 0;
  end

  --[[
    Gives a HUD element a draw function
    @param {string} id
    @param {function} func
    @void
  ]]
  function HOLOHUD.ELEMENTS:AddDrawElement(id, func)
    if (not HOLOHUD.ELEMENTS:ElementExists(id)) then return; end
    HOLOHUD.ELEMENTS.Elements[id].drawFunction = func;
  end

  --[[
    Returns whether a HUD element has a drawable component
    @param {string} id
    @return {boolean} true if has, false otherwise
  ]]
  function HOLOHUD.ELEMENTS:CanDrawElement(id)
    if (not HOLOHUD.ELEMENTS:ElementExists(id)) then return false; end
    return HOLOHUD.ELEMENTS:GetElement(id).drawFunction ~= nil;
  end

  --[[
    Draws all HUD elements
    @void
  ]]
  function HOLOHUD.ELEMENTS:DrawElements()
    for id, element in pairs(HOLOHUD.ELEMENTS.Elements) do
      if (HOLOHUD.ELEMENTS:IsElementEnabled(id) and HOLOHUD.ELEMENTS:CanDrawElement(id)) then
        local w, h = HOLOHUD.ELEMENTS:GetElement(id).drawFunction(element.configProxy);
        HOLOHUD.ELEMENTS:GetElement(id).w = w or 0;
        HOLOHUD.ELEMENTS:GetElement(id).h = h or 0;
      end
    end
  end

  --[[
    Builds a parameter for a HUD element's configuration table
    @param {string} name
    @param {any} value
    @param {any|nil} minValue
    @param {any|nil} maxValue
    @param {any|nil} options
    @return {table} parameter
  ]]
  function HOLOHUD.ELEMENTS:BuildConfigParam(name, value, minValue, maxValue, options)
    return {name = name, value = value, minValue = minValue, maxValue = maxValue, options = options};
  end

  --[[
    Looks into the configuration directory and loads up all the user data
    @void
  ]]
  function HOLOHUD.ELEMENTS:LoadUserConfiguration()
    local files, directories = file.Find(CONFIG_DIR .. "/*" .. DATA_EXTENSION, DATA_DIR);
    -- Load all files
    for _, filename in pairs(files) do
      local id = string.StripExtension(filename);
      HOLOHUD.ELEMENTS.ElementData[id] = util.JSONToTable(file.Read(CONFIG_DIR .. "/" .. filename, DATA_DIR));
      print("   + " .. id .. " loaded.");
    end

    -- No data is found
    if (table.IsEmpty(files)) then print("   + No user data found. Default parameters loaded."); end
  end

  --[[
    Resets an element's configuration back to default values
    @param {string} id
    @param {boolean|nil} should the messages not be shown
    @void
  ]]
  function HOLOHUD.ELEMENTS:DeleteElementUserData(id, suppress)
    if (not HOLOHUD.ELEMENTS:ElementExists(id) or not HOLOHUD.ELEMENTS:ElementHasUserData(id)) then
      if (not suppress) then
        print(HOLOHUD.CONFIG.Signature .. " Couldn't remove configuration for '" .. id .. "' since it does not exist.");
      end
    else
      HOLOHUD.ELEMENTS.ElementData[id] = nil;
      file.Delete(CONFIG_DIR .. "/" .. id .. DATA_EXTENSION);

      if (not suppress) then
        print(HOLOHUD.CONFIG.Signature .. " Configuration for '" .. id .. "' removed and set back to default.");
      end
    end
  end

  --[[
    Generates a blank user configuration for an element containing default values
    @param {string} id
    @void
  ]]
  function HOLOHUD.ELEMENTS:GenerateUserConfiguration(id)
    if (not HOLOHUD.ELEMENTS:ElementExists(id) or HOLOHUD.ELEMENTS.ElementData[id] ~= nil) then return; end

    -- Get only the values
    local data = {};
    if (HOLOHUD.ELEMENTS.Elements[id].config ~= nil) then
      for param, config in pairs(HOLOHUD.ELEMENTS.Elements[id].config) do
        data[param] = {value = config.value};
      end
    end

    -- Set them to the element data table
    HOLOHUD.ELEMENTS.ElementData[id] = {enabled = HOLOHUD.ELEMENTS.Elements[id].enabled, config = table.Copy(data)};
  end

  --[[
    Saves an element's user configuration
    @param {string} id
    @param {boolean|nil} should the messages not be shown
    @void
  ]]
  function HOLOHUD.ELEMENTS:SaveUserConfiguration(id, suppress)
    if (not file.Exists(CONFIG_DIR, DATA_DIR)) then file.CreateDir(CONFIG_DIR); end
    if (HOLOHUD.ELEMENTS:ElementExists(id)) then
      -- If this was called before changing data, generate the user data table
      if (not HOLOHUD.ELEMENTS:ElementHasUserData(id)) then
        HOLOHUD.ELEMENTS:GenerateUserConfiguration(id);
      end

      -- Write file
      file.Write(CONFIG_DIR .. "/" .. id .. DATA_EXTENSION, util.TableToJSON(HOLOHUD.ELEMENTS.ElementData[id]));

      if (not suppress) then
        print(HOLOHUD.CONFIG.Signature .. " Configuration for '" .. id .. "' saved successfully.");
      end
    else
      if (suppress) then
        print(HOLOHUD.CONFIG.Signature .. " Attempted to save configuration for '" .. id .. "' but the element does not exist.");
      end
    end
  end

  --[[
    Initiates the auto saving process for an element's configuration
    @param {string} id
    @void
  ]]
  local function AutoSaveConfig(id)
    -- Make sure the user has stopped changing values before saving
    local timerName = TIMER_PREFIX .. id;
    if (timer.Exists(timerName)) then
      timer.Stop(timerName); timer.Start(timerName); -- Reset timer
    else
      timer.Create(timerName, AUTO_SAVE_TIME, 1, function() -- Create it
        HOLOHUD.ELEMENTS:SaveUserConfiguration(id);
      end);
    end
  end

  --[[
    Changes and saves an element's configuration parameter
    @param {string} id
    @param {string} field
    @param {any} value
    @param {boolean|nil} save
    @void
  ]]
  function HOLOHUD.ELEMENTS:ChangeElementConfiguration(id, field, value, save)
    if (not HOLOHUD.ELEMENTS:ElementHasUserData(id)) then HOLOHUD.ELEMENTS:GenerateUserConfiguration(id); end
    if (save == nil) then save = false; end
    if (HOLOHUD.ELEMENTS.ElementData[id].config[field] == nil) then HOLOHUD.ELEMENTS.ElementData[id].config[field] = {value = value}; end
    HOLOHUD.ELEMENTS.ElementData[id].config[field].value = value;
    if (save) then
      HOLOHUD.ELEMENTS:SaveUserConfiguration(id);
    elseif (not save and HOLOHUD:IsAutoSaveEnabled()) then
      AutoSaveConfig(id);
    end
  end

  --[[
    Toggles a HUD element
    @param {string} id
    @param {boolean|nil} value
    @param {boolean|nil} save
    @void
  ]]
  function HOLOHUD.ELEMENTS:ToggleElement(id, value, save)
    if (not HOLOHUD.ELEMENTS:ElementHasUserData(id)) then HOLOHUD.ELEMENTS:GenerateUserConfiguration(id); end
    if (save == nil) then save = false; end
    if (value == nil) then value = not HOLOHUD.ELEMENTS.ElementData[id].enabled; end
    HOLOHUD.ELEMENTS.ElementData[id].enabled = value;
    if (save) then HOLOHUD.ELEMENTS:SaveUserConfiguration(id); end
  end

end
