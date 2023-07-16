--[[------------------------------------------------------------------
  ENVIRONMENTAL HAZARDS WARNINGS
  Icons displaying what kind of damage is the player receiving
]]--------------------------------------------------------------------

local NET = "holohud_hazard";

-- Display icons
if CLIENT then

  -- Parameters
  local PANEL_MARGIN, HEALTH_MARGIN = 20, 5;
  local PANEL_NAME = "hazards";
  local PANEL_SUBFIX = "hazard_";
  local TIME = 7;
  local BLINK = 0.266;
  local WIDTH, HEIGHT = 42, 42; -- Icons minimum size
  local TRAY_MARGIN = 5;
  local BLINK_SPEED = 0.0189;

  -- Variables
  local hazards = {};
  local tick = 0;
  local purged = false; -- Have panels been purged
  local blink = 0; -- Icons blink
  local blinked = false; -- Whether icons have blinked

  -- Single tray panel
  HOLOHUD:AddFlashPanel(PANEL_NAME);

  --[[
    Purges all hazard panels
    @void
  ]]
  local function PurgePanels()
    if (purged) then return; end
    for name, panel in pairs(hazards) do
      HOLOHUD:RemovePanel(PANEL_SUBFIX..name);
    end
    purged = true;
  end

  --[[
    Draws a hazard icon
    @param {number} x
    @param {number} y
    @param {number} w
    @param {number} h
    @param {string} hazard
    @param {Color} colour
    @void
  ]]
  local function DrawIcon(x, y, w, h, hazard, colour)
    if (hazards[hazard] == nil) then return; end
    local icon = hazards[hazard];
    HOLOHUD.ICONS:DrawHazardIcon(x + (w * 0.5), y + (h * 0.5), hazard, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, Color(colour.r, colour.g * (1 - icon.blink), colour.b * (1 - icon.blink), 255 * (blink + icon.blink) * icon.fade));
  end

  --[[
    Animates the icons
    @param {boolean} is using single tray
    @void
  ]]
  local function Animate(singleTray)
    -- Check if an icon's time has run out
    for name, panel in pairs(hazards) do
      -- Icon animation
      if (panel.tick < CurTime()) then
        -- Damage fade out animation
        if (panel.blink > 0) then
          hazards[name].blink = math.Clamp(hazards[name].blink - 0.012, 0, 1);
        end

        -- Fade out if single tray
        if (singleTray and panel.time < CurTime()) then
          if (panel.fade > 0) then
            hazards[name].fade = math.Clamp(panel.fade - 0.031, 0, 1);
            hazards[name].tick = CurTime() + 0.01;
          else
            hazards[name] = nil;
          end
        end
      end

      -- Panel management
      local panelName = PANEL_SUBFIX .. name;
      if (not singleTray) then -- If is multi panel based, remove panels when time run out
        -- Add panel if doesn't exist
        if (not HOLOHUD:HasFlashPanel(panelName)) then
          HOLOHUD:AddFlashPanel(panelName);
        end

        -- Activate panel afterwards
        HOLOHUD:SetPanelActive(panelName, panel.time > CurTime());

        -- Remove panel when it fades out
        if (not HOLOHUD:IsPanelActive(panelName)) then
          HOLOHUD:RemovePanel(panelName);
          hazards[name] = nil;
        end
      end
    end

    if (tick < CurTime()) then
      -- Animate blinking
      if (blinked) then
        if (blink > BLINK) then
          blink = blink - BLINK_SPEED;
        else
          blinked = not blinked;
        end
      else
        if (blink < 1) then
          blink = blink + BLINK_SPEED;
        else
          blinked = not blinked;
        end
      end

      tick = CurTime() + 0.01;
    end
  end

  --[[
    Draws the hazards icons in a row
    @param {number} x
    @param {number} y
    @param {number} w
    @param {number} h
    @param {Color} colour
    @void
  ]]
  local function DrawIconRow(x, y, w, h, colour)
    local i = 0;
    for name, panel in pairs(hazards) do
      DrawIcon(x + (WIDTH * i), y, WIDTH, HEIGHT, name, colour);
      i = i + 1;
    end
  end

  --[[
    Draws a single panel with the icons
    @param {number} x
    @param {number} y
    @param {Color} colour
    @void
  ]]
  local function DrawSingleTray(x, y, colour)
    local w, h = math.Clamp(WIDTH * table.Count(hazards), WIDTH, ScrW()), HEIGHT;
    HOLOHUD:DrawFragment(x, y, w, h, DrawIconRow, PANEL_NAME, colour);
    return w, h;
  end

  --[[
    Draws multiple panels with the icons
    @param {number} x
    @param {number} y
    @param {Color} colour
    @void
  ]]
  local function DrawPanelsTray(x, y, colour)
    local i = 0;
    for name, panel in pairs(hazards) do
      HOLOHUD:DrawFragment(x + ((WIDTH + TRAY_MARGIN) * i), y, WIDTH, HEIGHT, DrawIcon, PANEL_SUBFIX .. name, name, colour);
      i = i + 1;
    end
    return math.Clamp((WIDTH + TRAY_MARGIN) * table.Count(hazards), WIDTH, ScrW()), HEIGHT;
  end

  --[[
    Draws the hazards panels
    @param {function} config
    @void
  ]]
  local function DrawPanel(config)
    local singleTray, colour = config("single_tray"), config("colour");
    local w, h = HOLOHUD.ELEMENTS:GetElementSize("health");
    local healthPanelMul = 1;
    if (not HOLOHUD:IsPanelActive("health") and not HOLOHUD:IsPanelActive("armour")) then healthPanelMul = 0; end
    local x, y = PANEL_MARGIN, ScrH() - (PANEL_MARGIN + HEIGHT + (h + HEALTH_MARGIN) * healthPanelMul);

    -- Animate icons
    Animate(singleTray);

    -- Set panel as active for other panels to know
    HOLOHUD:SetPanelActive(PANEL_NAME, table.Count(hazards) > 0, true);

    -- Lifetime
    if (not singleTray) then
      purged = false;
      return DrawPanelsTray(x, y, colour);
    else
      PurgePanels();
      return DrawSingleTray(x, y, colour);
    end
  end

  -- Add element
	HOLOHUD.ELEMENTS:AddElement("hazards",
		"#holohud.settings.hazards.name",
		"#holohud.settings.hazards.description",
		nil,
		{
      single_tray = { name = "#holohud.settings.hazards.single_tray", value = false },
      colour = { name = "#holohud.settings.hazards.color", value = Color(255, 255, 255) }
    },
		DrawPanel
	);

  -- Receive hazards from server

  --[[
    Adds a hazard icon to the tray
    @param {string} hazard
    @void
  ]]
  local function AddHazard(hazard)
    hazards[hazard] = {time = CurTime() + TIME, blink = 1, tick = 0, fade = 1};
  end

  net.Receive(NET, function(len)
    local damageType = net.ReadFloat();
    local hazard = HOLOHUD:GetHazard(damageType);
    if (hazard ~= nil) then
      AddHazard(hazard);
    end
  end);

end

-- Receive damage types
if SERVER then

  util.AddNetworkString(NET);

  hook.Add("EntityTakeDamage", "holohud_hazard", function(player, damage)
    if (not player:IsPlayer()) then return; end
    net.Start(NET);
    net.WriteFloat(damage:GetDamageType());
    net.Send(player);
  end);

end
