--[[------------------------------------------------------------------
  HEART RATE MONITOR
  A heart rate display to indicate health
]]--------------------------------------------------------------------

if CLIENT then

  -- Textures
  local FILE_W, FILE_H = 128, 512;
  local PULSE_TEXTURE = {{w = 80}, {w = 83}, {w = 87}, {w = 90}, {w = 90}, {w = 97}, {w = 80}};
  local PULSE_WARN_TEXTURE = {{w = 72}, {w = 80}, {w = 83}, {w = 85}, {w = 87}, {w = 89}, {w = 83}};
  local CONTAINER_WIDTH, PULSE_HEIGHT = 100, 64;
  local BRACKET_TEXTURE, BRACKET_BRIGHT_TEXTURE = surface.GetTextureID("holohud/pulse/bracket"), surface.GetTextureID("holohud/pulse/bracket_bright");
  local SCROLL_SPEED, DAMAGE_SPEED = 0.013, -0.009;
  local MINIMUM_DAMAGE = 0.1;

  -- Initialize textures
  for i=0, 6 do
    PULSE_TEXTURE[i + 1].texture = surface.GetTextureID("holohud/pulse/pulse" .. i);
    PULSE_WARN_TEXTURE[i + 1].texture = surface.GetTextureID("holohud/pulse/pulse" .. i .. "b");
  end

  -- Variables
  local pulse = {};
  local scTick, dmTick, dmTime = 0, 0, 0;
  local lastHp, damage = 1, 0;

  --[[
    Adds a pulse icon to the queue
    @param {number} i
    @void
  ]]
  local function AddPulse(i, warn)
    if (warn == nil) then warn = false; end
    table.insert(pulse, {pos = 0, i = i, warn = warn, gen = false});
  end

  --[[
    Determines the pulse icon to use based on value
    @param {number} value
    @return {number} pulse
  ]]
  local function GetPulse(value)
    if (value > 0.75) then
      return 1;
    elseif (value > 0.66 and value <= 0.78) then
      return 2;
    elseif (value > 0.33 and value <= 0.66) then
      return 3;
    elseif (value > 0.2 and value <= 0.33) then
      return 4;
    elseif (value > 0.1 and value <= 0.2) then
      return 5;
    elseif (value > 0 and value <= 0.1) then
      return 6;
    else
      return 7;
    end
  end

  --[[
    Animates the heart rate
    @void
  ]]
  local function Animate()
    local alive, hp = LocalPlayer():Alive(), math.Clamp(LocalPlayer():Health() * 0.01, 0, LocalPlayer():Health() * 0.01);

    -- Damage animation
    if (lastHp ~= hp) then
      if (lastHp > hp) then
        damage = math.Clamp(damage + (lastHp - hp) * 3, 0, 1);
        if (dmTime < CurTime() + ((lastHp - hp) * 15)) then dmTime = CurTime() + ((lastHp - hp) * 10); end
      else
        if (lastHp <= 0) then dmTime = CurTime(); damage = 0; end
      end
      lastHp = hp;
    end

    if (dmTime < CurTime() and dmTick < CurTime()) then
      damage = math.Clamp(damage - 0.01, 0, 1);
      local mul = 1;
      if (LocalPlayer():IsSprinting()) then mul = 2; end
      dmTick = CurTime() + 0.066 * mul;
    end

    -- If monitor is empty, start up the sequence
    if (table.IsEmpty(pulse)) then
      AddPulse(GetPulse(hp), damage > MINIMUM_DAMAGE);
    end

    -- Pulse sequence
    if (scTick < CurTime()) then
      for i, cur in pairs(pulse) do
        -- Select texture
        local texture = PULSE_TEXTURE;
        if (pulse[i].warn) then texture = PULSE_WARN_TEXTURE; end

        -- Scroll
        if (cur.pos >= texture[cur.i].w and not cur.gen) then
          AddPulse(GetPulse(hp), (damage > MINIMUM_DAMAGE and alive) or (dmTime > CurTime()));
          pulse[i].gen = true;
        elseif (cur.pos >= texture[cur.i].w + CONTAINER_WIDTH) then
          pulse[i + 1].pos = pulse[i + 1].pos + 1;
          table.remove(pulse, i);
        end
        cur.pos = cur.pos + 1;
      end
      scTick = CurTime() + SCROLL_SPEED + (DAMAGE_SPEED * damage);
    end
  end

	--[[
		Draws a bracket
		@param {number} x
		@param {number} y
		@param {boolean|nil} inverse
		@void
	]]
	function HOLOHUD:DrawBracket(x, y, inverse, colour, bright)
		bright = bright or 0;
		if (inverse == nil) then inverse = false; end
		local r, g, b, a = colour.r + 20, colour.g + 20, colour.b + 20, colour.a;
		local u, v, w, h = 0, 0, 1, 1;
		if (inverse) then u, v, w, h = 1, 1, 0, 0; end

		-- Bracket
		--[[surface.SetTexture(BRACKET_TEXTURE);
		surface.SetDrawColor(Color(r, g, b, a * 0.76));
		surface.DrawTexturedRectUV(x, y, 34, 56, u, v, w, h);]]
    HOLOHUD:DrawTextureUV(BRACKET_TEXTURE, x, y, 34, 56, u, v, w, h, Color(r, g, b, a * 0.76), true)

		-- Bright
		surface.SetTexture(BRACKET_BRIGHT_TEXTURE);
		surface.SetDrawColor(Color(r, g, b, a * (0.09 + (0.2 * bright))));
		surface.DrawTexturedRectUV(x, y, 34, 56, u, v, w, h);
	end

  --[[
    Draws a pulse from the queue
    @param {number} i
    @param {number} x
    @param {number} y
    @void
  ]]
  local function DrawPulse(i, x, y, colour)
    local r, g, b, a = colour.r, colour.g, colour.b, colour.a;
    local texture = PULSE_TEXTURE[pulse[i].i];
    if (pulse[i].warn) then texture = PULSE_WARN_TEXTURE[pulse[i].i]; end

    -- Get sizes
    local u, v, w = 0, texture.w, texture.w;
    local diff = pulse[i].pos - CONTAINER_WIDTH;
    if (diff >= 0) then
      x = x + diff;
      w = texture.w - diff;
      u = texture.w - w;
    elseif (pulse[i].pos < texture.w) then
      w = pulse[i].pos;
      v = w;
    end

    -- Draw texture
    --[[surface.SetTexture(texture.texture);
    surface.SetDrawColor(Color(r, g, b, a));
    surface.DrawTexturedRectUV(x, y, w, PULSE_HEIGHT, u / FILE_W, 0, v / FILE_W, 1);]]
    HOLOHUD:DrawTextureUV(texture.texture, x, y, w, PULSE_HEIGHT, u / FILE_W, 0, v / FILE_W, 1, Color(r, g, b, a), true);
  end

  --[[
    Draws the heartrate monitor
    @param {number} x
    @param {number} y
    @param {Color} colour
    @param {string} bright
    @void
  ]]
  function HOLOHUD:DrawHeartMonitor(x, y, colour, bright)
    colour = colour or Color(255, 255, 255, 100);
    bright = bright or 0;

    -- Brackets
    HOLOHUD:DrawBracket(x, y, false, colour, bright);
		HOLOHUD:DrawBracket(x + 77, y, true, colour, bright);

    -- Pulse
    Animate();
    for i, cur in pairs(pulse) do
      DrawPulse(i, x + 5 + CONTAINER_WIDTH - cur.pos, y + 5, colour);
    end
  end

end
