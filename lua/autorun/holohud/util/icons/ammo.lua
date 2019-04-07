--[[------------------------------------------------------------------
  AMMUNITION ICONS
  Icons for the ammunition indicator and ammunition pickups
]]--------------------------------------------------------------------

if CLIENT then

  -- Parameters
  local DEFAULT_AMMO = 1;
  local MIN_BRIGHT = 0.44;
  local ACTIVE_BRIGHT = 0.66;
  local DEFAULT_W, DEFAULT_H = 32, 32;

  --[[
    Registers an ammo type for the current ammo indicator
    @param {string} ammunition type
    @param {string} foreground texture
    @param {string} bright texture
    @param {number|nil} texture width
    @param {number|nil} texture height
    @param {number|nil} actual width (horizontal margin)
    @void
  ]]
  function HOLOHUD.ICONS:AddBulletImage(ammoType, texture, textureBright, w, h, margin)
    HOLOHUD.ICONS.Ammo.Indicator[ammoType] = {texture = surface.GetTextureID(texture), textureBright = surface.GetTextureID(textureBright), w = w, h = h, margin = margin};
  end

  --[[
    Adds an image as an ammo type icon for the weapon switcher
    @param {string} ammunition type
    @param {Texture} texture
    @param {number|nil} texture width
    @param {number|nil} texture height
    @void
  ]]
  function HOLOHUD.ICONS:AddAmmoImage(ammoType, texture, w, h)
    HOLOHUD.ICONS:AddImageIcon(HOLOHUD.ICONS.Ammo.Switcher, ammoType, texture, w, h);
  end

  --[[
    Adds a character as an ammo type icon for the weapon switcher
    @param {string} ammunition type
    @param {string} font
    @param {string} char
    @param {number|nil} x
    @param {number|nil} y
    @void
  ]]
  function HOLOHUD.ICONS:AddAmmoIcon(ammoType, font, char, x, y)
    HOLOHUD.ICONS:AddFontIcon(HOLOHUD.ICONS.Ammo.Switcher, ammoType, font, char, x, y);
  end

  --[[
    Draws an ammo pickup icon
    @param {number} x
    @param {number} y
    @param {string} ammo type
    @param {number|nil} horizontal alignment
    @param {number|nil} vertical alignment
    @return {number} width
    @return {number} height
  ]]
  function HOLOHUD.ICONS:DrawAmmoIcon(x, y, ammoType, align, verticalAlign, bright, colour, draw_ac)
    if (HOLOHUD.ICONS:GetIcon(HOLOHUD.ICONS.Ammo.Switcher, ammoType) == nil) then return; end

    -- Draw it
    HOLOHUD.ICONS:DrawIcon(HOLOHUD.ICONS.Ammo.Switcher, x, y, ammoType, align, verticalAlign, bright, colour, draw_ac);

    -- Get its size and return it
    local icon = HOLOHUD.ICONS:GetIcon(HOLOHUD.ICONS.Ammo.Switcher, ammoType);
    surface.SetFont(icon.font);
    return icon.x or 0, icon.y or 0, surface.GetTextSize(icon.char);
  end

  --[[
    Returns a bullet icon's data
    @param {string} ammo type
    @void
  ]]
  function HOLOHUD.ICONS:GetBulletIcon(ammoType)
    return HOLOHUD.ICONS.Ammo.Indicator[ammoType] or HOLOHUD.ICONS.Ammo.Indicator[DEFAULT_AMMO];
  end

  --[[
    Draws a bullet icon
    @param {number} x
    @param {number} y
    @param {string} ammunition type
    @param {Color|nil} colour
    @param {number|nil} bright
    @return {number} width
    @return {number} height
  ]]
  function HOLOHUD.ICONS:DrawBulletIcon(x, y, ammoType, colour, bright, off)
    colour = colour or Color(255, 255, 255, 200);
    bright = bright or 0;
    if (off == nil) then off = false; end

    local data = HOLOHUD.ICONS:GetBulletIcon(ammoType);

    --[[if (not off) then
      -- Bright
      surface.SetTexture(data.textureBright);
      surface.SetDrawColor(Color(colour.r, colour.g, colour.b, colour.a * MIN_BRIGHT));
      surface.DrawTexturedRect(x, y, data.w or DEFAULT_W, data.h or DEFAULT_H);
    end]]

    -- Foreground
    --[[surface.SetTexture(data.texture);
    surface.SetDrawColor(Color(colour.r, colour.g, colour.b, colour.a));
    surface.DrawTexturedRect(x, y, data.w or DEFAULT_W, data.h or DEFAULT_H);]]
    --[[HOLOHUD:DrawTexture(data.texture, x, y, data.w or DEFAULT_W, data.h or DEFAULT_H, colour, not off);

    if (not off) then
      -- Active
      surface.SetTexture(data.textureBright);
      surface.SetDrawColor(Color(colour.r, colour.g, colour.b, colour.a * ACTIVE_BRIGHT * bright));
      surface.DrawTexturedRect(x, y, data.w or DEFAULT_W, data.h or DEFAULT_H);
    end]]

    HOLOHUD:DrawBrightTexture(data.texture, data.textureBright, x, y, data.w or DEFAULT_W, data.h or DEFAULT_H, colour, bright, off, true);

    return data.w, data.h;
  end

end
