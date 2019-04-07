--[[------------------------------------------------------------------
  WEAPON ICONS
  Weapon icons for the weapon selector and pickups
]]--------------------------------------------------------------------

if CLIENT then

  -- Parameters
  local SWEP_DEFAULT = surface.GetTextureID("weapons/swep");

  --[[
    Adds an image as a weapon icon
    @param {string} weapon class
    @param {Texture} texture
    @param {number|nil} w
    @param {number|nil} h
    @void
  ]]
  function HOLOHUD.ICONS:AddWeaponImage(weaponClass, texture, w, h)
    HOLOHUD.ICONS:AddImageIcon(HOLOHUD.ICONS.Weapons, weaponClass, texture, w, h);
  end

  --[[
    Adds a character as a weapon icon
    @param {string} weapon class
    @param {string} font
    @param {string} char
    @param {number|nil} x
    @param {number|nil} y
    @void
  ]]
  function HOLOHUD.ICONS:AddWeaponIcon(weaponClass, font, char, x, y)
    HOLOHUD.ICONS:AddFontIcon(HOLOHUD.ICONS.Weapons, weaponClass, font, char, x, y);
  end

  --[[
    Draws a weapon icon
    @param {number} x
    @param {number} y
    @param {string} weapon class
    @param {number|nil} horizontal alignment
    @param {number|nil} vertical alignment
    @param {Color|nil} colour
    @param {number|nil} bright
    @void
  ]]
  function HOLOHUD.ICONS:DrawWeaponIcon(x, y, weaponClass, align, verticalAlign, colour, bright)
    HOLOHUD.ICONS:DrawIcon(HOLOHUD.ICONS.Weapons, x, y, weaponClass, align, verticalAlign, bright, colour, true);
  end

  --[[
    Returns whether a weapon has an icon
    @param {string} weaponClass
    @return {boolean} has icon
  ]]
  function HOLOHUD.ICONS:HasWeaponIcon(weaponClass)
    return HOLOHUD.ICONS:GetIcon(HOLOHUD.ICONS.Weapons, weaponClass) ~= nil;
  end


  --[[
    Draws a weapon icon
    @param {number} x
    @param {number} y
    @param {Weapon} weapon
    @void
  ]]
  function HOLOHUD.ICONS:DrawWeapon(x, y, weapon, w, h, colour, bright)
    colour = colour or Color(255, 255, 255, 200);
    if (HOLOHUD.ICONS:HasWeaponIcon(weapon:GetClass())) then
      HOLOHUD.ICONS:DrawWeaponIcon(x, y, weapon:GetClass(), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, colour, bright);
    else
      if (weapon.DrawWeaponSelection ~= nil) then
        -- Transform icons into plain ones
        local bounce, bubble = weapon.BounceWeaponIcon, weapon.DrawWeaponInfoBox;
        weapon.BounceWeaponIcon = false;
        weapon.DrawWeaponInfoBox = false;

        -- If icon is a png, give it the original size
        if (type(weapon.WepSelectIcon) ~= "number") then
          w = weapon.WepSelectIcon:GetInt("$realwidth");
          h = weapon.WepSelectIcon:GetInt("$realheight");
        end

        surface.SetDrawColor(colour);
        weapon:DrawWeaponSelection(x - (w * 0.5), y - (h * 0.5) - 4, w, h, 255);

        -- Return to default their properties
        weapon.BounceWeaponIcon = bounce;
        weapon.DrawWeaponInfoBox = bubble;
      end
    end
  end

end
