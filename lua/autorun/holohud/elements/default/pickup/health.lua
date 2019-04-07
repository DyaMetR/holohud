--[[------------------------------------------------------------------
  HEALTH PICKUPS
  Health and armour related pickups
]]--------------------------------------------------------------------

if CLIENT then
  -- Namespace
  local PICKUP = HOLOHUD.ELEMENTS.PICKUP;

  -- Parameters
  local ICON_SIZE = 42;
  local MARGIN = 5; -- Icon margin
  local SCREEN_OFFSET = 20;
  local PANEL_SUBFIX = "pickup_health_";
  local COLOURS = {
    ["item_healthkit"] = HOLOHUD.ELEMENTS.HEALTH.GetHealthColour,
    ["item_healthvial"] = function()
                            local colour = HOLOHUD.ELEMENTS.HEALTH:GetHealthColour();
                            return Color(colour.r + 66, colour.g + 66, colour.b + 66, colour.a);
                          end,
    ["item_battery"] = HOLOHUD.ELEMENTS.HEALTH.GetArmourColour
  };
  local TIME = 4;

  -- Variables
  local pickups = {}; -- Item pickup tray

  --[[
    Returns whether an item is a health related item
    @param {string} item
    @return {boolean} is a health related item
  ]]
  function PICKUP:IsHealthItem(item)
    return COLOURS[item] ~= nil;
  end

  --[[
    Adds a health pickup to the tray
    @param {string} item
    @void
  ]]
  function PICKUP:AddHealthPickup(item)
    table.insert(pickups, {item = item, time = CurTime() + TIME});
    HOLOHUD:AddFlashPanel(PANEL_SUBFIX .. table.Count(pickups));
  end

  --[[
    Removes a pickup from the list
    @param {number} i
    @void
  ]]
  local function RemovePickup(pos)
    -- Remove the entry
    table.remove(pickups, pos);
    HOLOHUD:RemovePanel(PANEL_SUBFIX .. pos);

    if (table.Count(pickups) > 0) then
      -- Rename all active panels to fit the new order
      for i=pos + 1, table.Count(pickups) + 1 do
        HOLOHUD:RenamePanel(PANEL_SUBFIX .. i, PANEL_SUBFIX .. (i - 1));
      end
    end
  end

  --[[
    Draws a health pickup
    @param {string} item
    @void
  ]]
  local function DrawPickup(x, y, w, h, item)
    if (COLOURS[item] == nil) then return; end
    HOLOHUD.ICONS:DrawItemIcon(x + (w * 0.5), y + (h * 0.5), item, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, COLOURS[item](HOLOHUD.ELEMENTS.HEALTH));
  end

  --[[
    Draws the health pickup tray
    @void
  ]]
  function PICKUP:DrawHealthPickupTray(alpha)
    for i, pickup in pairs(pickups) do
      -- Animate and control flow
      HOLOHUD:SetPanelActive(PANEL_SUBFIX .. i, pickup.time > CurTime());
      if (not HOLOHUD:IsPanelActive(PANEL_SUBFIX .. i) and pickup.time < CurTime()) then
        RemovePickup(i);
      end

      -- Get offset and draw
      local pW, pH = 0, 0; -- Health panel size
      local hW, hH = 0, 0; -- Hazards panel size

      -- Get sizes if panels are active
      if (HOLOHUD:IsPanelActive("health") or HOLOHUD:IsPanelActive("armour")) then
        pW, pH = HOLOHUD.ELEMENTS:GetElementSize("health");
      end

      if (HOLOHUD:IsPanelActive("hazards")) then
        hW, hH = HOLOHUD.ELEMENTS:GetElementSize("hazards");
      end

      local offset = SCREEN_OFFSET + pH + hH + MARGIN;

      HOLOHUD:DrawFragmentAlign(20, ScrH() - offset - (ICON_SIZE + MARGIN) * i, ICON_SIZE, ICON_SIZE, DrawPickup, PANEL_SUBFIX .. i, TEXT_ALIGN_LEFT, nil, alpha, nil, pickup.item);
    end
  end
end
