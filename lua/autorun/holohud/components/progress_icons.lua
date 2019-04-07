--[[------------------------------------------------------------------
  PROGRESS TEXTURES
  Textures that work as progress bars
]]--------------------------------------------------------------------

if CLIENT then

  -- Parameters
  local SUIT_TEXTURE, SUIT_BRIGHT_TEXTURE = surface.GetTextureID("holohud/armor"), surface.GetTextureID("holohud/armorb");
  local VERT_TEXTURE, VERT_BRIGHT_TEXTURE = surface.GetTextureID("holohud/armor_bar"), surface.GetTextureID("holohud/armor_barb");
  local HOR_TEXTURE, HOR_BRIGHT_TEXTURE = surface.GetTextureID("holohud/bar_horizontal"), surface.GetTextureID("holohud/bar_horizontalb");
  local KEVLAR_TEXTURE, KEVLAR_BRIGHT_TEXTURE = surface.GetTextureID("holohud/kevlar"), surface.GetTextureID("holohud/kevlarb");
  local SUIT_W, SUIT_H, SUIT_V = 32, 64, 42;
  local BAR_W, BAR_H, BAR_V = 16, 64, 49;
  local KEVLAR_W, KEVLAR_H, KEVLAR_V = 64, 64, 39;

  --[[
    Draws a vertical progress bar
    @param {number} x
    @param {number} y
    @param {Color} colour
    @param {number} value
    @param {number} bright
    @void
  ]]
  function HOLOHUD:DrawVerticalBar(x, y, colour, value, bright)
    HOLOHUD:DrawProgressTexture(x, y, VERT_TEXTURE, VERT_BRIGHT_TEXTURE, BAR_W, BAR_H, BAR_V, value, bright, colour, TEXT_ALIGN_BOTTOM, false, true);
  end

  --[[
    Draws a horizontal progress bar
    @param {number} x
    @param {number} y
    @param {Color} colour
    @param {number} value
    @param {number} bright
    @void
  ]]
  function HOLOHUD:DrawHorizontalBar(x, y, colour, value, bright)
    HOLOHUD:DrawProgressTexture(x, y, HOR_TEXTURE, HOR_BRIGHT_TEXTURE, BAR_H, BAR_W, BAR_V, value, bright, colour, TEXT_ALIGN_RIGHT, false, true);
  end

  --[[
    Draws a silhouette as a progress bar
    @param {number} x
    @param {number} y
    @param {Color} colour
    @param {number} value
    @param {number} bright
    @void
  ]]
  function HOLOHUD:DrawSilhouette(x, y, colour, value, bright)
    HOLOHUD:DrawProgressTexture(x, y, SUIT_TEXTURE, SUIT_BRIGHT_TEXTURE, SUIT_W, SUIT_H, SUIT_V, value, bright, colour, TEXT_ALIGN_BOTTOM, false, true);
  end

  --[[
    Draws a kevlar icon as a progress bar
    @param {number} x
    @param {number} y
    @param {Color} colour
    @param {number} value
    @param {number} bright
    @void
  ]]
  function HOLOHUD:DrawKevlar(x, y, colour, value, bright)
    HOLOHUD:DrawProgressTexture(x, y, KEVLAR_TEXTURE, KEVLAR_BRIGHT_TEXTURE, KEVLAR_W, KEVLAR_H, KEVLAR_V, value, bright, colour, TEXT_ALIGN_BOTTOM, false, true);
  end

end
