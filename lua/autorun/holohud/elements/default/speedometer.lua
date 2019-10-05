--[[------------------------------------------------------------------
  SPEED-O-METER
  Displays current vehicle speed
]]--------------------------------------------------------------------

local NET, RPM = "holohud_vehicle_param", "holohud_vehicle_rpm";

if CLIENT then

  -- Parameters
  local PANEL_NAME = "speedometer";
  local KPH_UNIT, MPH_UNIT, UPS_UNIT = "km/h", "MPH", "ups";
  local KPH, MPH = 1.6093, 0.056818181;
  local W, H = 17, 50;
  local SCREEN_OFFSET = 20;

  -- Damage bar
  local BAR_W, BAR_H, BAR_V = 16, 64, 49;
  local BAR_R = BAR_H - BAR_V;
  local BAR_MARGIN = 15;
  local GOOD_COLOUR, WARN_COLOUR, CRIT_COLOUR = Color(100, 255, 100), Color(255, 220, 100), Color(255, 90, 80);

  -- Add panel
  HOLOHUD:AddFlashPanel(PANEL_NAME);
  HOLOHUD:AddHighlight(PANEL_NAME);

  -- Variables
  local lastDmg = 0;
  local colour = 0;
  local blink = 0;
  local lerp = 0;

  --[[
    Returns the real current player velocity
    @return {number} velocity length
  ]]
  local function GetVelocity()
    if (LocalPlayer():InVehicle()) then
      if (IsValid(LocalPlayer():GetVehicle():GetMoveParent())) then
        return LocalPlayer():GetVehicle():GetMoveParent():GetVelocity():Length();
      else
        return LocalPlayer():GetVehicle():GetVelocity():Length();
      end
    else
      return LocalPlayer():GetVelocity():Length();
    end
  end

  --[[
    Return the real health to display
    @return {number} vehicle health
  ]]
  local function GetHealth()
    if (not LocalPlayer():InVehicle()) then return -1, 0; end
    if (IsValid(LocalPlayer():GetVehicle():GetMoveParent())) then
      local ent = LocalPlayer():GetVehicle():GetMoveParent();
      if (ent:Health() > ent:GetNWFloat("Health")) then
        return ent:Health(), ent:GetMaxHealth();
      else
        return ent:GetNWFloat("Health"), ent:GetMaxHealth();
      end
    else
      return LocalPlayer():GetVehicle():Health(), LocalPlayer():GetVehicle():GetMaxHealth();
    end
  end

  --[[
    Returns the damage bar's colour
    @param {boolean} health bar as damage bar
    @return {Color} colour
  ]]
  local function GetDamageColour(isDamage)
    local goodCol = HOLOHUD.ELEMENTS:ConfigValue(PANEL_NAME, "good_colour");
    local warnCol = HOLOHUD.ELEMENTS:ConfigValue(PANEL_NAME, "warn_colour");
    local critCol = HOLOHUD.ELEMENTS:ConfigValue(PANEL_NAME, "crit_colour");

    if (colour < 0.5) then
      return HOLOHUD:IntersectColour(warnCol, critCol, math.Clamp((colour - 0.25) * 3, 0, 1));
    else
      return HOLOHUD:IntersectColour(goodCol, warnCol, math.Clamp((colour - 0.5) * 2, 0, 1));
    end
  end

  --[[
    Draws the damage bar
    @param {number} x
    @param {number} y
    @param {boolean} health bar as damage bar
    @void
  ]]
  local function DrawDamage(x, y, health, isDamage)
    -- Highlight
    if (lastDmg ~= health) then
      HOLOHUD:TriggerHighlight(PANEL_NAME);
      lastDmg = health;
    end

    -- Critical health
    if (health < 0.25 and blink < CurTime()) then
      HOLOHUD:TriggerHighlight(PANEL_NAME);
      blink = CurTime() + 1.16;
    end

    -- Set lerp
    colour = Lerp(FrameTime() * 3, colour, health);

    -- Draw
    if (isDamage) then health = 1 - health; end
    lerp = Lerp(FrameTime() * 5, lerp, health);
    HOLOHUD:DrawVerticalBar(x, y, GetDamageColour(isDamage), lerp, HOLOHUD:GetHighlight(PANEL_NAME));
  end

  --[[
    Draws the foreground
    @param {boolean} is MPH enabled instead of KPH
    @param {string} unit to display
    @param {boolean} show damage bar inversly
    @param {boolean} force hide damage bar
    @param {Color} text colour
    @param {Color} brackets colour
    @void
  ]]
  local function DrawForeground(x, y, w, h, always, unittype, unit, isDamage, hideBar, colour, bgCol)
    -- Get values
    local offset = 0;
    local hasDamage = false;
    local health, maxHealth = GetHealth();

    -- Get speed
    local speed = GetVelocity();
    if unittype == 2 then
      speed = speed * MPH;
    elseif unittype == 1 then
      speed = speed * MPH * KPH;
    else -- ups
      speed = speed;
    end

    -- Is vehicle damagable
    if (maxHealth > 0 and not hideBar) then
      offset = BAR_MARGIN;
      hasDamage = true;
    end

    -- Draw speed
    local zeros = "000";
    local unitoffset = 22;
    local bracketoffset = 31;
    if unittype == 3 then
      zeros = "0000";
      unitoffset = 44;
      bracketoffset = 15;
    end;
    HOLOHUD:DrawBracket(x + offset - 3, y - 3, false, bgCol);
    HOLOHUD:DrawNumber(x + offset + 17, y + (h * 0.5), math.floor(speed), colour, zeros, 0, "holohud_main", not LocalPlayer():InVehicle() and not always);
    HOLOHUD:DrawText(x + offset + HOLOHUD:GetNumberSize(3) + unitoffset, y + h - 9, unit, "holohud_pickup", colour, nil, nil, TEXT_ALIGN_BOTTOM);
    HOLOHUD:DrawBracket(x + w - 31, y - 3, true, bgCol);

    -- Draw damage bar
    if (hasDamage and not hideBar) then
      DrawDamage(x, y + 1, health/maxHealth, isDamage);
    end
  end

  --[[
    Animates and draws the panel
    @param {function} config
    @void
  ]]
  local function DrawPanel(config)
    -- Move meter if ammunition panel is active
    local offset = 0;
    if (HOLOHUD:IsPanelActive("ammunition")) then
      local w, h = HOLOHUD.ELEMENTS:GetElementSize("ammunition");
      offset = h + 5;
    end

    -- Get size
    local unit = KPH_UNIT;
    local unitcommon = 0;
    local panelmul = 2;
    if LocalPlayer():InVehicle() then
      unitcommon = config("unitveh");
    else
      unitcommon = config("unitfoot");
    end
    if (unitcommon == 2) then unit = MPH_UNIT; end
    if (unitcommon == 3) then
      unit = UPS_UNIT;
      panelmul = 3.4;
    end
    surface.SetFont("holohud_pickup");
    local unitWidth = surface.GetTextSize(unit);
    local w = (W * panelmul) + HOLOHUD:GetNumberSize(3) + unitWidth;
    local health, maxHealth = GetHealth();
    if (LocalPlayer():InVehicle() and maxHealth > 0 and not config("hide_bar")) then
      w = w + BAR_MARGIN;
    end

    -- Position
    local x, y = ScrW() - SCREEN_OFFSET - w, ScrH() - SCREEN_OFFSET - H - offset;
    if (config("center")) then
      x = (ScrW() * 0.5) - (w * 0.5);
      y = ScrH() - SCREEN_OFFSET - H;
    end

    HOLOHUD:SetPanelActive(PANEL_NAME, LocalPlayer():InVehicle() or config("always"));
    HOLOHUD:DrawFragment(x - config("x_offset"), y - config("y_offset"), w, H, DrawForeground, PANEL_NAME, config("always"), unitcommon, unit, config("damage"), config("hide_bar"), config("colour"), config("bg_col"));

    return w, h;
  end

  -- Add element
  HOLOHUD.ELEMENTS:AddElement(PANEL_NAME,
    "Speed-o-meter",
    "When in a vehicle, it'll track its speed",
    nil,
    {
      unitveh = { name = "Unit (in vehicle)", value = 1, options = {"km/h", "mph", "ups"} },
      unitfoot = { name = "Unit (on foot)", value = 3, options = {"km/h", "mph", "ups"} },
      damage = { name = "Health bar as damage", desc = "Health meter with count the amount of damage instead of the health left", value = false},
      hide_bar = { name = "Don't show damage bar", value = false },
      center = { name = "Centered", value = false },
      colour = { name = "Foreground colour", value = Color(255, 255, 255) },
      bg_col = { name = "Brackets colour", value = Color(255, 112, 66) },
      good_colour = { name = "Good state colour", value = GOOD_COLOUR },
      warn_colour = { name = "Warning colour", value = WARN_COLOUR },
      crit_colour = { name = "Critical colour", value = CRIT_COLOUR },
      x_offset = { name = "Horizontal offset", value = 0, minValue = 0, maxValue = ScrW() },
      y_offset = { name = "Vertical offset", value = 0, minValue = 0, maxValue = ScrH() },
      always = { name = "Display on foot", value = false }
    },
    DrawPanel
  );

end
