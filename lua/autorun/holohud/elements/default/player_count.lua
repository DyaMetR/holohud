--[[------------------------------------------------------------------
  PLAYER COUNT
  How many players are in the server currently
]]--------------------------------------------------------------------

if CLIENT then

  -- Parameters
  local SCREEN_OFFSET = 20;
  local HEIGHT = 43;
  local PANEL_NAME = "player_count";
  local COLOUR = Color(180, 226, 255, 200);
  local TEXTURE, TEXTURE_BRIGHT = surface.GetTextureID("holohud/user"), surface.GetTextureID("holohud/userb");
  local BRIGHT = 0.36;
  local TIME = 7; -- Time displayed when a player joins/leaves
  local REFRESH_TIME = 4; -- Time displayed when the scoreboard is shown
  local KEY = IN_SCORE;
  local MARGIN = 51;

  -- Highlight and panel
  HOLOHUD:AddHighlight(PANEL_NAME);
  HOLOHUD:AddFlashPanel(PANEL_NAME);

  -- Variables
  local lastPlys = 1;
  local time = 0;

  --[[
    Draws the player count indicator
    @param {number} x
    @param {number} y
    @param {number} w
    @param {number} h
    @param {boolean} is off
    @param {Color} colour
    @void
  ]]
  local function DrawCount(x, y, w, h, off, colour)
    local offset = HOLOHUD:GetNumberSize(3, "holohud_med_sm") + 40;
    local bright = HOLOHUD:GetHighlight(PANEL_NAME);
    HOLOHUD:DrawNumber(x + 35, y + (h * 0.5), player.GetCount(), colour, "000", bright, "holohud_med_sm", off);
    if (not off) then
      HOLOHUD:DrawBrightTexture(TEXTURE, TEXTURE_BRIGHT, x + 5, y + 5, 32, 32, colour, bright, false, true);
    else
      HOLOHUD:DrawTexture(TEXTURE, x + 5, y + 5, 32, 32, Color(255, 255, 255, 8));
    end
    HOLOHUD:DrawNumber(x + offset, y + (h * 0.5), game.MaxPlayers(), colour, "000", bright, "holohud_small", off);
  end

  --[[
    Animates and draws the player count panel
    @param {function} config
    @void
  ]]
  local function DrawPanel(config)
    -- Show if player count changes
    if (lastPlys ~= player.GetCount()) then
      HOLOHUD:TriggerHighlight(PANEL_NAME);
      time = CurTime() + TIME;
      lastPlys = player.GetCount();
    end

    -- Show if scoreboard is shown
    if (LocalPlayer():KeyDown(KEY)) then
      time = CurTime() + REFRESH_TIME;
    end

    -- Get width
    local w = HOLOHUD:GetNumberSize(3, "holohud_med_sm") + HOLOHUD:GetNumberSize(3, "holohud_small") + MARGIN;

    HOLOHUD:SetPanelActive(PANEL_NAME, time > CurTime() or config("always"));
    HOLOHUD:DrawFragmentAlignSimple(SCREEN_OFFSET, SCREEN_OFFSET, w, HEIGHT, DrawCount, PANEL_NAME, TEXT_ALIGN_TOP, game.SinglePlayer(), config("colour"));

    return w, HEIGHT;
  end

  -- Add element
  HOLOHUD.ELEMENTS:AddElement(PANEL_NAME,
    "#holohud.settings.player_count.name",
    "#holohud.settings.player_count.description",
    nil,
    {
      always = { name = "#holohud.settings.player_count.always_displayed", value = false },
      colour = { name = "#holohud.settings.player_count.color", value = COLOUR }
    },
    DrawPanel
  );

end
