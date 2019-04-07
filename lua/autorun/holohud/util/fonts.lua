--[[------------------------------------------------------------------
  FONTS
  Create consistent fonts for the different HUD elements
]]--------------------------------------------------------------------

if CLIENT then

  -- Parameters
  local DEFAULT_FONT = "Roboto Light";
  local WEIGHT = 500;
  local BRIGHT, ACTIVE = "_bright", "_active";

  -- Variables
  HOLOHUD.Fonts = {};
  local order = {};

  --[[
    Creates a set of fonts to be used
    @param {string} name
    @param {number} size
    @param {string|nil} font
    @param {number|nil} weight
    @param {number|nil} opaque
    @void
  ]]
  function HOLOHUD:CreateFont(name, size, font, weight, opaque)
    font = font or DEFAULT_FONT;
    weight = weight or WEIGHT;
    opaque = opaque or false;
    -- Normal variant
    surface.CreateFont( name, {
      font = font,
      size = size,
      weight = weight,
      blursize = 0,
      scanlines = 0,
      antialias = true,
      additive = (not opaque)
    });

    -- Idle bright variant
    surface.CreateFont( name..BRIGHT, {
      font = font,
      size = size,
      weight = weight,
      blursize = 4,
      scanlines = 2,
      antialias = true,
      additive = true
    });

    -- Active element variant
    surface.CreateFont( name..ACTIVE, {
      font = font,
      size = size,
      weight = weight,
      blursize = 6,
      scanlines = 2,
      antialias = true,
      additive = true
    });
  end

  --[[
    Returns the names of the set of fonts
    @param {string} name
    @return {string} fontName
    @return {string} fontNameBright
    @return {string} fontNameActive
  ]]
  function HOLOHUD:GetFonts(name)
    return name, name..BRIGHT, name..ACTIVE;
  end

  --[[
    Adds a usable font configuration
    @param {string} name
    @param {string} title
    @param {string} default
    @param {number} size
    @param {number|nil} weight
    @param {boolean|nil} opaque
  ]]
  function HOLOHUD:AddFont(name, title, default, size, weight, opaque)
    HOLOHUD.Fonts[name] = {title = title, default = default, size = size, weight = weight, opaque = opaque};
    table.insert(order, name);
  end

  --[[
    Returns a font based on their numerical order of insertion
    @param {number} i
    @return {string} font name
  ]]
  function HOLOHUD:GetFontByPosition(i)
    return order[i];
  end

end
