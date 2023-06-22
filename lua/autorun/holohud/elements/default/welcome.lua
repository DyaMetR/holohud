--[[------------------------------------------------------------------
  WELCOME SCREEN
  Welcomes the player once they get the HEV or spawn for the first time
]]--------------------------------------------------------------------

if CLIENT then

  -- Parameters
  local PANEL_NAME = "welcome";
  local W, H = 250, 304;
  local TITLE_COLOUR = Color(133, 216, 255);
  local TEXTURE = surface.GetTextureID("gui/center_gradient");
  local MAX_SYS_LOG = 14;
  local WELCOME = "#Welcome";
  local TITLE = "H0L-D4";
  local VERSION = HOLOHUD.Version.Major .. "." .. HOLOHUD.Version.Minor;
  local PATCH = HOLOHUD.Version.Patch .. language.GetPhrase( "Welcome.X.Paches.Applied" );
  local LOG_SPEED = 0.3; -- How often do new entries appear
  local TIME = 2.33; -- How much time is given to the user to see the full log before fading out
  local NO_PRESETS = language.GetPhrase( "Welcome.No_Presets" );

  -- Fonts
  HOLOHUD:CreateFont("holohud_welcome_title", 40, "Roboto", 0);
  HOLOHUD:CreateFont("holohud_welcome_subtitle", 20, "Roboto", 0);
  HOLOHUD:CreateFont("holohud_welcome_text", 20, "Roboto Condensed Light", 0);
  HOLOHUD:CreateFont("holohud_welcome_loading", 20, "Roboto Condensed", 0);

  -- Panel
  HOLOHUD:AddFlashPanel(PANEL_NAME);

  -- Variables
  local logQueue = {"All set. Have fun!"}; -- Configuration log entries to display
  local sysQueue = {}; -- Loading log entries to display
  local log = {}; -- Configuration log
  local sysLog = {}; -- Loading log
  local faded = false; -- Loading log was faded in
  local alpha = 0; -- Loading log alpha
  local tickL = 0; -- Loading log tick
  local tick = 0; -- Config log tick
  local time = 0; -- Time for the panel to hide
  local ended = true; -- Has the configuration boot up sequence finished
  local scroll = 0; -- Scrolling animation
  local sysLogCount = 0; -- System log count
  local nextTime = 0; -- Next log time
  local hasSuit = true;

  --[[
    Loads the log queue
    @void
  ]]
  local function LoadLog()
    -- Configuration log
    local presets = NO_PRESETS;
    local fonts = NO_PRESETS;

    if (table.Count(HOLOHUD.CONFIG.PRESETS:GetPresets()) > 0) then
      presets = language.GetPhrase( "Welcome.Loaded" ) .. table.Count(HOLOHUD.CONFIG.PRESETS:GetPresets()) .. language.GetPhrase( "Welcome.Loaded.X.Presets" );
    end

    if (table.Count(HOLOHUD.CONFIG.FONTS:GetFontPresets()) > 0) then
      fonts = language.GetPhrase( "Welcome.Loaded" ) .. table.Count(HOLOHUD.CONFIG.FONTS:GetFontPresets()) .. language.GetPhrase( "Welcome.Loaded.X.Presets" );
    end

    logQueue = {
      table.Count(HOLOHUD.ELEMENTS:GetElements()) .. language.GetPhrase( "Welcome.X.HUD.Elements.Found" ),
      language.GetPhrase( "Welcome.Loading.User.Configuration" ),
      language.GetPhrase( "Welcome.Configuration.Loaded" ),
      language.GetPhrase( "Welcome.Font.Configuration.Loaded" ),
      language.GetPhrase( "Welcome.Scanning.Layout.Presets" ),
      presets,
      language.GetPhrase( "Welcome.Scanning.Font.Presets" ),
      fonts,
      "",
      language.GetPhrase( "Welcome.All.Set.HF" )
    };

    -- By default, sys queue will consist of loading all elements
    for _, element in pairs(HOLOHUD.ELEMENTS:GetElements()) do
      table.insert(sysQueue, language.GetPhrase( "Welcome.Loading.Element.X" ) .. element.title .. "...");
      table.insert(sysQueue, language.GetPhrase( "Welcome.Loading.Element.X.Done" ));
    end
  end
  LoadLog(); -- In case something goes wrong, preload log

  --[[
    Resets the animation
    @void
  ]]
  function HOLOHUD:ResetWelcomeAnimation()
    LoadLog();
    log = {};
    sysLog = {};
    faded = false;
    alpha = 0;
    tick = 0;
    time = 0;
    ended = false;
    scroll = 0;
    sysLogCount = 0;
    nextTime = 0;
    hasSuit = true;
  end

  --[[
    Runs the system log animation
    @void
  ]]
  local function SystemLogAnim()
    if (not faded) then
      if (alpha < 1) then
        if (tickL < CurTime()) then
          alpha = math.Clamp(alpha + 0.02, 0, 1);
          tickL = CurTime() + 0.01;
        end
      else
        faded = true;
      end
    else
      local count = table.Count(sysLog);
      if (sysLogCount <= 0 or (scroll <= 0 and sysLogCount < table.Count(sysQueue) and sysLog[count].len >= string.len(sysLog[count].text))) then
        table.insert(sysLog, {text = sysQueue[sysLogCount + 1], len = 0});
        sysLogCount = sysLogCount + 1;
      end

      if (tickL < CurTime()) then

        -- Animate text
        local entry = sysLog[table.Count(sysLog)];
        if (entry ~= nil and entry.len < string.len(entry.text)) then
          sysLog[table.Count(sysLog)].len = math.Clamp(entry.len + 1, 0, string.len(entry.text));
        end

        -- Scroll up if limit is reached
        if (table.Count(sysLog) > MAX_SYS_LOG) then
          if (scroll < 1) then
            scroll = math.Clamp(scroll + 0.3, 0, 1);
          else
            table.remove(sysLog, 1);
            scroll = 0;
          end
        end

        -- Fade out
        if (ended) then
          alpha = math.Clamp(alpha - 0.04, 0, 1);
        end
        tickL = CurTime() + 0.01;
      end
    end
  end

  --[[
    Runs the configuration log animation
    @void
  ]]
  local function LogAnim()
    local count = table.Count(log);
    if (tick < CurTime() and HOLOHUD:GetFlashPanel(PANEL_NAME).flash <= 0) then
      if (nextTime < CurTime() and (count <= 0 or (count < table.Count(logQueue) and log[count].len >= string.len(logQueue[count])))) then
        table.insert(log, {i = count + 1, len = 0});
      end

      for _, entry in pairs(log) do
        if (entry.len < string.len(logQueue[entry.i])) then
          log[entry.i].len = log[entry.i].len + 1;
          time = CurTime() + TIME;
          nextTime = CurTime() + LOG_SPEED;
        end
      end

      -- Hide panel if has ended
      if (count >= table.Count(logQueue) and log[count].len >= string.len(logQueue[count])) then
        ended = true;
      end
      tick = CurTime() + 0.02;
    end
  end

  --[[
    Animates the log panels
    @void
  ]]
  local function Animate()
    if (HOLOHUD:CanDisplayPanel(PANEL_NAME)) then
      SystemLogAnim();
      LogAnim();
    else
      if (table.Count(sysLog) > 0 or table.Count(log) > 0) then
        sysLog = {};
        log = {};
      end
    end
  end

  --[[
    Draws the welcome header
    @param {number} x
    @param {number} y
    @param {number} w
    @param {Color} title colour
    @param {Color} text colour
    @void
  ]]
  local lerp = 0;
  local function DrawHeader(x, y, w, titleCol, textCol)
    titleCol = titleCol or TITLE_COLOUR;
    textCol = textCol or Color(255, 255, 255);
    lerp = Lerp(FrameTime() * 2, lerp, 1);

    -- Draw
    HOLOHUD:DrawText(x + 6, y + 3, WELCOME, "holohud_welcome_text", textCol);
    HOLOHUD:DrawText(x + 14, y + 21, TITLE, "holohud_welcome_title", titleCol);
    HOLOHUD:DrawText(x + 136, y + 57, HOLOHUD.Version.Major .. "." .. HOLOHUD.Version.Minor, "holohud_welcome_subtitle", titleCol, nil, nil, TEXT_ALIGN_BOTTOM);

    draw.RoundedBox(0, x + 10, y + 64, (w - 20) * lerp, 1, Color(titleCol.r, titleCol.g, titleCol.b, 166));
    if (HOLOHUD.Version.Patch > 0) then
      HOLOHUD:DrawText(x + 14, y + 68, PATCH, "holohud_welcome_subtitle", titleCol);
    end
  end

  --[[
    Draws a log entry
    @param {number} x
    @param {number} y
    @param {string} text
    @param {Color} title colour
    @param {Color} text colour
    @void
  ]]
  local function DrawRow(x, y, text, alpha, titleCol, textCol)
    titleCol = titleCol or TITLE_COLOUR;
    textCol = textCol or Color(255, 255, 255);
    if (string.len(text) <= 0) then return; end
    HOLOHUD:DrawText(x, y, ">", "holohud_welcome_subtitle", Color(titleCol.r, titleCol.g, titleCol.b, 255 * alpha));
    HOLOHUD:DrawText(x + 14, y + 1, text, "holohud_welcome_text", Color(textCol.r, textCol.g, textCol.b, 255 * alpha));
  end

  --[[
    Draws a loading sequence log entry
    @param {number} x
    @param {number} y
    @param {string} text
    @param {number} alpha
    @void
  ]]
  local function DrawLoadRow(x, y, text, alpha)
    HOLOHUD:DrawText(x, y, "> " .. text, "holohud_welcome_loading", Color(255, 255, 255), nil, nil, nil, true, 24 * alpha);
  end

  --[[
    Draws the loading log
    @param {number} x
    @param {number} y
    @param {Color} title colour
    @param {Color} text colour
    @void
  ]]
  local function DrawLog(x, y, titleCol, textCol)
    for i, entry in pairs(log) do
      DrawRow(x, y + 20 * (i - 1), string.sub(logQueue[entry.i], 1, entry.len), 1, titleCol, textCol);
    end
  end

  --[[
    Draws the loading sequence log
    @param {number} x
    @param {number} y
    @void
  ]]
  local function DrawLoadingLog(x, y)
    for i, entry in pairs(sysLog) do
      local a = 1;
      if (i == 1) then
        a = 1 - scroll;
      end
      DrawLoadRow(x, y + (20 * ((i - scroll) - 1)), string.sub(entry.text, 1, math.Clamp(entry.len, 0, 36)), a * alpha);
    end
  end

  --[[
    Draws the system boot up screen
    @param {number} x
    @param {number} y
    @void
  ]]
  local function DrawSystemBootup(x, y)
    -- Background
    draw.RoundedBox(0, x, y, W, H, Color(0, 0, 0, 26 * alpha));
    surface.SetTexture(TEXTURE);
    surface.SetDrawColor(Color(0, 0, 0, 100 * alpha));
    surface.DrawTexturedRect(x, y, W, H);

    -- Foreground
    DrawLoadingLog(x + 6 + (HOLOHUD:GetSway() * 0.33), y + 5);
  end

  --[[
    Draws the foreground
    @param {number} x
    @param {number} y
    @param {number} w
    @param {number} h
    @param {Color} title colour
    @param {Color} text colour
    @void
  ]]
  local function DrawConfigBootup(x, y, w, h, titleCol, textCol)
    Animate();
    DrawSystemBootup(math.Clamp(ScrW() * 0.23, 0, ScrW() - W) + HOLOHUD:GetSway(), y);
    DrawHeader(x, y, w, titleCol, textCol);
    DrawLog(x + 8, y + 94, titleCol, textCol);
  end

  --[[
    Controls whether the panel should be drawn, and draws it
    @param {function} configuration
    @void
  ]]
  local function DrawPanel(config)
    -- Offset
    local x, y = math.Clamp(ScrW() * 0.56, 0, ScrW() - W), (ScrH() * 0.5) - (H * 0.5);

    -- Reset
    if (not LocalPlayer():Alive()) then
      hasSuit = true;
      ended = true;
    else
      if (hasSuit ~= LocalPlayer():IsSuitEquipped()) then
        HOLOHUD:ResetWelcomeAnimation();
        hasSuit = LocalPlayer():IsSuitEquipped();
      end
    end

    -- Draw
    HOLOHUD:SetPanelActive(PANEL_NAME, (time > CurTime() or not ended) and hasSuit, true);
    HOLOHUD:DrawFragmentAlignSimple(x, y, W, H, DrawConfigBootup, PANEL_NAME, TEXT_ALIGN_TOP, config("title"), config("text"));

    return W, H;
  end

  -- Add element
  HOLOHUD.ELEMENTS:AddElement(PANEL_NAME,
    language.GetPhrase( "Welcome.Settings.Title" ),
    "#Welcome.Settings.Desc",
    nil,
    {
      title = { name = "#Welcome.Settings.Title.Coluor", value = TITLE_COLOUR },
      text = { name = "#Welcome.Settings.Text.Coluor", value = Color(255, 255, 255) }
    },
    DrawPanel
  );

end
