--[[------------------------------------------------------------------
  TARGET'S HEALTH BAR
  Display's current health of the target you're looking at
]]--------------------------------------------------------------------

local SHARED_VALUE = "holohud_maxHealth";

--[[
  Returns whether the entity is a non-player-character
  @param {Entity} entity
  @return {boolean} is NPC
]]
local function IsNPC(entity)
  return IsValid(entity) and (entity:IsNPC() or (entity:IsScripted() and entity.Type == "nextbot"));
end

if CLIENT then

  -- Parameters
  local PANEL_OFFSET = 20;
  local MARGIN = 20;
  local PANEL_NAME = "target_health";
  local WIDTH, HEIGHT, P_HEIGHT = 200, 43, 54;
  local TIME = 0.66;
  local HEALTH_GOOD, HEALTH_WARN, HEALTH_CRIT = Color(100, 255, 100, 200), Color(255, 233, 100, 200), Color(255, 100, 72, 200);
  local ARMOUR_COLOUR = Color(100, 166, 255);
  local TEXTURE, TEXTURE_BRIGHT = surface.GetTextureID("holohud/bar_horizontal"), surface.GetTextureID("holohud/bar_horizontalb");
  local SUIT_V = 49;

  -- Add panel and highlight
  HOLOHUD:AddFlashPanel(PANEL_NAME);
  HOLOHUD:AddHighlight(PANEL_NAME);

  -- Variables
  local lastHp = 0;
  local lerp = 0;
  local apLerp = 0;
  local index = -1;
  local time = 0;
  local colour = 0;

  --[[
    Returns the current health colour
    @return {Color} colour
  ]]
  local function GetHealthColour()
    local goodCol = HOLOHUD.ELEMENTS:ConfigValue(PANEL_NAME, "good_colour");
    local warnCol = HOLOHUD.ELEMENTS:ConfigValue(PANEL_NAME, "warn_colour");
    local critCol = HOLOHUD.ELEMENTS:ConfigValue(PANEL_NAME, "crit_colour");

    local value = 1 - colour;
		if (colour > 1) then
			value = (1 - (colour - 1));
			return HOLOHUD:IntersectColour(warnCol, critCol, value);
		else
			return HOLOHUD:IntersectColour(goodCol, warnCol, value);
		end
  end

  --[[
    Animates the health bar colour
    @void
  ]]
  local function AnimateColour(health)
    if (health > 25 and health < 50) then
			colour = Lerp(FrameTime() * 3, colour, 1);
		elseif (health <= 25) then
			colour = Lerp(FrameTime() * 6, colour, 2);
		else
			colour = Lerp(FrameTime(), colour, 0);
		end
  end

  --[[
    Displays the target's health
    @param {number} x
    @param {number} y
    @param {number} w
    @param {number} h
    @param {Entity} target
    @param {Color} enemy health colour
    @param {Color} allies health colour
    @param {Color} name colour
    @param {Color} armour colour
    @param {boolean} should lerp the value
    @void
  ]]
  local function DrawHealth(x, y, w, h, target, barCol, allyCol, nameColour, armourCol, shouldLerp)
    local bright = HOLOHUD:GetHighlight(PANEL_NAME);
    local name, health, maxHealth, armour = "", -1, -1, -1;
    barCol = barCol or Color(255, 100, 72, 200);
    nameColour = nameColour or Color(255, 255, 255, 200);

    -- Check if target is valid
    if (IsValid(target) and target:Health() > 0) then
      health = target:Health();
      if (target:IsPlayer()) then
        maxHealth = 100;
        armour = target:Armor();
        name = target:Nick();
        barCol = GetHealthColour();
        AnimateColour(health);
      elseif (IsNPC(target)) then
        maxHealth = target:GetNWInt(SHARED_VALUE);
        name = language.GetPhrase(target:GetClass());
        if (IsFriendEntityName(target:GetClass())) then
          barCol = allyCol or Color(100, 255, 100, 200);
        end
      end

      -- Trigger highlight
      if (lastHp ~= health) then
        HOLOHUD:TriggerHighlight(PANEL_NAME);
        lastHp = health;
      end

      if (shouldLerp) then
        lerp = Lerp(FrameTime() * 4, lerp, health);
        apLerp = Lerp(FrameTime() * 4, apLerp, armour);
      else
        lerp = health;
        apLerp = armour;
      end
    else
      lerp = -1;
      apLerp = -1;
      maxHealth = 0;
    end

    -- If it's a player display it differently
    if (armour > -1) then
      HOLOHUD:DrawText(x + (w * 0.5), y + 3, name, "holohud_target", nameColour, bright, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP);
      HOLOHUD:DrawBar(x + 6, y + h - 20, w + 4, 23, barCol, lerp / maxHealth, bright);
      HOLOHUD:DrawHorizontalBar(x + w - SUIT_V - 5, y + h - 16, armourCol or ARMOUR_COLOUR, apLerp / 100, bright);
    else
      HOLOHUD:DrawText(x + (w * 0.5), y + 4, name, "holohud_weapon_name", nameColour, bright, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP);
      HOLOHUD:DrawBar(x + 5, y + h - 11, w + 4, 23, barCol, lerp / maxHealth, bright);
    end
  end

  --[[
    Controls whether the panel should be drawn, and draws it
    @param {function} configuration
    @void
  ]]
  local offset = 0;
  local function DrawPanel(config)
    local trace = LocalPlayer():GetEyeTrace();

    -- Is entity valid
    if (trace ~= nil and IsValid(trace.Entity) and (trace.Entity:IsPlayer() or IsNPC(trace.Entity))) then
      index = trace.Entity:EntIndex();
      time = CurTime() + TIME;
    end

    local entity = ents.GetByIndex(index) or nil;

    -- Get screen offset and panel size
    local w, h = WIDTH, HEIGHT;
    local x, y = HOLOHUD.ELEMENTS:GetElementSize("compass");
    offset = math.Clamp(ScrH() * config("npc_offset"), PANEL_OFFSET + y + MARGIN, ScrH());
    if (entity ~= nil) then
      if (entity:IsPlayer()) then -- Player panel size and offset
        surface.SetFont("holohud_small");
        local u, v = surface.GetTextSize(entity:Nick());
        h = math.Clamp(v, P_HEIGHT, v);
        w = u + MARGIN * 2;
        offset = ScrH() * config("player_offset");
      end

      -- Remove reference if time passed
      if (time < CurTime() and (not HOLOHUD:IsPanelActive(PANEL_NAME) or HOLOHUD.EditMode)) then
        entity = nil;
      end
    end

    -- Activate and draw panel
    local align = TEXT_ALIGN_TOP;
    if (IsValid(entity) and entity:IsPlayer()) then align = TEXT_ALIGN_BOTTOM; end
    HOLOHUD:SetPanelActive(PANEL_NAME, IsValid(entity) and (entity:IsPlayer() or IsNPC(entity)) and time > CurTime());
    HOLOHUD:DrawFragmentAlign((ScrW() * 0.5) - (w * 0.5), offset, w, h, DrawHealth, PANEL_NAME, align, nil, config("alpha"), nil, entity, config("enemy"), config("ally"), config("name"), config("armour"));
  end

  -- Add element
  HOLOHUD.ELEMENTS:AddElement(PANEL_NAME,
    "Target ID",
    "Displays the health of the player/NPC you're looking at",
    nil,
    {
      alpha = { name = "Background opacity", value = 0.15, minValue = 0, maxValue = 1 },
      npc_offset = { name = "NPC panel offset", value = 0.16, minValue = 0, maxValue = 1 },
      player_offset = { name = "Player panel offset", value = 0.63, minValue = 0, maxValue = 1 },
      name = { name = "Name colour", value = Color(255, 255, 255)},
      ally = { name = "Ally colour", value = Color(100, 255, 100) },
      enemy = { name = "Enemy colour", value = Color(255, 100, 72) },
      good_colour = { name = "Normal colour", value = HEALTH_GOOD },
      warn_colour = { name = "Warning colour", value = HEALTH_WARN },
      crit_colour = { name = "Critical colour", value = HEALTH_CRIT },
      armour = { name = "Armour colour", value = ARMOUR_COLOUR },
      lerp = { name = "Enable smooth animation", value = true }
    },
    DrawPanel
  );

  -- Hide default
  hook.Add("HUDDrawTargetID", "holohud_target", function()
    if (HOLOHUD:IsHUDEnabled()) then return true; end
  end);

end

if SERVER then

  -- Use a networked value to know maximum health
  hook.Add("OnEntityCreated", "holohud_target_maxhealth", function(ent)
    if (not IsValid(ent) or ent == NULL or not IsNPC(ent) or ent.Health == nil) then return; end
    timer.Simple(0.1, function()
      if (not IsValid(ent) or ent == NULL or not IsNPC(ent) or ent.Health == nil) then return; end
      ent:SetNWInt(SHARED_VALUE, ent:Health());
    end);
  end);

end
