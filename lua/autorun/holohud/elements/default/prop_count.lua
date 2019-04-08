--[[------------------------------------------------------------------
  PROP COUNT
  How many props have you spawned
]]--------------------------------------------------------------------

if CLIENT then

  -- Parameters
  local PANEL_NAME = "prop_count";
  local BRIGHT = 0.36;
  local TEXTURE, TEXTURE_BRIGHT = surface.GetTextureID("holohud/props"), surface.GetTextureID("holohud/propsb");
  local COLOUR, CRIT_COLOUR = Color(255, 255, 255), Color(255, 118, 80);
  local SCREEN_OFFSET, HEIGHT, MARGIN = 20, 43, 48;
  local TIME = 4;
  local KEY = IN_SCORE;

  -- Highlight and panel
  HOLOHUD:AddHighlight(PANEL_NAME);
  HOLOHUD:AddFlashPanel(PANEL_NAME);

  -- Variables
  local lastProps = 0;
  local time = 0;
  local colourMul = 0;
  local blink = 0;
  local lerp = 0;

  --[[
    Animates the panel
    @param {number} prop amount
    @param {number} maximum prop amount
    @void
  ]]
  local function Animate(props, maxProps)
    -- Change colour if approaching maximum amount
    if (props/maxProps > 0.75) then
			colourMul = Lerp(FrameTime() * 4, colourMul, 1 - math.Clamp(((props/maxProps) - 0.66) / 0.26, 0, 1));
    else
			colourMul = Lerp(FrameTime() * 8, colourMul, 1);
		end

    -- Blink if too near to maximum
    if (props/maxProps >= 0.9 and blink < CurTime()) then
      HOLOHUD:TriggerHighlight(PANEL_NAME);
      blink = CurTime() + 0.76;
    end

    -- Display if props are spawned/removed
    if (props ~= lastProps and not game.SinglePlayer()) then
      HOLOHUD:TriggerHighlight(PANEL_NAME);
      time = CurTime() + TIME;
      lastProps = props;
    end

    -- Display if scoreboard is shown
    if (LocalPlayer():KeyDown(KEY)) then
      time = CurTime() + TIME;
    end

    -- Lerp
    lerp = Lerp(FrameTime() * 4, lerp, props);
  end

  --[[
    How many props are spawned by the player
    @param {number} x
    @param {number} y
    @param {number} w
    @param {number} h
    @param {boolean} is off
    @param {number} current prop count
    @param {number} maximum prop count
    @param {Color} colour
    @param {Color} high prop count colour
    @void
  ]]
  local function DrawProps(x, y, w, h, off, props, maxProps, colour, critColour)
    local bright = HOLOHUD:GetHighlight(PANEL_NAME);
    local colour = HOLOHUD:IntersectColour(colour, critColour, colourMul);
    HOLOHUD:DrawNumber(x + 38, y + (h * 0.5), props, colour, "000", bright, "holohud_med_sm", game.SinglePlayer());
    HOLOHUD:DrawProgressTexture(x + 5, y + 5, TEXTURE, TEXTURE_BRIGHT, 32, 32, 32, lerp/maxProps, bright, colour, TEXT_ALIGN_BOTTOM, game.SinglePlayer(), true);
  end

  --[[
    Animates and draws the player count panel
    @param {function} config
    @void
  ]]
  local function DrawPanel(config)
    if (LocalPlayer().GetCount == nil) then return; end
    local props = LocalPlayer():GetCount("props");
    local maxProps = GetConVar("sbox_maxprops"):GetInt();
    Animate(props, maxProps);

    -- Get offset
    local x = 0;
    if (HOLOHUD:IsPanelActive("player_count")) then
      x = HOLOHUD.ELEMENTS:GetElementSize("player_count") + 5;
    end

    -- Get size
    local w = HOLOHUD:GetNumberSize(3, "holohud_med_sm") + MARGIN;

    -- Draw
    HOLOHUD:SetPanelActive(PANEL_NAME, time > CurTime() or config("always") or (props/maxProps) >= 0.9);
    HOLOHUD:DrawFragmentAlignSimple(SCREEN_OFFSET + x, SCREEN_OFFSET, w, HEIGHT, DrawProps, PANEL_NAME, TEXT_ALIGN_TOP, game.SinglePlayer(), props, maxProps, config("colour"), config("crit_colour"));

    return w, HEIGHT;
  end

  -- Add element
  HOLOHUD.ELEMENTS:AddElement(PANEL_NAME,
    "Prop count",
    "How many props you've spawned",
    nil,
    {
      always = { name = "Always displayed", value = false },
      colour = { name = "Colour", value = COLOUR },
      crit_colour = { name = "Limit reach colour", desc = "Colour when nearing the prop limit", value = CRIT_COLOUR }
    },
    DrawPanel
  );

end
