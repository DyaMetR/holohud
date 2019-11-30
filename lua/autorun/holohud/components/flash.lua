--[[
  FLASH PANEL
  Flashing panel component to welcome an idle element
]]

if CLIENT then

  -- Parameters
  local BACKGROUND_DIST = 1.1;
  local ANIM_ON_SPEED = 0.13;
  local ANIM_OFF_SPEED = 0.076;
  local ANIM_FLASH_SPEED = 0.05;

  -- Textures
  local center = surface.GetTextureID("gui/center_gradient");

  -- Variables
  local tick = 0;
  local hadSuit = true;

  -- Edit mode (display all panels)
  HOLOHUD.EditMode = false;

  -- Flash panel table
  HOLOHUD.FlashPanels = {};

  --[[
    Draws a white rect that'll serve for when an element is loading
    @param {number} x
    @param {number} y
    @param {number} w
    @param {number} h
    @param {number} amount
  ]]
  function HOLOHUD:DrawFlashRect(x, y, w, h, amount)
    local u, v = self:GetSway();
    local x, y = x + u * BACKGROUND_DIST, y + v * BACKGROUND_DIST;
    local b = HOLOHUD:GetFlashBrightness();
    draw.RoundedBox(0, x, y, w, h, Color(255 * b, 255 * b, 255 * b, 255 * amount * HOLOHUD:GetFlashOpacity()));
    surface.SetDrawColor(Color(0, 0, 0, 43 * amount * HOLOHUD:GetFlashOpacity()));
    surface.SetTexture(center);
    surface.DrawTexturedRect(x, y - 1, w, h + 2);
  end

  --[[
    Adds a panel to the display list
    @param {string} panel
    @param {number} w
    @param {number} h
    @param {string} element
    @void
  ]]
  function HOLOHUD:AddFlashPanel(panel)
    HOLOHUD.FlashPanels[panel] = {active = false, anim = 0, flash = 0, force = false};
  end

  --[[
    Returns the data from a panel
    @param {string} panel
    @return {table} panelData
  ]]
  function HOLOHUD:GetFlashPanel(panel)
    return HOLOHUD.FlashPanels[panel];
  end

  --[[
    Returns whether a panel exists
    @param {string} panel
    @return {boolean} exists
  ]]
  function HOLOHUD:HasFlashPanel(panel)
    return HOLOHUD.FlashPanels[panel] ~= nil;
  end

  --[[
    Returns whether a panel is active
    @param {string} panel
    @return {boolean} true if active, false otherwise
  ]]
  function HOLOHUD:IsPanelActive(panel)
    return HOLOHUD.FlashPanels[panel].active or not HOLOHUD.FlashPanels[panel].active and HOLOHUD.FlashPanels[panel].anim > 0;
  end

  --[[
    Sets if a panel is active and should hide
    @param {string} panel
    @param {boolean} active
    @param {boolean|nil} is forced
    @void
  ]]
  function HOLOHUD:SetPanelActive(panel, active, force)
    if (self.FlashPanels[panel] == nil) then return end;
    if ((HOLOHUD.DEATH:ShouldHUDHide() or (not hadSuit and not HOLOHUD:ShouldHUDDrawWithoutSuit())) and not force) then active = false; end
    force = force or false;
    self.FlashPanels[panel].active = active;
    self.FlashPanels[panel].force = force;
  end

  --[[
    Resets a panel's animation
    @param {string} panel
    @void
  ]]
  function HOLOHUD:ResetPanel(panel, anim, flash)
    if (HOLOHUD.FlashPanels[panel] == nil) then return end;
    anim = anim or 0;
    flash = flash or 0;
    HOLOHUD.FlashPanels[panel].flash = flash;
    HOLOHUD.FlashPanels[panel].anim = anim;
  end

  --[[
    Removes a panel
    @param {string} panel
    @void
  ]]
  function HOLOHUD:RemovePanel(panel)
    HOLOHUD.FlashPanels[panel] = nil;
  end

  --[[
    Renames a panel
    @param {string} panel
    @param {string} new name
    @void
  ]]
  function HOLOHUD:RenamePanel(panel, name)
    HOLOHUD.FlashPanels[name] = table.Copy(HOLOHUD.FlashPanels[panel]);
    HOLOHUD.FlashPanels[panel] = nil;
  end

  --[[
    Returns whether a panel behind a flash panel can be displayed
    @param {string} panel
    @return {boolean} can display contents
  ]]
  function HOLOHUD:CanDisplayPanel(panel)
    local data = HOLOHUD.FlashPanels[panel];
    if (data == nil) then return false; end
    return data.flash < 1 and data.anim >= 1;
  end

  --[[
    Draws the given flash panel
    @param {string} panel
    @param {number} x
    @param {number} y
    @param {number} w
    @param {number} h
    @param {number|nil} align
    @param {number|nil} minimum panel height
  ]]
  function HOLOHUD:DrawFlashPanel(panel, x, y, w, h, align, minHeight)
    if (HOLOHUD.FlashPanels[panel] == nil) then return end;
    minHeight = minHeight or 0;
    align = align or TEXT_ALIGN_BOTTOM;
    local data = self.FlashPanels[panel];
    local anim = data.anim; -- Flash animation amount

    local xOffset, xScale, yOffset, yScale = 0, 1, 1, anim;
    if (align == TEXT_ALIGN_TOP) then
      yOffset = 0;
    elseif (align == TEXT_ALIGN_LEFT) then
      yScale = 1;
      xScale = anim;
    elseif (align == TEXT_ALIGN_RIGHT) then
      yScale = 1;
      xScale = anim;
      xOffset = 1;
    end

    local height = minHeight + (h - minHeight);
    if (data.flash > 0 and data.anim > 0) then
      HOLOHUD:DrawFlashRect(x + w * (1 - xScale) * xOffset, y + height * (1 - yScale) * yOffset, w * xScale, height * yScale, data.flash);
    end
  end

  --[[
    Animates the panels
    @void
  ]]
  local function Animate()
    local anim_on, anim_off = HOLOHUD:GetFlashDeploySpeed(), HOLOHUD:GetFlashRetractSpeed();

    -- Had suit?
    if (LocalPlayer():Health() > 0) then
      hadSuit = LocalPlayer():IsSuitEquipped();
    end

    -- Animate
    if (tick < CurTime()) then
      for k, panel in pairs(HOLOHUD.FlashPanels) do
        if (panel.active or HOLOHUD.EditMode and not panel.force) then
          if (panel.anim < 1) then
            panel.flash = 1;
            HOLOHUD.FlashPanels[k].anim = math.Clamp(panel.anim + anim_on, 0, 1);
          else
            if (panel.flash > 0) then
              HOLOHUD.FlashPanels[k].flash = math.Clamp(panel.flash - ANIM_FLASH_SPEED, 0, 1);
            end
          end
        else
          if (panel.anim > 0) then
            if (panel.flash < 1) then
              HOLOHUD.FlashPanels[k].flash = math.Clamp(panel.flash + anim_off, 0, 1);
            else
              HOLOHUD.FlashPanels[k].anim = math.Clamp(panel.anim - ANIM_FLASH_SPEED, 0, 1);
            end
          end
        end
      end
      tick = CurTime() + 0.01;
    end
  end

  -- Animate and enable edit mode
  local hasPressed = false;
  hook.Add("Think", "holohud_panel_animation", function()
    Animate();
    local pressed = input.IsKeyDown(HOLOHUD:GetContextMenuKey()) and HOLOHUD:IsContextMenuEnabled();
    if (pressed ~= hasPressed) then
      HOLOHUD.EditMode = pressed;
      hasPressed = pressed;
    end
  end);

end
