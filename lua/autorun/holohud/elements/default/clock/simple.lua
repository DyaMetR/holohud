--[[------------------------------------------------------------------
  CLOCK
  Simple variant
]]--------------------------------------------------------------------

if CLIENT then

  -- Namespace
  local CLOCK = HOLOHUD.ELEMENTS.CLOCK;

  -- Parameters
  local PANEL_NAME = "clock";
  local MARGIN, H, EXT_H = 14, 31, 47;

  --[[
    Draws a simple HH:MM:SS clock
    @param {string} time
    @param {string} date
    @boolean {boolean} isDateEnabled
    @void
  ]]
  local function Foreground(x, y, w, h, time, date, isDateEnabled, colour)
    HOLOHUD:DrawText(x + (w * 0.5), y + (H * 0.5), time, "holohud_clock_main", colour, HOLOHUD:GetHighlight(PANEL_NAME), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER);
    if (isDateEnabled) then
      HOLOHUD:DrawText(x + (w * 0.5), y + 24, date, "holohud_clock_small", colour, HOLOHUD:GetHighlight(PANEL_NAME), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP);
    end
  end

  --[[
    Draws the simple clock variant
    @param {number} horizontal offset
    @param {number} vertical offset
    @param {boolean} should draw seconds
    @param {boolean} is 24 hours format
    @param {boolean} is date enabled
    @void
  ]]
  function HOLOHUD.ELEMENTS.CLOCK:DrawSimple(hor_off, ver_off, sec, h24, isDateEnabled, colour)
    local timestamp = os.time();

    -- Get format
    local format = "%H:%M:%S";
    if (not sec) then format = "%H:%M"; end
    if (not h24) then
      local hour = tonumber(os.date("%H", timestamp));
      format = string.Replace(format, "H", "I");
      if (hour > 12) then
        format = format .. " PM";
      else
        format = format .. " AM";
      end
    end

    -- Time
    local time = os.date(format, timestamp);

    -- Get size
    surface.SetFont("holohud_clock_main");
    local timeW = surface.GetTextSize(time);

    local dateW = 0;
    local date = nil;
    local h = H;
    if (isDateEnabled) then
      surface.SetFont("holohud_clock_small");
      date = CLOCK.DAY_OF_WEEK[tonumber(os.date("%w", timestamp)) + 1] .. ", " .. os.date("%d", timestamp) .. " " .. CLOCK.MONTHS[tonumber(os.date("%m", timestamp))];
      dateW = surface.GetTextSize(date);
      h = EXT_H;
    end

    local w = math.max(timeW, dateW) + MARGIN;

    HOLOHUD:DrawFragmentAlignSimple((ScrW() * hor_off) - (w * 0.5), ScrH() * ver_off, w, h, Foreground, PANEL_NAME, TEXT_ALIGN_TOP, time, date, isDateEnabled, colour);

    return w, h;
  end

end
