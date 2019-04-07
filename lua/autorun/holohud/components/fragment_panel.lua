--[[------------------------------------------------------------------
  ELEMENT PANEL
  Full element panel featuring background, foreground and flash
]]--------------------------------------------------------------------

if CLIENT then

    local FOREGROUND_DIST = 1.33;

    --[[
      Draws a panel with a draw call on top and a flash with an alignment
      @param {number} x
      @param {number} y
      @param {number} w
      @param {number} h
      @param {function} func
      @param {string} flash
      @param {Color} colour
      @param {number} blurQuality
      @param {any} additional parameter sent to the panel
      @void
    ]]
    function HOLOHUD:DrawFragmentAlign(x, y, w, h, func, flash, align, colour, alpha, blurQuality, ...)
      local data = self:GetFlashPanel(flash);
      if (data == nil) then return; end

      if (data.anim >= 1) then
        HOLOHUD:DrawFragmentPanel(x, y, w, h, func, colour, alpha, blurQuality, ...);
      end

      if (data.flash > 0) then
        HOLOHUD:DrawFlashPanel(flash, x, y, w, h, align);
      end
    end

    --[[
      Draws an aligned panel with default quality and colour values
      @param {number} x
      @param {number} y
      @param {number} w
      @param {number} h
      @param {function} func
      @param {string} flash
      @param {any} additional parameter sent to the panel
      @void
    ]]
    function HOLOHUD:DrawFragmentAlignSimple(x, y, w, h, func, flash, align, ...)
      HOLOHUD:DrawFragmentAlign(x, y, w, h, func, flash, align, nil, nil, nil, ...);
    end

    --[[
      Draws a panel with a draw call on top and a flash
      @param {number} x
      @param {number} y
      @param {number} w
      @param {number} h
      @param {function} func
      @param {string} flash
      @param {any} additional parameter sent to the panel
      @void
    ]]
    function HOLOHUD:DrawFragment(x, y, w, h, func, flash, ...)
      HOLOHUD:DrawFragmentAlign(x, y, w, h, func, flash, nil, nil, nil, nil, ...);
    end

    --[[
      Draws a panel with a draw call on top
      @param {number} x
      @param {number} y
      @param {number} w
      @param {number} h
      @param {function} func
      @param {Color|nil} colour
      @param {number|nil} background alpha
      @param {number|nil} blur quality
      @param {any} additional parameter sent to the panel
    ]]
    function HOLOHUD:DrawFragmentPanel(x, y, w, h, func, colour, alpha, blurQuality, ...)
      local u, v = self:GetSway();
      local offset = (1 + (FOREGROUND_DIST - 1));
      HOLOHUD:DrawPanel(x, y, w, h, colour, alpha, blurQuality);
      func(x + u * offset, y + v * offset, w, h, ...);
    end

end
