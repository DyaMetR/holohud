--[[------------------------------------------------------------------
  ENVIRONMENTAL HAZARDS ICONS
  Icons for the damage types
]]--------------------------------------------------------------------

if CLIENT then

  --[[
    Adds an image as a hazard icon
    @param {string} hazard
    @param {Texture} texture
    @param {number|nil} w
    @param {number|nil} h
    @void
  ]]
  function HOLOHUD.ICONS:AddHazardImage(hazard, texture, w, h)
    HOLOHUD.ICONS:AddImageIcon(HOLOHUD.ICONS.Hazards, hazard, texture, w, h);
  end

  --[[
    Adds a character as a hazard icon
    @param {string} hazard
    @param {string} font
    @param {string} char
    @param {number|nil} x
    @param {number|nil} y
    @void
  ]]
  function HOLOHUD.ICONS:AddHazardIcon(hazard, font, char, x, y)
    HOLOHUD.ICONS:AddFontIcon(HOLOHUD.ICONS.Hazards, hazard, font, char, x, y);
  end

  --[[
    Draws a hazard icon
    @param {number} x
    @param {number} y
    @param {string} hazard
    @param {number|nil} horizontal alignment
    @param {number|nil} vertical alignment
    @void
  ]]
  function HOLOHUD.ICONS:DrawHazardIcon(x, y, hazard, align, verticalAlign, colour)
    HOLOHUD.ICONS:DrawIcon(HOLOHUD.ICONS.Hazards, x, y, hazard, align, verticalAlign, 0.46, colour, true);
  end

end
