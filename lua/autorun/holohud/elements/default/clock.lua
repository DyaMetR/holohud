--[[------------------------------------------------------------------
  CLOCK
  Display current time and date
]]--------------------------------------------------------------------

if CLIENT then

  -- Namespace
  HOLOHUD.ELEMENTS.CLOCK = {};

  HOLOHUD.ELEMENTS.CLOCK.DAY_OF_WEEK = {"Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"};
  HOLOHUD.ELEMENTS.CLOCK.MONTHS = {"Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"};

  --[[
    -- Include
    include("clock/simple.lua");
    include("clock/digital.lua");
  ]]
end

HOLOHUD:IncludeFile("clock/simple.lua");
HOLOHUD:IncludeFile("clock/digital.lua");

if CLIENT then

  -- Parameters
  local PANEL_NAME = "clock";
  local TIME = 10;

  -- Highlight and panel
  HOLOHUD:AddFlashPanel(PANEL_NAME);
  HOLOHUD:AddHighlight(PANEL_NAME);

  -- Value
  local time = 0;
  local lastUpdate = 0;

  --[[
    Trigger the clock if an hour passes
    @void
  ]]
  local function Animate(update)
    if ((CurTime() - lastUpdate)/60 > update) then
      HOLOHUD:TriggerHighlight(PANEL_NAME);
      time = CurTime() + TIME;
      lastUpdate = CurTime();
    end
  end

  --[[
		Animates and draws the full panel
		@param {table} config
		@void
	]]
  local function DrawPanel(config)
    local mode = config("mode");
    local hor_off, ver_off, sec, h24 = config("hor_off"), config("ver_off"), config("sec"), config("h24");
    local colour = config("colour");

    Animate(config("update"));
    HOLOHUD:SetPanelActive(PANEL_NAME, config("always") or time > CurTime());

    if (mode == 1 or mode == 3) then
      return HOLOHUD.ELEMENTS.CLOCK:DrawSimple(hor_off, ver_off, sec, h24, mode == 3, colour);
    elseif (mode == 2) then
      return HOLOHUD.ELEMENTS.CLOCK:DrawDigital(hor_off, ver_off, sec, h24, colour);
    end
  end

  -- Add element
  HOLOHUD.ELEMENTS:AddElement(PANEL_NAME,
    "Clock",
    "Display current time and date",
    nil,
    {
      always = { name = "Always displayed", desc = "Otherwise it will show up every hour", value = true },
      mode = { name = "Mode", value = 1, options = {"Simple", "Digital", "Simple with date"}},
      h24 = { name = "24 hours format", value = true },
      sec = { name = "Display seconds", value = true },
      hor_off = { name = "Horizontal offset", value = 0.5, minValue = 0, maxValue = 1 },
      ver_off = { name = "Vertical offset", value = 0.1, minValue = 0, maxValue = 1 },
      update = { name = "Update rate", desc = "How often (in minutes) it highlights itself", value = 60, minValue = 1, maxValue = 120 },
      colour = { name = "Colour", value = Color(255, 255, 255) }
    },
    DrawPanel
  );

end
