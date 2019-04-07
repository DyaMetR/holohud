if CLIENT then

  --[[
    ALSO, HAVE THE SLOT BEING TALLER WHEN THE PRINTNAME IS TALLER
  ]]

  -- Parameters
  local PANEL_NAME = "weapon_selected";
  local AMMO1, AMMO2, WEAPON = "weapon_switch_ammo", "weapon_switch_alt", "weapon_switch_icon";
  local ICON_WIDTH, ICON_HEIGHT = 192, 96;
  local SLOT_WIDTH, SLOT_HEIGHT = 225, 128;
  local SLOT_SIZE_RETRACTED, SLOT_MARGIN, SLOT_MARGIN_RETRACTED = 32, 4, 6;
  local TEXTURE, TEXTURE_BRIGHT = surface.GetTextureID("holohud/bar_horizontal"), surface.GetTextureID("holohud/bar_horizontalb");
  local AMMO_W, AMMO_H, AMMO_V = 64, 16, 49;
  local AMMO_COLOUR = Color(190, 255, 100, 200);
  local TEXT_SPEED = 0.017;
  local NAME_FONT = "holohud_weapon_name";

  HOLOHUD:AddFlashPanel(PANEL_NAME);
  HOLOHUD:AddHighlight(AMMO1);
  HOLOHUD:AddHighlight(AMMO2);
  HOLOHUD:AddHighlight(WEAPON);

  --[[
    Draws a weapon slot details foreground
    @param {number} x
    @param {number} y
    @param {number} width
    @param {boolean} is animated
    @param {string} header
    @param {Color} weapon colour
    @param {number} primary ammo type
    @param {number} secondary ammo type
    @param {number} ammo in clip
    @param {number} ammo in reserve
    @param {number} secondary ammo in reserve
    @param {number} maximum primary ammo
    @param {number} maximum secondary ammo
    @void
  ]]
  local name, tick, lerp, lerp2 = 0, 0, 0, 0;
  local function DrawWeaponPanel(x, y, w, h, width, animation, header, weapon, wepCol, ammoType, ammoType2, clip, reserve, alt, maxAmmo, maxAlt)
    local baseColour = HOLOHUD.ELEMENTS:ConfigValue("weapon_selector", "colour");

    -- Variables
    local printName = language.GetPhrase(weapon:GetPrintName());
    local ammoValue = reserve/maxAmmo;
    local ammoValue2 = alt/maxAlt;
    local displayText = printName;
    if (animation) then
      displayText = string.sub(printName, 1, name);
      ammoValue = lerp;
      ammoValue2 = lerp2;
    end

    -- Header
    draw.SimpleText(header, "holohud_small", x + 5, y, Color(baseColour.r, baseColour.g, baseColour.b, 88), nil, TEXT_ALIGN_TOP);

    -- Weapon name
    HOLOHUD:DrawText(x + 5, y + h - 5, displayText, NAME_FONT, baseColour, nil, nil, TEXT_ALIGN_BOTTOM);

    -- Weapon icon
    HOLOHUD.ICONS:DrawWeapon(x + (width * 0.5), y + (SLOT_HEIGHT * 0.5) - 4, weapon, ICON_WIDTH, ICON_HEIGHT, wepCol, HOLOHUD:GetHighlight(WEAPON));

    local offset = 0;

    -- Reserve ammunition
    if (ammoType >= 0) then
      HOLOHUD:DrawHorizontalBar(x + width - AMMO_V - 3, y + 2, AMMO_COLOUR, ammoValue, HOLOHUD:GetHighlight(AMMO1));
      HOLOHUD.ICONS:DrawAmmoIcon(x + width - 5, y + 1, ammoType, TEXT_ALIGN_RIGHT, nil, -1, Color(255, 255, 255, 24));
      offset = AMMO_V;
    end

    -- Secondary ammo
    if (ammoType2 >= 0) then
      HOLOHUD:DrawHorizontalBar(x + width - AMMO_V - 3 - offset, y + 2, AMMO_COLOUR, ammoValue2, HOLOHUD:GetHighlight(AMMO2));
      HOLOHUD.ICONS:DrawAmmoIcon(x + width - 5 - offset, y + 1, ammoType2, TEXT_ALIGN_RIGHT, nil, -1, Color(255, 255, 255, 24));
    end

    -- Animations
    if (animation) then
      if (tick < CurTime()) then

        -- Text
        if (name < string.len(printName)) then
          name = name + 1;
        end

        -- Primary ammo bar
        if (lerp ~= reserve / maxAmmo) then
          if (lerp < reserve / maxAmmo) then
            lerp = math.Clamp(lerp + 0.03, 0, reserve / maxAmmo);
          else
            lerp = math.Clamp(lerp - 0.03, reserve / maxAmmo, 1);
          end
          HOLOHUD:TriggerHighlight(AMMO1);
        end

        -- Secondary ammo bar
        if (lerp2 ~= alt / maxAlt) then
          if (lerp2 < alt / maxAlt) then
            lerp2 = math.Clamp(lerp2 + 0.03, 0, alt / maxAlt);
          else
            lerp2 = math.Clamp(lerp2 - 0.03, alt / maxAlt, 1);
          end
          HOLOHUD:TriggerHighlight(AMMO2);
        end
        tick = CurTime() + TEXT_SPEED;
      end
    end
  end

  --[[
    Draws a detailed weapon slot
    @param {number} x
    @param {number} y
    @param {Weapon} weapon
    @param {number} width
    @param {number} height
    @param {number|nil} header
    @param {number|nil} background alpha
    @param {boolean|nil} is animation enabled
    @param {Color|nil} foreground colour
    @param {Color|nil} out of ammo colour
    @void
  ]]
  local function DrawWeaponDetails(x, y, weapon, width, height, header, alpha, quality, animation, wepCol, critCol)
    width = width or SLOT_WIDTH;
    height = height or SLOT_HEIGHT;
    header = header or "";
    wepCol = wepCol or Color(255, 255, 255);
    critCol = critCol or Color(255, 0, 0);
    if (animation == nil) then animation = false; end

    -- Colours
    local colour = HOLOHUD:GetBackgroundColour();

    -- Weapon information
    local ammoType = weapon:GetPrimaryAmmoType();
    local ammoType2 = weapon:GetSecondaryAmmoType();
    local clip = weapon:Clip1();
    local reserve = LocalPlayer():GetAmmoCount(ammoType);
    local alt = LocalPlayer():GetAmmoCount(ammoType2);
    local maxAmmo = game.GetAmmoMax(ammoType);
    local maxAlt = game.GetAmmoMax(ammoType2);

    -- If the weapon has no ammo, paint it red
    if (ammoType >= 0 and reserve <= 0 and clip <= 0 and (ammoType2 < 0 or ammoType2 >= 0 and alt <= 0)) then
      colour = Color(critCol.r * 0.65, critCol.g * 0.65, critCol.b * 0.65);
      wepCol = Color(critCol.r + 100, critCol.g + 100, critCol.b + 100);
    end

    -- Draw the panel
    if (HOLOHUD:CanDisplayPanel(PANEL_NAME) or not animation) then
      HOLOHUD:DrawFragmentPanel(x, y, width, height, DrawWeaponPanel, colour, alpha, nil, width, animation, header, weapon, wepCol, ammoType, ammoType2, clip, reserve, alt, maxAmmo, maxAlt);
    else
      HOLOHUD:TriggerHighlight(WEAPON);
      name = 0;
      lerp = 0;
      lerp2 = 0;
      tick = CurTime() + 0.096;
    end

    -- If animation is enabled, draw the flash panel
    if (animation) then
      HOLOHUD:DrawFlashPanel(PANEL_NAME, x, y, width, height, nil, SLOT_SIZE_RETRACTED);
    end

  end

  --[[
    Draws a retracted slot panel's foreground
    @param {number} x
    @param {number} y
    @param {number} width
    @param {string} header
    @param {Weapon} weapon
    @param {boolean} onActiveSlot
  ]]
  local function DrawSlotPanel(x, y, w, h, header, weapon, onActiveSlot, colour, critCol)
    draw.SimpleText(header, "holohud_small", x + 5, y, Color(colour.r, colour.g, colour.b, 66), nil, TEXT_ALIGN_TOP);
    if (weapon ~= nil and onActiveSlot) then -- If not a slot header, show name
      HOLOHUD:DrawText(x + w * 0.5, y + h * 0.5, weapon:GetPrintName(), NAME_FONT, Color(colour.r * 0.82, colour.g * 0.82, colour.b * 0.82), nil, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER);
    end
  end

  --[[
    Draws a weapon slot that's not selected
    @param {number} x
    @param {number} y
    @param {boolean} has ammo
    @param {number|nil} background alpha
    @param {number|nil} blur quality
    @param {Color|nil} foreground colour
    @param {Color|nil} out of ammo colour
    @void
  ]]
  local function DrawRetractedSlot(x, y, weapon, width, height, onActiveSlot, header, alpha, quality, fgCol, critCol)
    header = header or "";
    fgCol = fgCol or Color(255, 255, 255);
    critCol = critCol or Color(255, 0, 0);
    width = width or SLOT_SIZE_RETRACTED;
    height = height or SLOT_SIZE_RETRACTED;
    local colour = HOLOHUD:GetBackgroundColour();

    -- Determine colour
    if (IsValid(weapon)) then
      local ammoType = weapon:GetPrimaryAmmoType();
      local ammoType2 = weapon:GetSecondaryAmmoType();
      local clip = weapon:Clip1();
      local reserve = LocalPlayer():GetAmmoCount(ammoType);
      local alt = LocalPlayer():GetAmmoCount(ammoType2);
      local maxAmmo = game.GetAmmoMax(ammoType);
      local maxAlt = game.GetAmmoMax(ammoType2);

      -- If the weapon has no ammo, paint it red
      if (ammoType >= 0 and reserve <= 0 and clip <= 0 and (ammoType2 < 0 or ammoType2 >= 0 and alt <= 0)) then
        colour = Color(critCol.r * 0.71, critCol.g * 0.71, critCol.b * 0.71);
      end
    end

    -- Stretch if the slot is active
    if (not onActiveSlot) then width = SLOT_SIZE_RETRACTED; end

    -- Draw slot
    HOLOHUD:DrawFragmentPanel(x, y, width, height, DrawSlotPanel, colour, alpha, quality, header, weapon, onActiveSlot, fgCol, critCol);
  end

  --[[
    Draws a weapon slot icon
    @param {number} x
    @param {number} y
    @param {boolean} active
    @param {number|nil} background alpha
    @param {number|nil} blur quality
    @param {boolean|nil} is animation enabled
    @param {Color|nil} colour
    @void
  ]]
  local function DrawWeaponSlot(x, y, weapon, width, height, isActive, onActiveSlot, header, alpha, quality, animation, colour, critColour)
    if (isActive) then
      DrawWeaponDetails(x, y, weapon, width, height, header, alpha, quality, animation, colour, critColour);
    else
      DrawRetractedSlot(x, y, weapon, width, height, onActiveSlot, header, alpha, 0, colour, critColour);
    end
  end

  --[[
    Draws the weapon selector
    @param {number} x
    @param {number} y
    @param {table} weapons
    @param {number} selected slot
    @param {number} selected position
    @param {table} slot length table
    @param {number} amount of weapons the player currently holds
    @param {table} config
    @void
  ]]
  local lSlot, lPos = 0, 0;
  function HOLOHUD:DrawWeaponSelector(x, y, weapons, iSlot, iPos, slotSize, config)

    -- Reset flash panel when changing weapons
    if (lSlot ~= iSlot or lPos ~= iPos) then
      HOLOHUD:ResetPanel("weapon_selected");
      lSlot = iSlot; lPos = iPos;
    end

    -- Draw the weapon indicator
    if (iSlot <= 0 and not HOLOHUD.EditMode) then return; end

    local alpha = config("alpha");
    local u = 0;

    -- When should the panel activate
    HOLOHUD:SetPanelActive(PANEL_NAME, iSlot > 0);

    -- Draw the selector
    for slot = 1, 6 do
      local onActiveSlot = iSlot == slot;
      local v = 0; -- Vertical displacement
      local width = SLOT_WIDTH;

      if (slotSize[slot] > 0) then
        -- Check greatest width of slot
        if (onActiveSlot) then
          for pos, weapon in pairs(weapons[slot]) do
            if (not IsValid(weapon)) then continue; end
            surface.SetFont(NAME_FONT);
            local textSize = surface.GetTextSize(weapon:GetPrintName()) + 12;
            if (textSize > width) then width = textSize; end
          end
        end

        -- Display weapon
        for pos, weapon in pairs(weapons[slot]) do
          local height = SLOT_HEIGHT;
          if (IsValid(weapon)) then
            local isActive = onActiveSlot and iPos == pos;

            -- Add header
            local header = nil;
            if (pos <= 1) then header = slot; end

            -- Get height in case of multiline weapon names
            if (isActive) then
              local firstLine = string.sub(weapon:GetPrintName(), 1, string.find(weapon:GetPrintName(), "\n"));
              if (HOLOHUD:GetTextSize(firstLine, NAME_FONT) > (SLOT_WIDTH - ICON_WIDTH) * 1.5) then
                local nW, nH = HOLOHUD:GetTextSize(weapon:GetPrintName(), NAME_FONT);
                local fontH = draw.GetFontHeight(NAME_FONT);
                if (nH > fontH) then height = (SLOT_HEIGHT - fontH) + nH; end
              end
            else
              local nW, nH = HOLOHUD:GetTextSize(weapon:GetPrintName(), NAME_FONT);
              height = math.max(nH + SLOT_MARGIN_RETRACTED, SLOT_SIZE_RETRACTED);
            end

            -- Draw weapon slot
            DrawWeaponSlot(x + u, y + v, weapon, width, height, isActive, onActiveSlot, header, alpha, quality, config("animation"), config("colour"), config("crit_colour"));
          end

          -- Set next weapon placement
          if (isActive) then
            if (height == nil) then height = SLOT_HEIGHT; end
            v = v + height + SLOT_MARGIN;
          else
            if (height == nil) then height = SLOT_SIZE_RETRACTED; end
            v = v + height + SLOT_MARGIN;
          end
        end
      else
        DrawRetractedSlot(x + u, y, nil, nil, nil, nil, nil, alpha, 0);
      end

      -- Set next slot placement
      if (onActiveSlot) then
        u = u + width + SLOT_MARGIN;
      else
        u = u + SLOT_SIZE_RETRACTED + SLOT_MARGIN;
      end
    end
  end

end
