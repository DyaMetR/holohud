
if CLIENT then

  -- Namespace
  HOLOHUD.CONFIG.FONTS = {};

  -- Parameters
  local PRESET_DIR = HOLOHUD.CONFIG.DataDir .. "/fonts/presets";
  local CUR_CONFIG_DIR = HOLOHUD.CONFIG.DataDir .. "/fonts/";
  local DATA_EXTENSION = ".dat";
  local CUR_CONFIG_FILE = CUR_CONFIG_DIR .. "current" .. DATA_EXTENSION;
  local DATA_DIR = "DATA";
  local INVALID_CHARACTERS = {"\"", ":"};
  local TIMER, AUTO_SAVE_TIME = "holohud_font_save_time", 1;

  -- Presets list
  local presets = {};

  -- Currently selected fonts (in order to build presets)
  local selectedFonts = {};

  --[[
    Refreshes a font with the given family
    @param {string} name
    @param {string} font
    @param {boolean|nil} should this set font as selected
    @param {number|nil} x
    @param {number|nil} y
    @void
  ]]
  function HOLOHUD.CONFIG.FONTS:SelectFontFamily(name, font, shouldSave, x, y)
    if (reset == nil) then reset = false; end
    if (HOLOHUD.Fonts[name] == nil) then return; end
    local data = HOLOHUD.Fonts[name];
    HOLOHUD:CreateFont(name, data.size, font, data.weight, data.opaque);
    if (shouldSave) then
      selectedFonts[name] = {font = font, x = x, y = y};
    end
  end

  --[[
    Resets the font configuration to default
    @void
  ]]
  function HOLOHUD.CONFIG.FONTS:ResetFontsToDefault()
    HOLOHUD.CONFIG.FONTS:SetDefaultFont();
    selectedFonts = {};
    file.Delete(CUR_CONFIG_FILE);
  end

  --[[
    Resets a single font to default
    @param {string} name
    @void
  ]]
  function HOLOHUD.CONFIG.FONTS:ResetFontToDefault(name)
    HOLOHUD.CONFIG.FONTS:SelectFontFamily(name, HOLOHUD.Fonts[name].default);
    selectedFonts[name] = nil;
    HOLOHUD.CONFIG.FONTS:SaveCurrentFontConfiguration();
  end

  --[[
    Loads the last used font configuration and loads it into memory
    @void
  ]]
  function HOLOHUD.CONFIG.FONTS:LoadCurrentFont()
    if (file.Exists(CUR_CONFIG_FILE, DATA_DIR)) then
      print("  > Loading last font configuration...");
      selectedFonts = util.JSONToTable(file.Read(CUR_CONFIG_FILE, DATA_DIR));

      -- Load up the fonts
      for name, font in pairs(selectedFonts) do
        if (HOLOHUD.Fonts[name] ~= nil) then
          local data = HOLOHUD.Fonts[name];
          HOLOHUD:CreateFont(name, data.size, font.font, data.weight, data.opaque);
        end
      end
      print("  > Done.");
    end
  end

  --[[
    Saves the current selected fonts into disk
    @void
  ]]
  function HOLOHUD.CONFIG.FONTS:SaveCurrentFontConfiguration()
    if (not file.Exists(CUR_CONFIG_DIR, DATA_DIR)) then file.CreateDir(CUR_CONFIG_DIR); end
    file.Write(CUR_CONFIG_FILE, util.TableToJSON(selectedFonts));
  end

  --[[
    Saves and applies a new font configuration
    @param {string} name
    @param {string} font
    @param {number|nil} x
    @param {number|nil} y
    @void
  ]]
  function HOLOHUD.CONFIG.FONTS:ApplyFontConfiguration(name, font, x, y)
    HOLOHUD.CONFIG.FONTS:SelectFontFamily(name, font, true, x, y);
    HOLOHUD.CONFIG.FONTS:SaveCurrentFontConfiguration();
    print(HOLOHUD.CONFIG.Signature .. " New font applied.");
  end

  --[[
    Returns a font family's offsets
    @param {string} font
    @return {number} x
    @return {number} y
  ]]
  function HOLOHUD.CONFIG.FONTS:GetFontOffset(font)
    if (selectedFonts[font] == nil) then return 0, 0; end
    return selectedFonts[font].x or 0, selectedFonts[font].y or 0;
  end

  --[[
    Changes a font's offset and ticks the timer to automatically save changes
    @param {}
  ]]
  function HOLOHUD.CONFIG.FONTS:ApplyNewFontOffset(font, x, y)
    if (selectedFonts[font] == nil) then selectedFonts[font] = {font = nil, x = x, y = y}; return; end

    -- Apply new offsets
    selectedFonts[font].x = x; selectedFonts[font].y = y;

    -- Make sure the user has stopped changing values before saving
    if (timer.Exists(TIMER)) then
      timer.Stop(TIMER); timer.Start(TIMER); -- Reset timer
    else
      timer.Create(TIMER, AUTO_SAVE_TIME, 1, function() -- Create it
        HOLOHUD.CONFIG.FONTS:SaveCurrentFontConfiguration();
        print(HOLOHUD.CONFIG.Signature .. " New position saved.");
      end);
    end
  end

  --[[
    Returns all currently listed font presets
    @return {table} presets
  ]]
  function HOLOHUD.CONFIG.FONTS:GetFontPresets()
    return presets;
  end

  --[[
    Returns whether are there any available presets on the disk
    @return {boolean} true if any are available, false otherwise
  ]]
  function HOLOHUD.CONFIG.FONTS:HasFontPresets()
    return table.Count(file.Find(PRESET_DIR .. "/*" .. DATA_EXTENSION, DATA_DIR)) > 0;
  end

  --[[
    Loads and lists all of the font presets in the disk
    @void
  ]]
  function HOLOHUD.CONFIG.FONTS:LoadFontPresets()
    local files, directories = file.Find(PRESET_DIR .. "/*" .. DATA_EXTENSION, DATA_DIR);
    for _, filename in pairs(files) do
      local name = string.StripExtension(filename);
      presets[name] = true;
      print("   + " .. name .. " found.");
    end
  end

  --[[
    Loads a font preset from the disk
    @param {sring} name
    @void
  ]]
  function HOLOHUD.CONFIG.FONTS:LoadFontPreset(name)
    if (presets[name] == nil) then print(HOLOHUD.CONFIG.Signature .. " Font preset not found."); return; end
    selectedFonts = util.JSONToTable(file.Read(PRESET_DIR.. "/" .. name .. DATA_EXTENSION, DATA_DIR));
    for name, font in pairs(selectedFonts) do
      local data = HOLOHUD.Fonts[name];
      HOLOHUD:CreateFont(name, data.size, font.font, data.weight, data.opaque);
    end
    HOLOHUD.CONFIG.FONTS:SaveCurrentFontConfiguration();
    print(HOLOHUD.CONFIG.Signature .. " Font preset '" .. name .. "' loaded successfully.");
  end

  --[[
    Saves the current configuration as a preset
    @param {string} name
    @void
  ]]
  function HOLOHUD.CONFIG.FONTS:CreateFontSnapshot(name)
    -- Check if string is empty
    if (string.len(name) <= 0) then print(HOLOHUD.CONFIG.Signature .. " Couldn't save preset: No name supplied."); return; end

    -- Check if an invalid character is found
    for _, char in pairs(INVALID_CHARACTERS) do
      if (string.find(name, char) ~= nil) then
        print(HOLOHUD.CONFIG.Signature .. " Couldn't save preset: Invalid character '" .. char .. "' detected."); return;
      end
    end

    -- Otherwise, save the preset
    HOLOHUD.CONFIG.FONTS:AddFontPreset(name, selectedFonts);
  end

  --[[
    Adds a preset to memory and saves it on the disk
    @param {string} id
    @param {table} config
    @void
  ]]
  function HOLOHUD.CONFIG.FONTS:AddFontPreset(id, config)
    if (not file.Exists(PRESET_DIR, DATA_DIR)) then file.CreateDir(PRESET_DIR); end
    file.Write(PRESET_DIR .. "/" .. id .. DATA_EXTENSION, util.TableToJSON(config));
    presets[id] = true;
    print(HOLOHUD.CONFIG.Signature .. " Font preset '" .. id .. "' saved successfully.");
  end

  --[[
    Removes a preset
    @param {string} name
    @void
  ]]
  function HOLOHUD.CONFIG.FONTS:DeleteFontPreset(name)
    if (presets[name] == nil) then print(HOLOHUD.CONFIG.Signature .. " Couldn't delete font preset: It does not exist."); return; end
    file.Delete(PRESET_DIR .. "/" .. name .. DATA_EXTENSION);
    presets[name] = nil;
    print(HOLOHUD.CONFIG.Signature .. " Font preset '" .. name .. "' deleted successfully.");
  end

  --[[
    Returns the current font family of a system font
    @param {string} name
    @return {string} font
  ]]
  function HOLOHUD.CONFIG.FONTS:GetFontFamily(name)
    if (selectedFonts[name] == nil or selectedFonts[name].font == nil) then return HOLOHUD.Fonts[name].default; end
    return selectedFonts[name].font;
  end

  --[[
    Sets a font family for everything
    @param {string} font
    @void
  ]]
  function HOLOHUD.CONFIG.FONTS:SetUniqueFont(font)
    for name, _ in pairs(HOLOHUD.Fonts) do
      HOLOHUD.CONFIG.FONTS:SelectFontFamily(name, font, true);
    end
    HOLOHUD.CONFIG.FONTS:SaveCurrentFontConfiguration();
  end

  --[[
    Prevently loads the system with the default fonts in case the user doesn't have any
    @void
  ]]
  function HOLOHUD.CONFIG.FONTS:SetDefaultFont()
    for name, font in pairs(HOLOHUD.Fonts) do
      HOLOHUD.CONFIG.FONTS:SelectFontFamily(name, font.default);
    end
  end

end
