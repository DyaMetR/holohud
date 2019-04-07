--[[------------------------------------------------------------------
  PICKUP HISTORY
  Weapon pickup
]]--------------------------------------------------------------------

if CLIENT then
  -- Namespace
  local PICKUP = HOLOHUD.ELEMENTS.PICKUP;

  -- Parameters
  local WEAPON_WIDTH, WEAPON_HEIGHT, WEAPON_HEIGHT_MARGIN = 192, 96;
  local ACQUIRED = "ACQUIRED";

  --[[
    Adds a weapon pickup to the history
    @param {Weapon} weapon
    @void
  ]]
  function PICKUP:AddWeaponPickup(weapon, displayWeapon, displayTitle)
    if (not IsValid(weapon)) then return; end

    surface.SetFont("holohud_weapon_name");
    local u, v = 0, 0;
    if (displayWeapon) then
      u, v = surface.GetTextSize(weapon:GetPrintName());
    end

    local w, h = math.Clamp(u + 13, WEAPON_WIDTH, ScrW()), WEAPON_HEIGHT + v;

    PICKUP:AddPickup(PICKUP.PickupType.WEAPON, {weapon = weapon, margin = v, tick = 0, anim1 = 0, anim2 = 0, displayWeapon = displayWeapon, displayTitle = displayTitle}, w, h);

    -- Emit the pickup sound
    LocalPlayer():EmitSound("physics/metal/weapon_impact_soft" .. math.random(1, 2) .. ".wav", 75, 100, nil, CHAN_ITEM);
  end

  --[[
    Draws a weapon pickup
    @param {number} x
    @param {number} y
    @param {number} w
    @param {number} h
    @param {Weapon} weapon
    @param {number} name margin
    @param {number} ACQUIRED text animation
    @param {number} weapon name text animation
    @param {boolean} display weapon name
    @param {boolean} display title
    @param {Color} colour
    @param {Color} crit colour
    @void
  ]]
  function PICKUP.WeaponPickup(x, y, w, h, weapon, nameMargin, anim1, anim2, displayTitle, displayWeapon, colour, critColour)
    colour = colour or Color(255, 255, 255);
    critColour = critColour or Color(255, 0, 0);
    if (not LocalPlayer():HasWeapon(weapon:GetClass())) then
      colour = Color(critColour.r + 100, critColour.r + 100, critColour.r + 100);
    end

    -- Title
    if (displayTitle) then
      HOLOHUD:DrawText(x + 3, y, string.sub(ACQUIRED, 1, anim2), "holohud_pickup", Color(255, 255, 255, 30), nil, nil, nil, true);
    end

    -- Icon
    HOLOHUD.ICONS:DrawWeapon(x + (w * 0.5), y + (WEAPON_HEIGHT * 0.5), weapon, WEAPON_WIDTH, WEAPON_HEIGHT, colour);

    -- Weapon name
    if (displayWeapon) then
      HOLOHUD:DrawText(x + 5, y + h - 4, string.sub(language.GetPhrase(weapon:GetPrintName()), 1, anim1), "holohud_weapon_name", colour, nil, nil, TEXT_ALIGN_BOTTOM);
    end
  end

  --[[
    Plays the animation for a weapon pickup
    @param {number} i
    @void
  ]]
  function PICKUP:WeaponAnimation(i, animate)
    local pickup = PICKUP.pickups[i];

    if (animate) then
      -- Delay text animation
      if (HOLOHUD:GetFlashPanel(PICKUP.PANEL_SUBFIX .. i).flash > 0) then
        PICKUP.pickups[i].tick = CurTime() + 1;
      end

      -- Animate text
      if (pickup.data.tick < CurTime() and HOLOHUD:GetFlashPanel(PICKUP.PANEL_SUBFIX .. i).flash <= 0) then
        if (pickup.data.anim2 < string.len(ACQUIRED)) then
          PICKUP.pickups[i].data.anim2 = pickup.data.anim2 + 1;

          -- Delay
          if (math.abs(pickup.data.anim2 - string.len(ACQUIRED)) < 1) then
            PICKUP.pickups[i].data.tick = CurTime() + 0.3;
          else
            PICKUP.pickups[i].data.tick = CurTime() + 0.015;
          end
        else
          if (pickup.data.anim1 < string.len(language.GetPhrase(pickup.data.weapon:GetPrintName()))) then
            PICKUP.pickups[i].data.anim1 = pickup.data.anim1 + 1;
            PICKUP.pickups[i].data.tick = CurTime() + 0.02
          end
        end
      end
    else
      pickup.data.anim1 = string.len(language.GetPhrase(pickup.data.weapon:GetPrintName()));
      pickup.data.anim2 = string.len(ACQUIRED);
    end
  end
end
