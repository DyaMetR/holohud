--[[------------------------------------------------------------------
  PICKUP HISTORY
  Ammunition pickup
]]--------------------------------------------------------------------

-- Namespace
local PICKUP = HOLOHUD.ELEMENTS.PICKUP;

-- Parameters
local AMMO_WIDTH, AMMO_HEIGHT = 111, 51; -- 150 ; 192, 44
local COLLECTED = "COLLECTED";

--[[
  Adds a weapon pickup to the history
  @param {string} ammunition type
  @param {number} amount
  @param {boolean} should display name by user configuration
  @void
]]
function PICKUP:AddAmmoPickup(ammoType, amount, displayTitle, configDisplayName)
  -- Name size
  local u, v = 0, 0;
  local n, m = HOLOHUD:GetNumberSize(4, "holohud_med_sm");

  -- If ammo type has no icon or user wants to show the ammo name, display it
  local displayName = HOLOHUD.ICONS:GetIcon(HOLOHUD.ICONS.Ammo.Indicator, game.GetAmmoID(ammoType)) == nil or configDisplayName;
  if (displayName) then
    surface.SetFont("holohud_weapon_name");
    u, v = surface.GetTextSize(language.GetPhrase(ammoType .. "_ammo"));
    v = v - 4;
  end

  -- Title offset
  local offset = 0;
  if (displayTitle) then
    offset = 13;
  end

  -- Final size
  local w, h = math.max(n + 28, u) + 10, v + m + offset;

  -- Add new pickup
  local pickup = PICKUP.ammoPickups[ammoType];
  if (pickup == nil || PICKUP.pickups[pickup] == nil) then
    PICKUP:AddPickup(PICKUP.PickupType.AMMO, {ammoType = ammoType, amount = amount, tick = 0, anim1 = 0, anim2 = 0, lerp = 0, displayAmmo = displayName, displayTitle = displayTitle}, w, h);
    PICKUP.ammoPickups[ammoType] = table.Count(PICKUP.pickups);
    HOLOHUD:AddHighlight(PICKUP.PANEL_SUBFIX .. ammoType);
  else
    PICKUP.pickups[pickup].time = CurTime() + PICKUP.TIME;
    PICKUP.pickups[pickup].data.amount = PICKUP.pickups[pickup].data.amount + amount;
    HOLOHUD:TriggerHighlight(PICKUP.PANEL_SUBFIX .. ammoType);
  end
end

--[[
  Draws an ammunition pickup
  @param {number} x
  @param {number} y
  @param {number} w
  @param {number} h
  @param {string} ammunition type
  @param {number} amount
  @param {number} title animation
  @param {number} ammunition type name animation
  @param {boolean} display ammunition type name
  @param {Color} colour
  @void
]]
function PICKUP.AmmoPickup(x, y, w, h, ammoType, amount, anim1, anim2, displayTitle, displayName, colour)
  local u = HOLOHUD:GetNumberSize(4, "holohud_med_sm");
  local i = HOLOHUD.ICONS:GetBulletIcon(ammoType);
  local bright = HOLOHUD:GetHighlight(PICKUP.PANEL_SUBFIX .. ammoType);
  local ammo = game.GetAmmoID(ammoType);

  -- Display name
  if (displayName) then
    HOLOHUD:DrawText(x + 3, y + h - 2, string.sub(language.GetPhrase(ammoType .. "_ammo"), 1, anim1), "holohud_weapon_name", colour, bright, nil, TEXT_ALIGN_BOTTOM);
  end

  -- Display title
  local offset = 0;
  if (displayTitle) then
    offset = 1;
    HOLOHUD:DrawText(x + 3, y, string.sub(COLLECTED, 1, anim2), "holohud_pickup", Color(255, 255, 255, 30), 0, nil, nil, true); -- Title
  end

  -- Display icon and amount
  HOLOHUD.ICONS:DrawBulletIcon(x + w - u - (i.w - (i.margin * 0.5)) - 8, y + (HOLOHUD.ICONS:GetBulletIcon(ammo).h * 0.5) - 13 + (13 * offset), ammo, HOLOHUD.ELEMENTS:ConfigValue("ammunition", "colour"), bright);
  HOLOHUD:DrawNumber(x + w - 7, y + (12 * offset), math.Round(amount), HOLOHUD.ELEMENTS:ConfigValue("ammunition", "colour"), "0000", bright, "holohud_med_sm", false, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP);
end


--[[
  Plays the animation for an ammunition pickup
  @param {number} i
  @param {boolean} should the animation play
  @void
]]
function PICKUP:AmmoAnimation(i, animate)
  local pickup = PICKUP.pickups[i];

  if (animate) then

    -- Delay text animation
    if (HOLOHUD:GetFlashPanel(PICKUP.PANEL_SUBFIX .. i).flash > 0) then
      HOLOHUD:TriggerHighlight(PICKUP.PANEL_SUBFIX .. pickup.data.ammoType);
      PICKUP.pickups[i].tick = CurTime() + 1;
    end

    -- Animate text
    if (pickup.data.tick < CurTime() and HOLOHUD:GetFlashPanel(PICKUP.PANEL_SUBFIX .. i).flash <= 0) then
      if (pickup.data.anim2 < string.len(COLLECTED)) then
        PICKUP.pickups[i].data.anim2 = pickup.data.anim2 + 1;

        -- Delay
        if (math.abs(pickup.data.anim2 - string.len(COLLECTED)) < 1) then
          PICKUP.pickups[i].data.tick = CurTime() + 0.1;
        else
          PICKUP.pickups[i].data.tick = CurTime() + 0.015;
        end
      else
        if (pickup.data.anim1 < string.len(language.GetPhrase(pickup.data.ammoType .. "_ammo"))) then
          PICKUP.pickups[i].data.anim1 = pickup.data.anim1 + 1;
          PICKUP.pickups[i].data.tick = CurTime() + 0.02
        end
      end
    end
  else
    PICKUP.pickups[i].data.anim1 = string.len(language.GetPhrase(pickup.data.ammoType .. "_ammo"));
    PICKUP.pickups[i].data.anim2 = string.len(COLLECTED);
  end

  -- Animate lerp
  PICKUP.pickups[i].data.lerp = Lerp(FrameTime() * 5, pickup.data.lerp, pickup.data.amount);
end
