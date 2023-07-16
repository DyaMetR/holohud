--[[------------------------------------------------------------------
  CLOCK
  Display current time and date
]]--------------------------------------------------------------------

if CLIENT then

  -- Namespace
  HOLOHUD.ELEMENTS.CLOCK = {};

  HOLOHUD.ELEMENTS.CLOCK.DAY_OF_WEEK = {
    "holohud.hud.clock.week.sunday",
    "holohud.hud.clock.week.monday",
    "holohud.hud.clock.week.tuesday",
    "holohud.hud.clock.week.wednesday",
    "holohud.hud.clock.week.thursday",
    "holohud.hud.clock.week.friday",
    "holohud.hud.clock.week.saturday"
  };
  HOLOHUD.ELEMENTS.CLOCK.MONTHS = {
    "holohud.hud.clock.month.january",
    "holohud.hud.clock.month.february",
    "holohud.hud.clock.month.march",
    "holohud.hud.clock.month.april",
    "holohud.hud.clock.month.may",
    "holohud.hud.clock.month.june",
    "holohud.hud.clock.month.july",
    "holohud.hud.clock.month.august",
    "holohud.hud.clock.month.september",
    "holohud.hud.clock.month.october",
    "holohud.hud.clock.month.november",
    "holohud.hud.clock.month.december"
  };

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
    "#holohud.settings.clock.name",
    "#holohud.settings.clock.description",
    nil,
    {
      always = { name = "#holohud.settings.clock.always_displayed", desc = "#holohud.settings.clock.always_displayed.description", value = true },
      mode = { name = "#holohud.settings.clock.mode", value = 1, options = {"#holohud.settings.clock.mode.simple", "#holohud.settings.clock.mode.digital", "#holohud.settings.clock.mode.simple_with_date"}},
      h24 = { name = "#holohud.settings.clock.24format", value = true },
      sec = { name = "#holohud.settings.clock.show_seconds", value = true },
      hor_off = { name = "#holohud.settings.clock.x", value = 0.5, minValue = 0, maxValue = 1 },
      ver_off = { name = "#holohud.settings.clock.y", value = 0.1, minValue = 0, maxValue = 1 },
      update = { name = "#holohud.settings.clock.update_rate", desc = "#holohud.settings.clock.update_rate.description", value = 60, minValue = 1, maxValue = 120 },
      colour = { name = "#holohud.settings.clock.color", value = Color(255, 255, 255) }
    },
    DrawPanel
  );

end
