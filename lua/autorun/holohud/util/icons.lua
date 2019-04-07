--[[------------------------------------------------------------------
  ICONS
  Visual icons for ammunition types, weapon selection menu, and
  item pickups.
]]--------------------------------------------------------------------

if CLIENT then

  -- Namespace
  HOLOHUD.ICONS = {};

  -- Parameters
  local IMAGE_W, IMAGE_H = 128, 64;
  local IMAGE, FONT = 0, 1;
  local ICON_COLOUR = Color(255, 255, 255);

  -- Databases
  HOLOHUD.ICONS.Weapons = {};
  HOLOHUD.ICONS.Ammo = {Switcher = {}, Indicator = {}};
  HOLOHUD.ICONS.Items = {};
  HOLOHUD.ICONS.Hazards = {};
  HOLOHUD.ICONS.KillIcons = {};

  --[[
    Adds an image as an icon
    @param {table} table
    @param {string} item class
    @param {Texture} texture
    @param {number|nil} w
    @param {number|nil} h
    @param {Color|nil} colour
    @param {number|nil} real margin
    @param {number|nil} real vertical margin
    @void
  ]]
  function HOLOHUD.ICONS:AddImageIcon(table, itemClass, texture, w, h, colour, u, v)
    table[itemClass] = {type = IMAGE, texture = texture, w = w, h = h, colour = colour, u = u or w, v = v or h};
  end

  --[[
    Adds a character as an icon
    @param {table} table
    @param {string} item class
    @param {string} font
    @param {string} char
    @param {number|nil} x
    @param {number|nil} y
    @param {Color|nil} colour
    @void
  ]]
  function HOLOHUD.ICONS:AddFontIcon(table, itemClass, font, char, x, y, colour)
    table[itemClass] = {type = FONT, font = font, char = char, x = x, y = y, colour = colour};
  end

  --[[
    Returns an icon
    @param {string} item class
    @return {table} icon data
  ]]
  function HOLOHUD.ICONS:GetIcon(table, itemClass)
    return table[itemClass];
  end

  --[[
    Returns an icon's size
    @param {table} table
    @param {string} itemClass
    @return {number} w
    @return {number} h
  ]]
  function HOLOHUD.ICONS:GetIconSize(table, itemClass)
    local icon = HOLOHUD.ICONS:GetIcon(table, itemClass);
    if (icon == nil) then return 0, 0; end
    if (icon.type == FONT) then
      surface.SetFont(icon.font);
      return surface.GetTextSize(icon.char);
    else
      return icon.u, icon.v;
    end
  end

  --[[
    Draws an icon
    @param {table} table
    @param {number} x
    @param {number} y
    @param {string} item class
    @param {number|nil} horizontal alignment
    @param {number|nil} vertical alignment
    @param {boolean|nil} should bright display
    @param {boolean|nil} draw chromatic aberration
    @void
  ]]
  function HOLOHUD.ICONS:DrawIcon(table, x, y, itemClass, align, verticalAlign, bright, colour, draw_ac)
    colour = colour or ICON_COLOUR;
    align = align or TEXT_ALIGN_LEFT;
    verticalAlign = verticalAlign or TEXT_ALIGN_TOP;

    local icon = HOLOHUD.ICONS:GetIcon(table, itemClass);

    if (icon == nil) then return; end

    colour = icon.colour or colour;
    x = x + (icon.x or 0);
    y = y + (icon.y or 0);
    local w, h = icon.w, icon.h;

    -- Either an image or a text char
    if (icon.type <= IMAGE) then
      local u, v = 0, 0;
      -- Horizontal alignment
      if (align == TEXT_ALIGN_CENTER) then
        u = -w * 0.5;
      elseif (align == TEXT_ALIGN_RIGHT) then
        u = -w;
      end

      -- Vertical alignment
      if (verticalAlign == TEXT_ALIGN_CENTER) then
        v = -h * 0.5;
      elseif (verticalAlign == TEXT_ALIGN_BOTTOM) then
        v = -h;
      end

      -- Draw the icon
      --[[surface.SetTexture(icon.texture);
      surface.SetDrawColor(colour);
      surface.DrawTexturedRect(x + u, y + v, w, h);]]
      HOLOHUD:DrawTexture(icon.texture, x + u - math.ceil((icon.w - icon.u) * 0.5), y + v - math.ceil((icon.h - icon.v) * 0.5), w, h, colour, draw_ac);
    else
      if (draw.GetFontHeight(icon.font .. "_bright")) then
        HOLOHUD:DrawText(x, y, icon.char, icon.font, colour, bright, align, verticalAlign, not draw_ac);
      else
        if (draw_ac and HOLOHUD:IsChromaticAberrationEnabled()) then
          local sep = HOLOHUD:GetChromaticAberrationSeparation();
          draw.SimpleText(icon.char, icon.font, x + sep, y + sep,Color(colour.r, 0, 0, colour.a), align, verticalAlign);
          draw.SimpleText(icon.char, icon.font, x, y, Color(0, colour.g, 0, colour.a), align, verticalAlign);
          draw.SimpleText(icon.char, icon.font, x - sep, y - sep, Color(0, 0, colour.b, colour.a), align, verticalAlign);
        else
          draw.SimpleText(icon.char, icon.font, x, y, colour, align, verticalAlign);
        end
      end
    end
  end

  -- Include files
  --[[include("icons/ammo.lua");
  include("icons/items.lua");
  include("icons/weapons.lua");
  include("icons/hazards.lua");
  include("icons/killicons.lua");]]
end

HOLOHUD:IncludeFile("icons/ammo.lua");
HOLOHUD:IncludeFile("icons/items.lua");
HOLOHUD:IncludeFile("icons/weapons.lua");
HOLOHUD:IncludeFile("icons/hazards.lua");
HOLOHUD:IncludeFile("icons/killicons.lua");
