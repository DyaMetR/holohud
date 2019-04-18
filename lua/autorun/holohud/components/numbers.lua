--[[------------------------------------------------------------------
  NUMBERS
  Standard number displaying methods
]]--------------------------------------------------------------------


if CLIENT then

  -- Parameters
  local DEFAULT_FONT = "holohud_main";
  local MIN_BRIGHT = 0.44;
  local ACTIVE_BRIGHT = 0.66;
  local ALPHA = 200;

  --[[
    Draws a number with idle and active bright plus a background
    @param {number} x
    @param {number} y
    @param {Color|nil} colour
    @param {string|nil} zeros
    @param {number|nil} bright
    @param {string|nil} font
    @param {boolean|nil} is off (background only)
    @param {number|nil} horizontal alignment
    @param {number|nil} vertical alignment
    @param {boolean|nil} draw chromatic aberration
    @void
  ]]
  function HOLOHUD:DrawNumber(x, y, number, colour, zeros, bright, font, off, align, vertical_align)
      font = font or DEFAULT_FONT;
      bright = bright or 0;
      colour = colour or Color(255, 255, 255);
      align = align or TEXT_ALIGN_LEFT;
      vertical_align = vertical_align or TEXT_ALIGN_CENTER;

      -- More digits than zeros
      if (not zeros) then
        if (math.floor(math.log10(number)) + 1 > 3 and type(number) == "number") then
          zeros = "";
          local digits = math.max(math.floor(math.log10(number)) + 1, 3);
          for i=1, digits do
            zeros = zeros .. "0";
          end
        else
          zeros = "000";
        end
      end

      -- Font offset
      local u, v = HOLOHUD.CONFIG.FONTS:GetFontOffset(font);
      x = x + u; y = y + v;

      -- Get text size
      surface.SetFont(font);
      local offset = math.ceil(surface.GetTextSize(zeros));
      if (align == TEXT_ALIGN_RIGHT) then
        offset = 0;
      elseif (align == TEXT_ALIGN_CENTER) then
        offset = offset * 0.5;
      end
      align = TEXT_ALIGN_RIGHT;

      -- Draw the number
      draw.SimpleText(zeros, font, x + offset, y, Color(255, 255, 255, 12 * HOLOHUD:GetOffOpacity()), align, vertical_align);
      if (not off) then
          draw.SimpleText(number, font.."_bright", x + offset, y, Color(colour.r, colour.g, colour.b, ALPHA * MIN_BRIGHT), align, vertical_align);

          -- Chromatic aberration
          if (HOLOHUD:IsChromaticAberrationEnabled()) then
            local sep = HOLOHUD:GetChromaticAberrationSeparation();
            draw.SimpleText(number, font, x + offset + sep, y + sep, Color(colour.r, 0, 0, ALPHA), align, vertical_align);
            draw.SimpleText(number, font, x + offset, y, Color(0, colour.g, 0, ALPHA), align, vertical_align);
            draw.SimpleText(number, font, x + offset - sep, y - sep, Color(0, 0, colour.b, ALPHA), align, vertical_align);
          else
            draw.SimpleText(number, font, x + offset, y, Color(colour.r, colour.g, colour.b, ALPHA), align, vertical_align);
          end

          -- Active bright
          draw.SimpleText(number, font.."_active", x + offset, y, Color(colour.r, colour.g, colour.b, ALPHA * bright * ACTIVE_BRIGHT), align, vertical_align);
      end
  end

  --[[
    Returns the size of a number set
    @param {string|number} text (or digits if number)
    @param {string|nil} font
    @return {number} size
  ]]
  function HOLOHUD:GetNumberSize(text, font)
    text = text or "000";
    font = font or DEFAULT_FONT;

    surface.SetFont(font);
    if (type(text) == "number") then
      local w, h = surface.GetTextSize("0");
      return w * text, h;
    else
      return surface.GetTextSize(text);
    end
  end

  --[[
    Draws a simple text
    @param {number} x
    @param {number} y
    @param {string} text
    @param {string|nil} font
    @param {Color|nil} colour
    @param {number|nil} alignment
    @param {number|nil} vertical alignment
    @param {boolean|nil} has no bright
    @param {number|nil} force alpha
    @void
  ]]
  function HOLOHUD:DrawText(x, y, text, font, colour, bright, align, vertical_align, off, alpha)
    off = off or false;
    vertical_align = vertical_align or TEXT_ALIGN_TOP;
    bright = bright or 0;
    font = font or DEFAULT_FONT;
    if (off and alpha == nil) then alpha = 12; end
    alpha = alpha or ALPHA;
    colour = colour or Color(255, 255, 255, alpha);

    -- Font offset
    local u, v = HOLOHUD.CONFIG.FONTS:GetFontOffset(font);
    x = x + u; y = y + v;

    -- Alignment
    local offset = 0;

    if (vertical_align ~= TEXT_ALIGN_TOP) then
      surface.SetFont(font);
      local w, h = surface.GetTextSize(text);
      offset = h;
      if (vertical_align == TEXT_ALIGN_CENTER) then offset = offset * 0.5; end
    end

    if (bright >= 0 and not off) then draw.DrawText(text, font.."_bright", x + u, y + v - offset, Color(colour.r, colour.g, colour.b, alpha * MIN_BRIGHT), align); end

    if (not off and HOLOHUD:IsChromaticAberrationEnabled()) then
      local sep = HOLOHUD:GetChromaticAberrationSeparation();
      draw.DrawText(text, font, x + u + sep, y + v - offset + sep, Color(colour.r, 0, 0, alpha), align);
      draw.DrawText(text, font, x + u, y + v - offset, Color(0, colour.g, 0, alpha), align);
      draw.DrawText(text, font, x + u - sep, y + v - offset - sep, Color(0, 0, colour.b, alpha), align);
    else
      draw.DrawText(text, font, x + u, y + v - offset, Color(colour.r, colour.g, colour.b, alpha), align);
    end
    if (bright > 0 and not off) then draw.DrawText(text, font.."_active", x + u, y + v - offset, Color(colour.r, colour.g, colour.b, alpha * ACTIVE_BRIGHT * bright), align); end
  end

  --[[
    Returns a text's size
    @param {string} text
    @param {string} font
    @return {number} width
    @return {number} height
  ]]
  function HOLOHUD:GetTextSize(text, font)
    if (text == nil) then return 0, 0; end
    font = font or "holohud_main";
    surface.SetFont(font);
    return surface.GetTextSize(text);
  end

end
