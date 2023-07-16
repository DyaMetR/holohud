--[[------------------------------------------------------------------
  PING DISPLAY
  How much latency does the current player have with the server
]]--------------------------------------------------------------------

if CLIENT then

  -- Parameters
  local PANEL_NAME = "ping";
  local PANEL_MARGIN = 20;
  local DOT_W, DOT_H = 16, 16;
  local ICON_W, ICON_H = 32, 32;
  local DOT_MARGIN = 8;
  local FORE_MARGIN, HEIGHT = 8, 50;
  local FONT = "holohud_med_sm";
  local UPDATE = 10; -- How often does the history update
  local OFF, NORMAL, MODERATE, HIGH, LAG = Color(255, 255, 255, 7), Color(255, 255, 255, 200), Color(255, 222, 0, 200), Color(255, 160, 0, 200), Color(255, 0, 0, 200);
  local KEY = IN_SCORE;

  -- Textures
  local ICON, ICON_BRIGHT = surface.GetTextureID("holohud/ping"), surface.GetTextureID("holohud/pingb");
  local DOT = surface.GetTextureID("holohud/ping_dot");
  local DOT_BG = surface.GetTextureID("holohud/ping_dot_bg");
  local DOT_BRIGHT = surface.GetTextureID("holohud/ping_dotb");

  -- Add panel and highlight
  HOLOHUD:AddFlashPanel(PANEL_NAME);
  HOLOHUD:AddHighlight(PANEL_NAME);

  -- Variables
  local history = {};
  local update = 0;
  local colour = 1; -- Current colour
  local lastColour = 1; -- Last colour
  local time = 0; -- Display time

  --[[
    Returns a colour based on ping code
    @param {number} code
    @return {Color} colour
  ]]
  local function GetColour(code)
    if (code == 1) then return OFF;
    elseif (code == 2) then return HOLOHUD.ELEMENTS:ConfigValue(PANEL_NAME, "low_colour");
    elseif (code == 3) then return HOLOHUD.ELEMENTS:ConfigValue(PANEL_NAME, "mod_colour");
    elseif (code == 4) then return HOLOHUD.ELEMENTS:ConfigValue(PANEL_NAME, "high_colour");
    elseif (code == 5) then return HOLOHUD.ELEMENTS:ConfigValue(PANEL_NAME, "lag_colour");
    end
  end

  --[[
    Returns a number based on the ping amount
    @return {number} code
  ]]
  local function GetPingCode()
    local ping = LocalPlayer():Ping();

    if (ping > 50 and ping < 100) then
			return 2;
		elseif (ping >= 100 and ping < 200) then
			return 3;
    elseif (ping >= 200 and ping < 300) then
      return 4;
    elseif (ping >= 300) then
      return 5;
		else
			return 1;
		end
  end


  --[[
    Returns the actual colour of the ping meter
    @return {Color} colour
  ]]
  local function GetPingColour()
    local code = math.Clamp(GetPingCode(), 2, 5);

    if (math.ceil(colour) > code) then
      return HOLOHUD:IntersectColour(GetColour(math.ceil(colour)), GetColour(code), colour - code);
    else
      return HOLOHUD:IntersectColour(GetColour(math.floor(colour)), GetColour(code), math.abs(colour - code));
    end
  end

  --[[
    Animates the numbers and ping history
    @param {number} amount of circles
    @void
  ]]
  local lastCode = 1;
  local function Animate(history_count)
    local ping = LocalPlayer():Ping();

    -- History
    if (not game.SinglePlayer() and (update < CurTime() or lastCode ~= GetPingCode())) then
      -- Remove the off-limit registries
      if (table.Count(history) > history_count) then
        table.remove(history, table.Count(history));
      end

      -- Insert new entry
      table.insert(history, 1, GetPingCode());

      -- Highlight if difference is big
      if (table.Count(history) <= 1) then
        HOLOHUD:TriggerHighlight(PANEL_NAME);
      else
        if (GetPingCode() ~= history[2] and (history[2] + GetPingCode() ~= 3)) then
          -- Highlight
          HOLOHUD:TriggerHighlight(PANEL_NAME);
          time = CurTime() + 8;
        end
      end

      update = CurTime() + UPDATE;
    end

    -- Colour fade out
		colour = Lerp(FrameTime() * 3, math.Clamp(colour, 2, 5), GetPingCode());

    -- Update last code
    lastCode = GetPingCode();

    -- Deploy if scoreboard is shown
    if (LocalPlayer():KeyDown(KEY) and time <= CurTime() + 4) then
      time = CurTime() + 4;
    end
  end

  --[[
    Draws the ping history
    @param {number} x
    @param {number} y
    @param {number} amount of circles
    @void
  ]]
  local function DrawHistory(x, y, amount)

    -- Draw history
    for i=0, (amount - 1) do
      local colour = Color(255, 255, 255, 12);
      local ping = history[i + 1];
      if (ping == nil) then
        ping = 1;
      end

      -- Colour the dot
      colour = GetColour(ping);
      HOLOHUD:DrawBrightTexture(DOT, DOT_BRIGHT, x + (DOT_MARGIN + 5) * i, y, DOT_W, DOT_H, colour, HOLOHUD:GetHighlight(PANEL_NAME), ping <= 1, GetPingCode() > 1);
    end
  end

  --[[
    Draws the ping meter
    @param {number} x
    @param {number} y
    @param {number} w
    @param {number} h
    @param {number} amount of history circles
    @param {boolean|nil} is off
    @void
  ]]
  local function DrawPing(x, y, w, h, history_count, off)
    off = off or false;
    local ping = LocalPlayer():Ping();

    -- Ping amount
    HOLOHUD:DrawNumber(x + w - 8, y + 18, ping, GetPingColour(), nil, HOLOHUD:GetHighlight(PANEL_NAME), FONT, off, TEXT_ALIGN_RIGHT);

    -- Icon
    local u, v, colour = 3, 2, GetPingColour();
    HOLOHUD:DrawBrightTexture(ICON, ICON_BRIGHT, x + u, y + v, ICON_W, ICON_H, colour, HOLOHUD:GetHighlight(PANEL_NAME), off, true);

    -- Draw history
    DrawHistory(x + (w * 0.5) - (((DOT_MARGIN + 5) * history_count) * 0.5) - 2, y + h - DOT_H - 2, history_count);
  end

  --[[
    Draws the ping panel
    @param {function} config
    @void
  ]]
  local function DrawPanel(config)
    local ping = LocalPlayer():Ping();
    local width = HOLOHUD:GetNumberSize(3, FONT) + FORE_MARGIN + ICON_W;
    local history_count = math.floor(width / (DOT_MARGIN + 6));

    -- Animate
    Animate(history_count);

    -- Draw
    HOLOHUD:SetPanelActive(PANEL_NAME, true);
    HOLOHUD:DrawFragmentAlignSimple(ScrW() - (PANEL_MARGIN + width), PANEL_MARGIN, width, HEIGHT, DrawPing, PANEL_NAME, TEXT_ALIGN_TOP, history_count, game.SinglePlayer());

    -- Activate panel
    HOLOHUD:SetPanelActive(PANEL_NAME, time > CurTime() or config("always") or ping >= 200);

    return width, HEIGHT;
  end

  -- Add element
  HOLOHUD.ELEMENTS:AddElement("ping",
    "#holohud.settings.ping.name",
    "#holohud.settings.ping.description",
    nil,
    {
      always = { name = "#holohud.settings.ping.always_displayed", value = false },
      low_colour = { name = "#holohud.settings.ping.low_color", value = NORMAL },
      mod_colour = { name = "#holohud.settings.ping.moderate_color", value = MODERATE },
      high_colour = { name = "#holohud.settings.ping.high_color", value = HIGH },
      lag_colour = { name = "#holohud.settings.ping.very_high_color", value = LAG }
    }, DrawPanel
  );

end
