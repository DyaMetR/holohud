--[[------------------------------------------------------------------
  KILL ICONS
  Custom kill feed icons
]]--------------------------------------------------------------------

if CLIENT then

  --[[
    Adds an image as a kill icon
    @param {string} entity class
    @param {Texture} texture
    @param {number|nil} w
    @param {number|nil} h
    @void
  ]]
  function HOLOHUD.ICONS:AddKillIconImage(class, texture, w, h, u, v)
    HOLOHUD.ICONS:AddImageIcon(HOLOHUD.ICONS.KillIcons, class, texture, w, h, nil, u, v);
  end

  --[[
    Adds a character as a kill icon
    @param {string} entity class
    @param {string} font
    @param {string} char
    @param {number|nil} x
    @param {number|nil} y
    @void
  ]]
  function HOLOHUD.ICONS:AddKillIconChar(class, font, char, x, y)
    HOLOHUD.ICONS:AddFontIcon(HOLOHUD.ICONS.KillIcons, class, font, char, x, y);
  end

  --[[
    Draws an kill icon
    @param {number} x
    @param {number} y
    @param {string} entity class
    @param {number|nil} horizontal alignment
    @param {number|nil} vertical alignment
    @void
  ]]
  function HOLOHUD.ICONS:DrawKillIcon(x, y, class, align, verticalAlign, colour)
    HOLOHUD.ICONS:DrawIcon(HOLOHUD.ICONS.KillIcons, x, y, class, align, verticalAlign, 0, colour, true);
  end

  --[[
    Returns whether a kill icon exists
    @param {string} class
    @return {boolean} exists
  ]]
  function HOLOHUD.ICONS:HasKillIcon(class)
    return HOLOHUD.ICONS:GetIcon(HOLOHUD.ICONS.KillIcons, class) ~= nil;
  end

end
