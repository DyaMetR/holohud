--[[
  PERCENTAGE BAR
  Percentage bar component, used mainly for the health bar
]]

if CLIENT then

  -- Textures
  local BAR_BACKGROUND = surface.GetTextureID("holohud/bar/background");
  local BAR_OUTLINE = surface.GetTextureID("holohud/bar/outline");
  local BAR_FOREGROUND = surface.GetTextureID("holohud/bar/foreground");
  local BAR_BRIGHT = surface.GetTextureID("holohud/bar/bright");
  local BAR_GRADIENT = surface.GetTextureID("holohud/bar/gradient");

  -- Background
  local BACKGROUND_START = surface.GetTextureID("holohud/bar/background/start");
  local BACKGROUND_BODY = surface.GetTextureID("holohud/bar/background/body");
  local BACKGROUND_END = surface.GetTextureID("holohud/bar/background/end");

  -- Outline
  local OUTLINE_START = surface.GetTextureID("holohud/bar/outline/start");
  local OUTLINE_BODY = surface.GetTextureID("holohud/bar/outline/body");
  local OUTLINE_END = surface.GetTextureID("holohud/bar/outline/end");

  -- Foreground
  local FOREGROUND_START = surface.GetTextureID("holohud/bar/foreground/start");
  local FOREGROUND_BODY = surface.GetTextureID("holohud/bar/foreground/body");
  local FOREGROUND_END = surface.GetTextureID("holohud/bar/foreground/end");

  -- Bright
  local BRIGHT_START = surface.GetTextureID("holohud/bar/bright/start");
  local BRIGHT_BODY = surface.GetTextureID("holohud/bar/bright/body");
  local BRIGHT_END = surface.GetTextureID("holohud/bar/bright/end");

  -- Gradient
  local GRADIENT_START = surface.GetTextureID("holohud/bar/gradient/start");
  local GRADIENT_BODY = surface.GetTextureID("holohud/bar/gradient/body");
  local GRADIENT_END = surface.GetTextureID("holohud/bar/gradient/end");

  -- Parameters
  local BAR_WIDTH, BAR_HEIGHT = 138, 24;

  local BODY_WIDTH, BODY_HEIGHT = 128, 32;
  local BODY_REAL_WIDTH = 104;

  local EXT_WIDTH, EXT_HEIGHT = 16, 32;
  local EXT_REAL_WIDTH = 12;

  --[[
    Draws a composed bar by start, middle and end
    @param {number} x
    @param {number} y
    @param {number} w
    @param {number} h
    @param {number} start
    @param {number} body
    @param {number} end
    @param {number} v
    @param {number} cut
  ]]
  local function ComposeBar(x, y, w, h, colour, start, body, endi, v, off)
    v = v or 1;
    v = math.Clamp(v, 0, 1); -- Make sure it doesn't go out of bounds

    local width = math.Round(w * v);

    -- Draw the start of the bar
    local sW = math.Clamp(width, 0, EXT_REAL_WIDTH);

    -- If cut is false, preserve extreme
    --[[surface.SetTexture(start);
    surface.DrawTexturedRectUV(x, y, sW, h, 0, 0, sW/EXT_WIDTH, 1);]]
    HOLOHUD:DrawTextureUV(start, x, y, sW, h, 0, 0, sW/EXT_WIDTH, 1, colour, not off);

    -- Draw the middle of the bar
    local bodyWidth = w - (BODY_WIDTH - BODY_REAL_WIDTH);
    local bW = math.Clamp(width - EXT_REAL_WIDTH, 0, bodyWidth);
    --[[surface.SetDrawColor(colour);
    surface.SetTexture(body);
    surface.DrawTexturedRectUV(x + EXT_REAL_WIDTH, y, bW, h, 0, 0, math.Clamp(bW/w, 0, BODY_REAL_WIDTH/BODY_WIDTH), 1);
    ]]
    HOLOHUD:DrawTextureUV(body, x + EXT_REAL_WIDTH, y, bW, h, 0, 0, math.Clamp(bW/w, 0, BODY_REAL_WIDTH/BODY_WIDTH), 1, colour, not off);

    -- Draw the end of the bar
    local eW = math.Clamp(width - bodyWidth - EXT_REAL_WIDTH, 0, EXT_REAL_WIDTH);
    local offset = bodyWidth + EXT_REAL_WIDTH;

    --[[surface.SetDrawColor(colour);
    surface.SetTexture(endi);
    surface.DrawTexturedRectUV(x + offset, y, eW, h, 0, 0, eW/EXT_REAL_WIDTH, 1);]]
    HOLOHUD:DrawTextureUV(endi, x + offset, y, eW, h, 0, 0, eW/EXT_REAL_WIDTH, 1, colour, not off);

  end

  --[[
    Draws a bar
    @param {number} x
    @param {number} y
    @param {number} w
    @param {number} h
    @param {Color} colour
    @param {number} value
    @param {boolean} outline
    @void
  ]]
  function HOLOHUD:DrawBar(x, y, w, h, colour, value, bright, outline)
    if (outline == nil) then outline = false; end
    colour = colour or Color(255, 255, 255);

    x = x - 7;
    y = y - 10;

    -- Background
    ComposeBar(x, y, w, h, Color(255, 255, 255, 12 * HOLOHUD:GetOffOpacity()), BACKGROUND_START, BACKGROUND_BODY, BACKGROUND_END, nil, true);

    -- Outline
    if (outline) then
      local add = 50 * (1-bright)
      ComposeBar(x, y, w, h, Color(colour.r + add, colour.g + add, colour.b + add, (50 * bright) + 50), OUTLINE_START, OUTLINE_BODY, OUTLINE_END);
    else
      ComposeBar(x, y, w, h, Color(colour.r, colour.g, colour.b, 50), OUTLINE_START, OUTLINE_BODY, OUTLINE_END, value);
    end

    -- Foreground
    ComposeBar(x, y, w, h, colour, FOREGROUND_START, FOREGROUND_BODY, FOREGROUND_END, value);

    -- Bright
    ComposeBar(x, y, w, h, Color(colour.r, colour.g, colour.b, (30 * bright) + 10), BRIGHT_START, BRIGHT_BODY, BRIGHT_END, value);

    -- Gradient
    ComposeBar(x, y, w, h, Color(255, 255, 255, 8), GRADIENT_START, GRADIENT_BODY, GRADIENT_END, value);

  end

end
