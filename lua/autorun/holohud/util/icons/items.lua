--[[------------------------------------------------------------------
  ITEM ICONS
  Item icons for pickups
]]--------------------------------------------------------------------

if CLIENT then

  --[[
    Adds an image as an item icon
    @param {string} item class
    @param {Texture} texture
    @param {number|nil} w
    @param {number|nil} h
    @param {Color|nil} colour
    @void
  ]]
  function HOLOHUD.ICONS:AddItemImage(itemClass, texture, w, h, colour)
    HOLOHUD.ICONS:AddImageIcon(HOLOHUD.ICONS.Items, itemClass, texture, w, h, colour);
  end

  --[[
    Adds a character as an item icon
    @param {string} item class
    @param {string} font
    @param {string} char
    @param {number|nil} x
    @param {number|nil} y
    @param {Color|nil} colour
    @void
  ]]
  function HOLOHUD.ICONS:AddItemIcon(itemClass, font, char, x, y, colour)
    HOLOHUD.ICONS:AddFontIcon(HOLOHUD.ICONS.Items, itemClass, font, char, x, y, colour);
  end

  --[[
    Draws an item icon
    @param {number} x
    @param {number} y
    @param {string} item class
    @param {number|nil} horizontal alignment
    @param {number|nil} vertical alignment
    @param {Color|nil} colour
    @void
  ]]
  function HOLOHUD.ICONS:DrawItemIcon(x, y, itemClass, align, verticalAlign, colour)
    HOLOHUD.ICONS:DrawIcon(HOLOHUD.ICONS.Items, x, y, itemClass, align, verticalAlign, nil, colour, true);
  end

end
