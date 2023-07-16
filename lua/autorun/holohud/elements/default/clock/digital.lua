--[[------------------------------------------------------------------
  CLOCK
  Simple variant
]]--------------------------------------------------------------------

if CLIENT then

  -- Parameters
  local CLOCK = HOLOHUD.ELEMENTS.CLOCK;
  local PANEL_NAME = "clock";
  local MARGIN, H = 21, 67;

  -- Create font for AM/PM
  HOLOHUD:CreateFont("holohud_clock_digital1", 14, "Roboto Condensed Light", 0);

  --[[
    Draws a simple HH:MM:SS clock
    @param {table} timestamp
    @param {string} week date
    @param {boolean} is on 24 hour format
    @param {boolean} should seconds display
    @param {Color} colour
    @void
  ]]
  local function Foreground(x, y, w, h, timestamp, date, h24, sec, colour)
    local offset = 8;
    local min_offset = HOLOHUD:GetNumberSize(2, "holohud_clock_big") + offset;
    local sec_offset = min_offset - HOLOHUD:GetNumberSize(2, "holohud_clock_med") + 9;

    -- Time
    local format = "H";
    if (not h24) then format = "I"; end
    local hour = tonumber(os.date("%" .. format, timestamp));
    HOLOHUD:DrawNumber(x + offset, y - 4, hour, colour, "00", HOLOHUD:GetHighlight(PANEL_NAME), "holohud_clock_big", nil, nil, TEXT_ALIGN_TOP);
    HOLOHUD:DrawNumber(x + min_offset, y + 34, os.date("%M", timestamp), colour, "00", HOLOHUD:GetHighlight(PANEL_NAME), "holohud_clock_med", nil, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP);
    if (sec) then
      HOLOHUD:DrawNumber(x + min_offset + 2, y + 1, os.date("%S", timestamp), colour, "00", HOLOHUD:GetHighlight(PANEL_NAME), "holohud_clock_main", nil, nil, TEXT_ALIGN_TOP);
    end

    -- AM/PM
    if (not h24) then
      local pm = tonumber(os.date("%H", timestamp)) > 12;
      HOLOHUD:DrawText(x + 6, y + 39, "AM", "holohud_clock_digital1", colour, HOLOHUD:GetHighlight(PANEL_NAME), nil, nil, pm);
      HOLOHUD:DrawText(x + 6, y + 48, "PM", "holohud_clock_digital1", colour, HOLOHUD:GetHighlight(PANEL_NAME), nil, nil, not pm);
    end

    -- Date
    local date_offset = 0;
    if (not sec) then date_offset = 8; end
    HOLOHUD:DrawText(x + min_offset + 3, y + 25 - date_offset, date, "holohud_clock_small", colour, HOLOHUD:GetHighlight(PANEL_NAME));
    HOLOHUD:DrawText(x + min_offset + 3, y + 41 - date_offset, language.GetPhrase(CLOCK.MONTHS[tonumber(os.date("%m", timestamp))]), "holohud_clock_small", colour, HOLOHUD:GetHighlight(PANEL_NAME));
  end

  --[[
    Draws the simple clock variant
    @param {number} horizontal offset
    @param {number} vertical offset
    @param {boolean} should draw seconds
    @param {boolean} is 24 hours format
    @param {Color} colour
    @void
  ]]
  function HOLOHUD.ELEMENTS.CLOCK:DrawDigital(hor_off, ver_off, sec, h24, colour)
    local timestamp = os.time();
    local w = HOLOHUD:GetNumberSize(2, "holohud_clock_big");
    surface.SetFont("holohud_clock_small");

    local weekDay = os.date("*t", os.time()).wday;
    local date = language.GetPhrase(CLOCK.DAY_OF_WEEK[weekDay]) .. ", " .. os.date("%d", timestamp);
    w = w + surface.GetTextSize(date) + MARGIN;

    HOLOHUD:DrawFragmentAlignSimple((ScrW() * hor_off) - (w * 0.5), ScrH() * ver_off, w, H, Foreground, PANEL_NAME, TEXT_ALIGN_TOP, timestamp, date, h24, sec, colour);

    return w, H;
  end

end
