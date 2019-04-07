--[[------------------------------------------------------------------
  PRESETS
  User generated configuration snapshots
]]--------------------------------------------------------------------

if CLIENT then

  -- Namespace
  HOLOHUD.CONFIG.PRESETS = {};

  -- Parameters
  local PRESET_DIR = HOLOHUD.CONFIG.DataDir .. "/presets";
  local DATA_EXTENSION = ".dat";
  local DATA_DIR = "DATA";
  local INVALID_CHARACTERS = {"\"", ":"};

  -- Loaded presets
  local presets = {};

  --[[
    Returns the list of loaded presets
    @return {table} presets
  ]]
  function HOLOHUD.CONFIG.PRESETS:GetPresets()
    return presets;
  end

  --[[
    Adds a preset to memory and saves it on the disk
    @param {string} id
    @param {table} config
    @void
  ]]
  function HOLOHUD.CONFIG.PRESETS:AddPreset(id, config)
    if (not file.Exists(PRESET_DIR, DATA_DIR)) then file.CreateDir(PRESET_DIR); end
    file.Write(PRESET_DIR .. "/" .. id .. DATA_EXTENSION, util.TableToJSON(config));
    presets[id] = true;
    print(HOLOHUD.CONFIG.Signature .. " Preset '" .. id .. "' saved successfully.");
  end

  --[[
    Returns whether a preset exists
    @param {string} id
    @return {boolean} true if exists, false otherwise
  ]]
  function HOLOHUD.CONFIG.PRESETS:PresetExists(id)
    return file.Exists(PRESET_DIR .. "/" .. id .. DATA_EXTENSION, DATA_DIR);
  end

  --[[
    Changes the current user generated configuration to the preset
    @param {string} id
    @void
  ]]
  function HOLOHUD.CONFIG.PRESETS:SelectPreset(id)
    if (HOLOHUD.CONFIG.PRESETS:PresetExists(id)) then
      HOLOHUD.ELEMENTS.ElementData = util.JSONToTable(file.Read(PRESET_DIR .. "/" .. id .. DATA_EXTENSION, DATA_DIR));

      -- Persist preset configuration
      for id, _ in pairs(HOLOHUD.ELEMENTS.ElementData) do
        HOLOHUD.ELEMENTS:SaveUserConfiguration(id);
      end

      print(HOLOHUD.CONFIG.Signature .. " Preset loaded successfully.");
    else
      print(HOLOHUD.CONFIG.Signature .. " The given preset does not exist.");
    end
  end

  --[[
    Returns whether are there any available presets on the disk
    @return {boolean} true if any are available, false otherwise
  ]]
  function HOLOHUD.CONFIG.PRESETS:HasPresets()
    return table.Count(file.Find(PRESET_DIR .. "/*" .. DATA_EXTENSION, DATA_DIR)) > 0;
  end

  --[[
    Lists all presets from the disk, loading them into memory
    @void
  ]]
  function HOLOHUD.CONFIG.PRESETS:LoadPresets()
    local files, directories = file.Find(PRESET_DIR .. "/*" .. DATA_EXTENSION, DATA_DIR);
    for _, filename in pairs(files) do
      local name = string.StripExtension(filename);
      presets[name] = true;
      print("   + " .. name .. " found.");
    end
  end

  --[[
    Saves the current element data into a preset
    @param {string} name
    @void
  ]]
  function HOLOHUD.CONFIG.PRESETS:CreateSnapshot(name)
    -- Check if string is empty
    if (string.len(name) <= 0) then print(HOLOHUD.CONFIG.Signature .. " Couldn't save preset: No name supplied."); return; end

    -- Check if an invalid character is found
    for _, char in pairs(INVALID_CHARACTERS) do
      if (string.find(name, char) ~= nil) then
        print(HOLOHUD.CONFIG.Signature .. " Couldn't save preset: Invalid character '" .. char .. "' detected."); return;
      end
    end

    -- Otherwise, save the preset
    HOLOHUD.CONFIG.PRESETS:AddPreset(name, HOLOHUD.ELEMENTS:GetElementsData());
  end

  --[[
    Removes a preset
    @param {string} name
    @void
  ]]
  function HOLOHUD.CONFIG.PRESETS:DeletePreset(name)
    if (presets[name] == nil) then print(HOLOHUD.CONFIG.Signature .. " Couldn't delete preset: It does not exist."); return; end
    file.Delete(PRESET_DIR .. "/" .. name .. DATA_EXTENSION);
    presets[name] = nil;
    print(HOLOHUD.CONFIG.Signature .. " Preset '" .. name .. "' deleted successfully.");
  end

end
