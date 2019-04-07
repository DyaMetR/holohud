--[[------------------------------------------------------------------
  PANEL
  Blurred panel component
]]--------------------------------------------------------------------

if CLIENT then

    -- Parameters
    local BACKGROUND_DIST = 1.1;
    local FOREGROUND_DIST = 1.33;

    -- Textures
    local blur = Material("pp/blurscreen");
    local center = surface.GetTextureID("gui/center_gradient");

    --[[
      Draws a rectangle that partially blurs the screen
      @param {number} x
      @param {number} y
      @param {number} w
      @param {number} h
      @param {number|nil} blur quality
      @void
    ]]
    function HOLOHUD:DrawBlurRect(x, y, w, h, quality)
      if (HOLOHUD:GetBackgroundBlur() <= 0) then return; end
      quality = quality or 5;
      quality = quality * HOLOHUD:GetBlurQuality();

      surface.SetDrawColor(255,255,255,255 * HOLOHUD:GetBackgroundBlur()); -- Apply configuration
      surface.SetMaterial(blur);
      for i = 1, math.Clamp(math.ceil(quality), 1, 10) do
        local mul = math.Clamp(5/quality, 1, 3);
        blur:SetFloat("$blur", ((i * mul)/3) * 2);
        blur:Recompute();

        render.UpdateScreenEffectTexture();

        local X, Y = 0, 0;
        render.SetScissorRect(x, y, x + w, y + h, true);
        surface.DrawTexturedRect(X * -1, Y * -1, ScrW(), ScrH());
        render.SetScissorRect(0, 0, 0, 0, false);
      end
    end

    --[[
      Draws a rectangle, base for the panels
      @param {number} x
      @param {number} y
      @param {number} w
      @param {number} h
      @param {Color|nil} colour
      @param {number|nil} background alpha
      @param {number|nil} foreground alpha
      @void
    ]]
    function HOLOHUD:DrawRect(x, y, w, h, colour, alpha)
      alpha = alpha or 0.1725;
      colour = colour or HOLOHUD:GetBackgroundColour();
      alpha = alpha * HOLOHUD:GetBackgroundOpacity(); -- Apply configuration
      draw.RoundedBox(0, x, y, w, h, Color(colour.r, colour.g, colour.b, 255 * alpha));
      surface.SetDrawColor(Color(colour.r, colour.g, colour.b, 255 * alpha * 1.76 * math.Clamp(w / 512, 0.12, 0.66)));
      surface.SetTexture(center);
      surface.DrawTexturedRect(x, y - 1, w, h + 2);
    end

    --[[
      Draws a panel with blur and background
      @param {number} x
      @param {number} y
      @param {number} w
      @param {number} h
      @param {Color|nil} colour
      @param {number|nil} blur panel quality
      @void
    ]]
    function HOLOHUD:DrawPanel(x, y, w, h, colour, alpha, blurQuality)
      blurQuality = blurQuality or 5;
      local u, v = self:GetSway();
      local offset = (1 + (BACKGROUND_DIST - 1));

      if (blurQuality >= 0) then HOLOHUD:DrawBlurRect(x + u, y + v, w, h, blurQuality); end
      HOLOHUD:DrawRect(x + u * offset, y + v * offset, w, h, colour, alpha);
    end
end
