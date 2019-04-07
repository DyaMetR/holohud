--[[------------------------------------------------------------------
  TEXTURE CALLS
  Draw textured rects with an applicable CA effect
]]--------------------------------------------------------------------

if CLIENT then

  -- Parameters
  local OFF_COLOUR = Color(255, 255, 255, 12);
  local ALPHA = 200;
  local MIN_BRIGHT, MAX_BRIGHT = 0.36, 0.8;

  --[[
    Draws a textured rect
    @param {number} texture
    @param {number} x
    @param {number} y
    @param {number} w
    @param {number} h
    @param {Color|nil} colour
    @param {boolean} draw chromatic aberration
    @void
  ]]
  function HOLOHUD:DrawTexture(texture, x, y, w, h, colour, draw_ca)
    colour = colour or Color(255, 255, 255, ALPHA);
    local sep = HOLOHUD:GetChromaticAberrationSeparation();

    surface.SetTexture(texture);

    -- Chromatic aberration
    if (draw_ca and HOLOHUD:IsChromaticAberrationEnabled()) then
      surface.SetDrawColor(Color(colour.r, 0, 0, colour.a));
      surface.DrawTexturedRect(x + sep, y + sep, w, h);

      surface.SetDrawColor(Color(0, colour.g, 0, colour.a));
      surface.DrawTexturedRect(x, y, w, h);

      surface.SetDrawColor(Color(0, 0, colour.b, colour.a));
      surface.DrawTexturedRect(x - sep, y - sep, w, h);
    else
      surface.SetDrawColor(Color(colour.r, colour.g, colour.b, colour.a));
      surface.DrawTexturedRect(x, y, w, h);
    end
  end

  --[[
    Draws a textured rect scissored
    @param {number} texture
    @param {number} x
    @param {number} y
    @param {number} w
    @param {number} h
    @param {number} u start
    @param {number} v start
    @param {number} u end
    @param {number} v end
    @param {Color|nil} colour
    @param {boolean} draw chromatic aberration
    @void
  ]]
  function HOLOHUD:DrawTextureUV(texture, x, y, w, h, u1, v1, u2, v2, colour, draw_ca)
    colour = colour or Color(255, 255, 255);
    local sep = HOLOHUD:GetChromaticAberrationSeparation()

    surface.SetTexture(texture);

    -- Chromatic aberration
    if (draw_ca and HOLOHUD:IsChromaticAberrationEnabled()) then
      surface.SetDrawColor(Color(colour.r, 0, 0, colour.a));
      surface.DrawTexturedRectUV(x + sep, y + sep, w, h, u1, v1, u2, v2);

      surface.SetDrawColor(Color(0, colour.g, 0, colour.a));
      surface.DrawTexturedRectUV(x, y, w, h, u1, v1, u2, v2);

      surface.SetDrawColor(Color(0, 0, colour.b, colour.a));
      surface.DrawTexturedRectUV(x - sep, y - sep, w, h, u1, v1, u2, v2);
    else
      surface.SetDrawColor(Color(colour.r, colour.g, colour.b, colour.a));
      surface.DrawTexturedRectUV(x, y, w, h, u1, v1, u2, v2);
    end
  end

  --[[
    Draws a rotated textured rect
    @param {number} texture
    @param {number} x
    @param {number} y
    @param {number} w
    @param {number} h
    @param {Color|nil} colour
    @param {number|nil} rotation
    @param {boolean} draw chromatic aberration
    @void
  ]]
  function HOLOHUD:DrawTextureRotated(texture, x, y, w, h, colour, rot, draw_ca)
    colour = colour or Color(255, 255, 255);
    local sep = HOLOHUD:GetChromaticAberrationSeparation();

    surface.SetTexture(texture);

    -- Chromatic aberration
    if (draw_ca and HOLOHUD:IsChromaticAberrationEnabled()) then
      surface.SetDrawColor(Color(colour.r, 0, 0, colour.a));
      surface.DrawTexturedRectRotated(x + sep, y + sep, w, h, rot);

      surface.SetDrawColor(Color(0, colour.g, 0, colour.a));
      surface.DrawTexturedRectRotated(x, y, w, h, rot);

      surface.SetDrawColor(Color(0, 0, colour.b, colour.a));
      surface.DrawTexturedRectRotated(x - sep, y - sep, w, h, rot);
    else
      surface.SetDrawColor(Color(colour.r, colour.g, colour.b, colour.a));
      surface.DrawTexturedRectRotated(x, y, w, h, rot);
    end
  end

  --[[
    Draws a texture with their bright component that can be turned off
    @param {number} texture
    @param {number} bright texture
    @param {number} x
    @param {number} y
    @param {number} w
    @param {number} h
    @param {Color} colour
    @param {number} bright
    @param {boolean} is off
    @param {boolean} enable chromatic aberration
    @param {boolean} should always be on
    @void
  ]]
  function HOLOHUD:DrawBrightTexture(texture, brightTexture, x, y, w, h, colour, bright, off, draw_ca, force_on)
    if (off and not force_on) then
      HOLOHUD:DrawTexture(texture, x, y, w, h, OFF_COLOUR, false, true);
    else
      HOLOHUD:DrawTexture(brightTexture, x, y, w, h, Color(colour.r, colour.g, colour.b, colour.a * MIN_BRIGHT), false);
      HOLOHUD:DrawTexture(texture, x, y, w, h, colour, draw_ca);
      HOLOHUD:DrawTexture(brightTexture, x, y, w, h, Color(colour.r, colour.g, colour.b, colour.a * MAX_BRIGHT * bright), false);
    end
  end

  --[[
    Draws a scissor texture with their bright component that can be turned off
    @param {number} texture
    @param {number} bright texture
    @param {number} x
    @param {number} y
    @param {number} w
    @param {number} h
    @param {number} u1
    @param {number} v1
    @param {number} u2
    @param {number} v2
    @param {Color} colour
    @param {number} bright
    @param {boolean} is off
    @param {boolean} enable chromatic aberration
    @param {boolean} should always be on
    @void
  ]]
  function HOLOHUD:DrawBrightTextureUV(texture, brightTexture, x, y, w, h, u1, v1, u2, v2, colour, bright, off, draw_ca, force_on)
    bright = bright or 0;
    if (off and not force_on) then
      HOLOHUD:DrawTexture(texture, x, y, w, h, OFF_COLOUR, false, true);
    else
      HOLOHUD:DrawTextureUV(brightTexture, x, y, w, h, u1, v1, u2, v2, Color(colour.r, colour.g, colour.b, colour.a * MIN_BRIGHT), false);
      HOLOHUD:DrawTextureUV(texture, x, y, w, h, u1, v1, u2, v2, colour, draw_ca);
      HOLOHUD:DrawTextureUV(brightTexture, x, y, w, h, u1, v1, u2, v2, Color(colour.r, colour.g, colour.b, colour.a * MAX_BRIGHT * bright), false);
    end
  end

  --[[
    Draws a rotated texture with their bright component that can be turned off
    @param {number} texture
    @param {number} bright texture
    @param {number} x
    @param {number} y
    @param {number} w
    @param {number} h
    @param {number} rotation
    @param {Color} colour
    @param {number} bright
    @param {boolean} is off
    @param {boolean} enable chromatic aberration
    @param {boolean} should always be on
    @void
  ]]
  function HOLOHUD:DrawBrightTextureRotated(texture, brightTexture, x, y, w, h, rot, colour, bright, off, draw_ca, force_on)
    if (off and not force_on) then
      HOLOHUD:DrawTextureRotated(texture, x, y, w, h, rot, OFF_COLOUR, false, true);
    else
      HOLOHUD:DrawTextureRotated(brightTexture, x, y, w, h, rot, Color(colour.r, colour.g, colour.b, colour.a * MIN_BRIGHT), false);
      HOLOHUD:DrawTextureRotated(texture, x, y, w, h, rot, colour, draw_ca);
      HOLOHUD:DrawTextureRotated(brightTexture, x, y, w, h, rot, Color(colour.r, colour.g, colour.b, colour.a * MAX_BRIGHT * bright), false);
    end
  end

  --[[
    Draws a texture as a progress bar
    @param {number} x
    @param {number} y
    @param {number} texture id
    @param {number} bright texture id
    @param {number} w
    @param {number} h
    @param {number} real height
    @param {number} value
    @param {number} bright
    @param {Color} colour
    @param {number} align
    @param {boolean} is off
    @param {boolean} should draw chromatic aberration
    @void
  ]]
  function HOLOHUD:DrawProgressTexture(x, y, texture, brightTexture, w, h, v, value, bright, colour, align, off, draw_ca)
    value = math.Clamp(value, 0, 1);
    local width, height = math.Round(v * value), h;
    local u1, v1, u2, v2 = 0, 0, width/w, 1;
    local u, r = 0, 0;

    -- Alignment
    if (align == TEXT_ALIGN_RIGHT) then
      width = math.Round(v * value) + (w - v);
      u1 = 1 - (width/w);
      u2 = 1;
      u = w - width;
    elseif (align == TEXT_ALIGN_TOP) then
      u2 = 1;
      width = w;
      height = math.Round(v * value);
      v2 = height/h;
    elseif (align == TEXT_ALIGN_BOTTOM) then
      u2 = 1;
      width = w;
      height = math.Round(v * value) + (h - v);
      v1 = 1 - (height/h);
      r = h - height;
    end

    -- Draw
    HOLOHUD:DrawTexture(texture, x, y, w, h, OFF_COLOUR, false);

    if (not off) then
      HOLOHUD:DrawBrightTextureUV(texture, brightTexture, x + u, y + r, width, height, u1, v1, u2, v2, colour, bright, nil, draw_ca);
    end
  end

end
