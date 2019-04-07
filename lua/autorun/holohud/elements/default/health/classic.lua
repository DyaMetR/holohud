--[[------------------------------------------------------------------
  HEALTH AND ARMOUR INDICATORS
  Classic FPS layout
]]--------------------------------------------------------------------

-- Namespace
local HEALTH = HOLOHUD.ELEMENTS.HEALTH;

-- Panels and highlights
local PANEL_NAME = HEALTH.PANELS.DEFAULT;
local DEFAULT, ARMOUR = HEALTH.HIGHLIGHT.HEALTH, HEALTH.HIGHLIGHT.ARMOUR;

-- Parameters
local FONT = "holohud_main_cds";
local HEALTH_PANEL_OFFSET = 20;
local HEALTH_PANEL_W, HEALTH_PANEL_H = 200, 50;
local CROSS_TEXTURE, CROSS_TEXTURE_BRIGHT = surface.GetTextureID("holohud/cross"), surface.GetTextureID("holohud/crossb");
local CROSS_W, SUIT_W = 32, 32;
local MARGIN = 6;

--[[
  Draws the indicators
  @param {number} x
  @param {number} y
  @param {number} w
  @param {number} h
  @param {number} health
  @param {number} armour
]]
local apLerp = 0;
local function DrawIndicators(x, y, w, h, health, armour, hideArmour)
  local healthWidth = HOLOHUD:GetNumberSize(3, FONT) + CROSS_W - 5;

  local hColour, hBright = HEALTH:GetHealthColour(), HOLOHUD:GetHighlight(DEFAULT);
  local aColour, aBright = HEALTH:GetArmourColour(), HOLOHUD:GetHighlight(ARMOUR);

  -- Health
  HOLOHUD:DrawBrightTexture(CROSS_TEXTURE, CROSS_TEXTURE_BRIGHT, x + 7, y + 10, CROSS_W, CROSS_W, hColour, hBright, nil, true);
  HOLOHUD:DrawNumber(x + CROSS_W + MARGIN + 1, y + (h * 0.5), math.Clamp(health, 0, health), hColour, nil, hBright, FONT);

  -- Armour
  if (not hideArmour or armour > 0) then
    apLerp = Lerp(FrameTime() * 4, apLerp, armour);
    HOLOHUD:DrawSilhouette(x + healthWidth + MARGIN + 5, y + 5, aColour, apLerp * 0.01, aBright);
    HOLOHUD:DrawNumber(x + SUIT_W + healthWidth + MARGIN, y + (h * 0.5), armour, aColour, nil, aBright, FONT, armour <= 0);
  end
end

--[[
  Draws the panel
  @param {number} health
  @param {number} armour
  @param {number} width
  @param {number} height
  @void
]]
function HOLOHUD.ELEMENTS.HEALTH:ClassicPanel(health, armour, hideArmour)
  -- Hide armour if the configuration tells so
  local displayArmour = 1;
  if (hideArmour and armour <= 0) then displayArmour = 0; end

  -- Calculate panel size
  local armourWidth = SUIT_W + HOLOHUD:GetNumberSize(3, FONT) - 4;
  local width = HOLOHUD:GetNumberSize(3, FONT) + CROSS_W + 16 + (armourWidth * displayArmour);

  -- Draw
  HOLOHUD:DrawFragment(HEALTH_PANEL_OFFSET, ScrH() - (HEALTH_PANEL_OFFSET + HEALTH_PANEL_H), width, HEALTH_PANEL_H, DrawIndicators, PANEL_NAME, health, armour, hideArmour);

  return width, HEALTH_PANEL_H;
end
