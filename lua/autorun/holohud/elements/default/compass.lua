--[[------------------------------------------------------------------
  COMPASS
  Displays current player's bearings
]]--------------------------------------------------------------------

if CLIENT then

  -- Parameters
  local MAIN_FONT, SEC_FONT = "holohud_compass", "holohud_compass_small";
  local PANEL_NAME = "compass";
  local PANEL_NAME_MAIN = "compass_main";
  local SCREEN_OFFSET = 35;
  local W, H = 400, 27;
  local ANGLE_HEIGHT, ANGLE_WIDTH_MARGIN = 28, 10;
  local BEARING_MARGIN = 10;

  HOLOHUD:AddFlashPanel(PANEL_NAME);
  HOLOHUD:AddFlashPanel(PANEL_NAME_MAIN);

  --[[
    Draws a bearing position on screen relative to the player's rotation
    @param {number} x
    @param {number} y
    @param {number} w
    @param {number} h
    @param {string} bearing
    @param {number|nil} angle
    @param {boolean|nil} minor bearing
    @param {boolean|nil} should it be using numbers or lines
    @param {number|nil} distance scale
    @param {boolean|nil} should display in 360 degrees
    @param {Color} colour
    @void
  ]]
  local function DrawGraduation(x, y, w, h, bearing, angle, isMinor, numbers, scale, degrees, colour)
    degrees = degrees or false;
    numbers = numbers or nil;
    scale = scale or 1;
    angle = angle or 0;
    isMinor = isMinor or false;

    -- Display bearing in 0 -> 360 or -180 -> 180
    if (degrees and type(bearing) == "number") then
      bearing = bearing + 180;
    end

    -- Get the offset of the icon
    local X = x + (w * 0.5) + (W * scale * 2 * (LocalPlayer():GetAngles().y / 180)) + (W * scale * 2 * (angle / 180));

    if (X < x or X > x + w) then return; end -- Don't draw if it's not on range

    local font = MAIN_FONT;

    -- Change size and colour if it's not a major bearing
    if (isMinor) then
      colour = Color(colour.r * 0.65, colour.g * 0.65, colour.b * 0.65);
      font = SEC_FONT;

      if (not numbers) then
        bearing = "I";
      end
    end

    -- Get opacity
    surface.SetFont(font);
    local size = surface.GetTextSize(bearing);
    local a = math.min(math.Clamp(((X - x) - (size * 0.5)) / size, 0, 1), math.Clamp((w - ((X - x) + (size * 0.5))) / size, 0, 1));

    HOLOHUD:DrawText(X, y + (h * 0.5) - 1, bearing, font, colour, nil, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, nil, a * 200)
  end

  --[[
    Draws the main compass element
    @param {boolean} display in 360 degrees
    @param {number} distance between bearings scale
    @param {boolean} display numbers in between
    @param {Color} colour
    @void
  ]]
  local function DrawCompass(x, y, w, h, degrees, scale, numbers, colour)
    if (w > (W * 1.5) and scale < w/(W * 1.5)) then scale = w/(W * 1.5); end

    -- Major
    DrawGraduation(x, y, w, h, "#holohud.hud.compass.north", -90, nil, numbers, scale, degrees, colour);
    DrawGraduation(x, y, w, h, "#holohud.hud.compass.south", 90, nil, numbers, scale, degrees, colour);
    DrawGraduation(x, y, w, h, "#holohud.hud.compass.east", 0, nil, numbers, scale, degrees, colour);
    DrawGraduation(x, y, w, h, "#holohud.hud.compass.west", 180, nil, numbers, scale, degrees, colour);
    DrawGraduation(x, y, w, h, "#holohud.hud.compass.west", -180, nil, numbers, scale, degrees, colour);

    -- Minor
    for i=1,8 do -- North to east
      DrawGraduation(x, y, w, h, i * -BEARING_MARGIN, i * BEARING_MARGIN, true, numbers, scale, degrees, colour);
    end

    for i=10, 17 do -- South to west positive
      DrawGraduation(x, y, w, h, i * BEARING_MARGIN, i * -BEARING_MARGIN, true, numbers, scale, degrees, colour);
    end

    for i=19, 26 do -- South to east positive
      DrawGraduation(x, y, w, h, - 360 + (i * BEARING_MARGIN), i * -BEARING_MARGIN, true, numbers, scale, degrees, colour);
    end

    for i=19, 26 do -- South to west negative
      local angle = (19 - i) + 17;
      DrawGraduation(x, y, w, h, angle * BEARING_MARGIN, i * BEARING_MARGIN, true, numbers, scale, degrees, colour);
    end

    for i=10, 17 do -- East to south negative
      DrawGraduation(x, y, w, h, i * -BEARING_MARGIN, i * BEARING_MARGIN, true, numbers, scale, degrees, colour);
    end

    for i=1,8 do -- North to west
      DrawGraduation(x, y, w, h, i * BEARING_MARGIN, i * -BEARING_MARGIN, true, numbers, scale, degrees, colour);
    end
  end

  --[[
    Displays the current player's yaw angle
    @param {boolean} 0 to 360 degrees
    @param {Color} colour
    @void
  ]]
  local function DrawAngle(x, y, w, h, degrees, colour)
    degrees = degrees or false;
    local angle = LocalPlayer():GetAngles().y;
    local zeroes = "-000";

    -- Adjust element based on configuration
    if (degrees) then
      angle = angle + 180;
      zeroes = nil;
    end

    -- Draw number
    HOLOHUD:DrawNumber(x + (w * 0.5) - 1, y + (h * 0.5), math.Round(angle), colour, zeroes, nil, MAIN_FONT, nil, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER);
  end

  --[[
    Draws the full compass element
    @param {function} config
    @void
  ]]
  local function DrawPanel(config)
    local w = config("width") or W;

    -- Draw the compass
    HOLOHUD:SetPanelActive(PANEL_NAME_MAIN, config("always"));
    HOLOHUD:DrawFragmentAlignSimple((ScrW() * 0.5) - (w * 0.5), ScrH() * config("offset"), w, H, DrawCompass, PANEL_NAME_MAIN, TEXT_ALIGN_TOP, config("degrees"), config("scale"), config("numbers"), config("colour"));

    -- Get degrees panel size
    local size = 3;
    if (not config("degrees")) then size = 4; end
    w = HOLOHUD:GetNumberSize(size, MAIN_FONT) + (ANGLE_WIDTH_MARGIN * 2);

    -- Draw the degrees panel
    HOLOHUD:SetPanelActive(PANEL_NAME, config("rotation"), true);
    HOLOHUD:DrawFragmentAlignSimple((ScrW() * 0.5) - (w * 0.5), (ScrH() * config("offset")) + H + 4, w, ANGLE_HEIGHT, DrawAngle, PANEL_NAME, TEXT_ALIGN_TOP, config("degrees"), config("colour"));

    -- Get current total height
    local h = H;
    if (config("rotation")) then h = h + 4 + ANGLE_HEIGHT; end

    return w, h;
  end

  -- Add element
	HOLOHUD.ELEMENTS:AddElement("compass",
		"#holohud.settings.compass.name",
		"#holohud.settings.compass.description",
		nil,
		{
      always = { name = "#holohud.settings.compass.always_displayed", desc = "#holohud.settings.compass.always_displayed.description", value = true },
      numbers = { name = "#holohud.settings.compass.numeric_inbetween", desc = "#holohud.settings.compass.numeric_inbetween.description", value = false },
      rotation = { name = "#holohud.settings.compass.angle", value = false },
      degrees = { name = "#holohud.settings.compass.360angle", desc = "#holohud.settings.compass.360angle.description", value = false },
      scale = { name = "#holohud.settings.compass.scale", value = 1, minValue = 0.66, maxValue = 5 },
      width = { name = "#holohud.settings.compass.width", value = W, minValue = 0, maxValue = W * 5 },
      offset = { name = "#holohud.settings.compass.offset", value = 0.044, minValue = 0, maxValue = 1 },
      colour = { name = "#holohud.settings.compass.color", value = Color(255, 255, 255)}
    },
		DrawPanel
	);

end
