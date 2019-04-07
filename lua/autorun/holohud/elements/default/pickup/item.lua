--[[------------------------------------------------------------------
  PICKUP HISTORY
  Item pickup
]]--------------------------------------------------------------------

-- Namespace
local PICKUP = HOLOHUD.ELEMENTS.PICKUP;

-- Parameters
local ITEM_WIDTH, ITEM_HEIGHT = 192, 20;
local PICKED_UP = "PICKED UP";

--[[
  Adds an item pickup to the history
  @param {string} item
  @void
]]
function PICKUP:AddItemPickup(item, displayTitle)
  local iconH = 0;

  -- Get icon size
  local icon = HOLOHUD.ICONS:GetIcon(HOLOHUD.ICONS.Items, item);
  if (icon ~= nil) then
    if (icon.type == 0) then
      iconH = icon.h;
    else
      surface.SetFont(icon.font);
      local w, h = surface.GetTextSize(icon.char);
      iconH = h;
    end
  end

  -- Display title
  local offset = 1;
  if (displayTitle) then
    offset = 0;
  end

  -- Get size
  surface.SetFont("holohud_weapon_name");
  local u, v = surface.GetTextSize(language.GetPhrase(item));
  local w, h = math.Clamp(u + 13, ITEM_WIDTH, ScrW()), ITEM_HEIGHT - (16 * offset) + iconH + v;

  PICKUP:AddPickup(PICKUP.PickupType.ITEM, {item = item, tick = 0, anim1 = 0, anim2 = 0, displayTitle = displayTitle}, w, h);
end

--[[
  Draws an item pickup
  @param {number} x
  @param {number} y
  @param {number} w
  @param {number} h
  @param {string} item class
  @param {number} title animation
  @param {number} text animation
  @param {boolean} should display title
  @param {Color} colour
  @void
]]
function PICKUP.ItemPickup(x, y, w, h, item, anim1, anim2, displayTitle, colour)
  -- Title
  if (displayTitle) then
    HOLOHUD:DrawText(x + 3, y, string.sub(PICKED_UP, 1, anim2), "holohud_pickup", Color(255, 255, 255, 30), nil, nil, nil, true);
  end

  -- Info
  HOLOHUD.ICONS:DrawItemIcon(x + (w * 0.5), y + (h * 0.5), item, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER);
  HOLOHUD:DrawText(x + 5, y + h - 4, string.sub(language.GetPhrase(item), 1, anim1), "holohud_weapon_name", colour, nil, nil, TEXT_ALIGN_BOTTOM);
end

--[[
  Plays the animation for an item pickup
  @param {number} i
  @param {boolean} should the animation play
  @void
]]
function PICKUP:PickupAnimation(i, animate)
  local pickup = PICKUP.pickups[i];

  if (animate) then
    -- Delay text animation
    if (HOLOHUD:GetFlashPanel(PICKUP.PANEL_SUBFIX .. i).flash > 0) then
      PICKUP.pickups[i].tick = CurTime() + 1;
    end

    -- Animate text
    if (pickup.data.tick < CurTime() and HOLOHUD:GetFlashPanel(PICKUP.PANEL_SUBFIX .. i).flash <= 0) then
      if (pickup.data.anim2 < string.len(PICKED_UP)) then
        PICKUP.pickups[i].data.anim2 = pickup.data.anim2 + 1;

        -- Delay
        if (math.abs(pickup.data.anim2 - string.len(PICKED_UP)) < 1) then
          PICKUP.pickups[i].data.tick = CurTime() + 0.16;
        else
          PICKUP.pickups[i].data.tick = CurTime() + 0.015;
        end
      else
        if (pickup.data.anim1 < string.len(language.GetPhrase(pickup.data.item))) then
          PICKUP.pickups[i].data.anim1 = pickup.data.anim1 + 1;
          PICKUP.pickups[i].data.tick = CurTime() + 0.02
        end
      end
    end
  else
    pickup.data.anim1 = string.len(language.GetPhrase(pickup.data.item));
    pickup.data.anim2 = string.len(PICKED_UP);
  end
end
