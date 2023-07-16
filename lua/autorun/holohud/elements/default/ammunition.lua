--[[------------------------------------------------------------------
  AMMUNITION DISPLAY
  Core file for the ammunition indicators
]]--------------------------------------------------------------------

-- Util and setup
if CLIENT then

  -- Namespace
  HOLOHUD.ELEMENTS.AMMUNITION = {};

  -- Parameters
  HOLOHUD.ELEMENTS.AMMUNITION.PANELS = { -- Panel names
    DEFAULT = "ammunition",
    SECONDARY = "ammunition_alt",
    MINIMALIST = "ammunition_minimalist"
  };

  HOLOHUD.ELEMENTS.AMMUNITION.HIGHLIGHT = { -- Highlight panels
    CLIP = "ammunition_clip",
    RESERVE = "ammunition_reserve",
    SECONDARY = "ammunition_alt"
  };

  -- Inlcude panels
  --[[include("ammunition/default.lua");
  include("ammunition/minimalist.lua");
  include("ammunition/compact.lua");]]
end

HOLOHUD:IncludeFile("ammunition/default.lua");
HOLOHUD:IncludeFile("ammunition/minimalist.lua");
HOLOHUD:IncludeFile("ammunition/compact.lua");

if CLIENT then

  -- Parameters
  local ELEMENT_NAME = "ammunition";
  local AMMO_COLOUR, CRIT_COLOUR = Color(255, 236, 100, 200), Color(255, 100, 72, 200); -- Default colours
  local TIME = 5; -- Default display time (in seconds)

  -- Register panels
  HOLOHUD:AddFlashPanel(HOLOHUD.ELEMENTS.AMMUNITION.PANELS.DEFAULT);
  HOLOHUD:AddFlashPanel(HOLOHUD.ELEMENTS.AMMUNITION.PANELS.SECONDARY);
  HOLOHUD:AddFlashPanel(HOLOHUD.ELEMENTS.AMMUNITION.PANELS.MINIMALIST);

  -- Register highlight
  HOLOHUD:AddHighlight(HOLOHUD.ELEMENTS.AMMUNITION.HIGHLIGHT.CLIP);
  HOLOHUD:AddHighlight(HOLOHUD.ELEMENTS.AMMUNITION.HIGHLIGHT.RESERVE);
  HOLOHUD:AddHighlight(HOLOHUD.ELEMENTS.AMMUNITION.HIGHLIGHT.SECONDARY);

  -- Variables
  local sOffset = 0; -- Secondary attack animation offset
  local srOffset = 0; -- Secondary ammo type change animation offset
  local rOffset = 0; -- Reload animation offset
  local aOffset = 0; -- Attack animation offset
  local reload = false; -- Is the weapon being reloaded
  local attack = false; -- Is the player using the primary fire
  local attack2 = false; -- Is the player using the secondary fire
  local lastWeapon = nil; -- Which was the last weapon
  local lAmmo, lClip, lAlt = 0, 0, 0; -- Last ammo, clip and alternate fire ammo
  local tick = 0; -- Generic tick
  local isRetracted = false; -- Is the ammo indicator retracted?
  local time = 0; -- Time before hiding the display
  local lastMode = -1; -- Last mode

  -- Colouring
  local primaryColour, secondaryColour = 1, 1;

  --[[
    Based on the weapon's ammo, change colours
    @param {number} primary ammunition type
    @param {number} secondary ammunition type
    @param {number} clip ammunition amount
    @param {number} primary ammunition reserve
    @param {number} secondary ammunition reserve
    @void
  ]]
  local function AnimateColour(primary, secondary, clip, reserve, alt)
    if (clip <= -1) then clip = reserve; end
    if (primary < 0) then clip = alt; end

    -- Primary ammo
		if (clip > 0) then
			primaryColour = Lerp(FrameTime() * 4, primaryColour, 1);
    else
			primaryColour = Lerp(FrameTime() * 8, primaryColour, 0);
		end

    -- Secondary ammo
    if (alt > 0 or secondary < 0) then
      secondaryColour = Lerp(FrameTime() * 3, secondaryColour, 1);
    else
			secondaryColour = Lerp(FrameTime() * 6, secondaryColour, 0);
		end
  end

  --[[
    Animates the ammunition panel
    @param {number} display mode
    @param {number} weapon entity index
    @param {number} primary ammunition type
    @param {number} secondary ammunition type
    @param {number} clip ammunition amount
    @param {number} primary ammunition reserve
    @param {number} secondary ammunition reserve
    @void
  ]]
  function Animate(mode, weapon, primary, secondary, clip, reserve, alt)
    -- Colouring
    AnimateColour(primary, secondary, clip, reserve, alt);

    -- Mode changes, display new indicators
    if (lastMode ~= mode) then
      if (lastMode ~= -1) then
        time = CurTime() + TIME;
      end
      lastMode = mode;
    end

    -- Show when RELOAD is pressed or when is empty and player attempts to attack
    local isEmpty = primary >= 0 and clip <= 0 or clip <= -1 and reserve <= 0 or primary < 0 and alt <= 0;
    if (LocalPlayer():KeyDown(IN_RELOAD) or LocalPlayer():KeyDown(IN_ATTACK) and isEmpty) then
      time = CurTime() + TIME;
    end

    -- Highlight numbers on change
    if (lClip ~= clip) then
      HOLOHUD:TriggerHighlight(HOLOHUD.ELEMENTS.AMMUNITION.HIGHLIGHT.CLIP);

      -- Do reload animation
      if (reload and lClip < clip and clip - lClip > 1) then
        rOffset = 1;
      end

      -- Do attack animation
      if (lClip > clip) then
        if (attack) then aOffset = 0; end
        attack = true;
      end

      time = CurTime() + TIME;
      lClip = clip;
    end

    if (lAmmo ~= reserve) then
      HOLOHUD:TriggerHighlight(HOLOHUD.ELEMENTS.AMMUNITION.HIGHLIGHT.RESERVE);

      -- If no clip is present, do the animation with reserve ammo
      if (clip <= -1 and lAmmo > reserve) then
        if (attack) then aOffset = 0; end
        attack = true;
      end

      time = CurTime() + TIME;
      lAmmo = reserve;
    end

    if (lAlt ~= alt) then
      HOLOHUD:TriggerHighlight(HOLOHUD.ELEMENTS.AMMUNITION.HIGHLIGHT.SECONDARY);
      -- Bullet animation
      if (lAlt > alt) then
        if (attack2) then sOffset = 0; end
        attack2 = true;
      end

      if (mode ~= 2 or primary < 0) then
        time = CurTime() + TIME;
      end
      lAlt = alt;
    end

    -- Change weapon
    if (lastWeapon ~= weapon) then
      reload = true;
      rOffset = 1;
      srOffset = 1;
      lastWeapon = weapon;
    end

    -- Do reload animation
    if (clip <= 0 and reserve > 0 and not reload) then
      reload = LocalPlayer():KeyDown(IN_RELOAD);
    end

    -- Do all animations
    if (tick < CurTime()) then
      -- Reload animation
      if (reload and rOffset > 0 and HOLOHUD:GetFlashPanel(HOLOHUD.ELEMENTS.AMMUNITION.PANELS.DEFAULT).flash < 1) then
        rOffset = math.Clamp(rOffset - 0.07, 0, 1);
      end

      -- Attack animation
      if (attack and aOffset < 1) then
        aOffset = math.Clamp(aOffset + 0.2, 0, 1);
      elseif (attack and aOffset >= 1) then
        attack = false;
        aOffset = 0;
      end

      -- Secondary attack animation
      if (attack2 and sOffset < 1) then
        sOffset = math.Clamp(sOffset + 0.2, 0, 1);
      elseif (attack2 and sOffset >= 1) then
        attack2 = false;
        sOffset = 0;
      end

      -- Secondary ammo type change animation
      if (srOffset > 0 and HOLOHUD:GetFlashPanel(HOLOHUD.ELEMENTS.AMMUNITION.PANELS.SECONDARY).flash < 1) then
        srOffset = math.Clamp(srOffset - 0.07, 0, 1);
      end

      tick = CurTime() + 0.01;
    end

  end

  --[[
    Calculates the bullet alpha
    @param {number} percentage
    @param {number} i
    @param {number} count
    @param {number} animation
    @return {number} alpha
  ]]
  local function GetBulletAlpha(percentage, i, count, anim)
    anim = anim or 0;
    local a = 1;
    if (i <= 0) then a = (1-anim); end
    return math.Clamp(percentage - ((i+1)/count), 0, 1 / count) / (1 / count) * a;
  end

  --[[
    Draws a bullet stream
    @param {number} x
    @param {number} y
    @param {number} ammunition type
    @param {number} current ammunition amount
    @param {number} maximum ammunition amount
    @param {number} amount of bullets displayed
    @param {Color|nil} colour
    @param {number|nil} bright
    @param {number|nil} attack animation amount
    @param {number|nil} reload animation amount
    @param {number|nil} percentage of bullets displayed
    @param {boolean|nil} vertical or horizontal
    @void
  ]]
  function HOLOHUD.ELEMENTS.AMMUNITION:DrawBulletStream(x, y, ammo, clip, max, rounds, colour, bright, aAnim, rAnim, percentage, vertical)
    if (vertical == nil) then vertical = false; end
    bright = bright or 0;
    colour = colour or AMMO_COLOUR;
    aAnim = aAnim or 0;
    rAnim = rAnim or 0;
    percentage = percentage or 1;
    if (rAnim > 0) then aAnim = 0; end

    -- Limit bullets so they don't go out of bounds
    max = math.Clamp(max, 0, max);

    -- Ammunition type icon size
    local icon = HOLOHUD.ICONS:GetBulletIcon(ammo);
    local tWidth, margin = icon.w or 0, icon.margin or 0;
    local pos = -(tWidth * 0.5) + (margin * 0.5);

    -- Alignment
    local u, v = 1, 0;
    if (vertical) then u = 0; v = 1; end

    -- Cut up rounds
    local count = math.min(max, rounds);
    if (clip > max) then count = rounds; end

    -- Animation offsets
    local rOff = (margin * count) * rAnim;
    local aOff = (-margin * aAnim);

    -- Clip bullets
    for i=0, math.Clamp(clip, 0, count)-1 + (math.ceil(aAnim)) do
      local offset = pos + rOff + aOff + (margin * i);
      local colour = Color(colour.r, colour.g, colour.b, colour.a * GetBulletAlpha(percentage, i, count + 1, aAnim));
      HOLOHUD.ICONS:DrawBulletIcon(x + offset * u, y + offset * v, ammo, colour, bright);
    end

    -- Maximum capacity
    if (rounds > max) then
      if (clip > max) then max = clip; end
      for i=max, rounds - 1 do
        local offset = pos + (margin * i);
        HOLOHUD.ICONS:DrawBulletIcon(x + offset * u, y + offset * v, ammo, Color(255, 255, 255, 24), nil, true);
      end
    end
  end

  --[[
    Returns whether the panel has time to display
    @return {boolean} true if time hasn't run out, false otherwise
  ]]
  function HOLOHUD.ELEMENTS.AMMUNITION:CanDisplay(clip, maxClip)
    return time > CurTime() or (HOLOHUD.ELEMENTS:ConfigValue(ELEMENT_NAME, "hide") and clip < maxClip and clip > -1);
  end

  --[[
    Returns whether the panel should hide because player is in a vehicle
    @return {boolean} true if in vehicle, false otherwise
  ]]
  function HOLOHUD.ELEMENTS.AMMUNITION:InVehicle()
    return LocalPlayer():InVehicle() and not LocalPlayer():GetAllowWeaponsInVehicle();
  end

  --[[
    Returns the current colour for the ammunition indicator
    @param {boolean|nil} is secondary ammunition colour
    @return {Color} colour
  ]]
  function HOLOHUD.ELEMENTS.AMMUNITION:GetColour(secondary)
    local colour = primaryColour;
    if (secondary) then colour = secondaryColour; end
    return HOLOHUD:IntersectColour(HOLOHUD.ELEMENTS:ConfigValue(ELEMENT_NAME, "colour"), HOLOHUD.ELEMENTS:ConfigValue(ELEMENT_NAME, "crit_colour"), colour);
  end

  --[[
    Returns the current bullet stream animation
    @param {boolean|nil} is secondary ammunition
    @return {number} attack animation
    @return {number} reload animation
  ]]
  function HOLOHUD.ELEMENTS.AMMUNITION:GetBulletStreamAnimation(secondary)
    if (secondary) then
      return sOffset, srOffset;
    else
      return aOffset, rOffset;
    end
  end

  --[[
		Animates and draws the full panel
		@param {table} config
		@void
	]]
  local function DrawPanel(config)
    -- Get weapon data
    local weapon = LocalPlayer():GetActiveWeapon();
    local entIndex, primary, secondary, clip, maxClip, reserve, alt = -1, -1, -1, -1, -1, 0, 0;
    if (IsValid(weapon)) then
      entIndex = weapon:EntIndex();
      primary = weapon:GetPrimaryAmmoType();
      secondary = weapon:GetSecondaryAmmoType();
      clip = weapon:Clip1();
      maxClip = weapon:GetMaxClip1();
      reserve = LocalPlayer():GetAmmoCount(primary);
      alt = LocalPlayer():GetAmmoCount(secondary);
    end

    -- Animate
    Animate(config("mode"), entIndex, primary, secondary, clip, reserve, alt);

    -- Should activate
    HOLOHUD:SetPanelActive(HOLOHUD.ELEMENTS.AMMUNITION.PANELS.DEFAULT,
                          not HOLOHUD.ELEMENTS.AMMUNITION:InVehicle() and
                          (primary >= 0 or secondary >= 0 and primary < 0)
                          and (HOLOHUD.ELEMENTS.AMMUNITION:CanDisplay(clip, maxClip) or config("always")));

    -- Display based on mode
    if (config("mode") == 2) then
      return HOLOHUD.ELEMENTS.AMMUNITION:MinimalistPanel(primary, secondary, clip, maxClip, reserve, alt, config, not IsValid(weapon));
    elseif (config("mode") == 3) then
      return HOLOHUD.ELEMENTS.AMMUNITION:CompactPanel(primary, secondary, clip, maxClip, reserve, alt, config, not IsValid(weapon));
    else
      return HOLOHUD.ELEMENTS.AMMUNITION:DefaultPanel(primary, secondary, clip, maxClip, reserve, alt, config, not IsValid(weapon));
    end

  end

  -- Add element
  HOLOHUD.ELEMENTS:AddElement(ELEMENT_NAME,
    "#holohud.settings.ammo.name",
    "#holohud.settings.ammo.description",
    {"CHudAmmo", "CHudSecondaryAmmo"},
    {
      always = {name = "#holohud.settings.ammo.always_displayed", value = false },
      mode = { name = "#holohud.settings.ammo.mode", value = 1, options = {"#holohud.settings.ammo.mode.default", "#holohud.settings.ammo.mode.minimal", "#holohud.settings.ammo.mode.compact"} },
      hide = { name = "#holohud.settings.ammo.dont_hide", desc = "#holohud.settings.ammo.dont_hide.description", value = false },
      colour = { name = "#holohud.settings.ammo.color", value = AMMO_COLOUR },
      crit_colour = { name = "#holohud.settings.ammo.empty_color", value = CRIT_COLOUR }
    }, DrawPanel
  );

end
