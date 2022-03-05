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
  local HEALTH_FULL, HEALTH_GOOD, HEALTH_WARN, HEALTH_CRIT = Color(200, 255, 200, 200), Color(100, 255, 100, 200), Color(255, 233, 100, 200), Color(255, 100, 72, 200);
  local ARMOUR_COLOUR = Color(100, 166, 255);
  local TEXTURE, TEXTURE_BRIGHT = surface.GetTextureID("holohud/bar_horizontal"), surface.GetTextureID("holohud/bar_horizontalb");
  local SUIT_V = 49;

  local HEALTH_LENGTH = 3;
  local HEALTH_MAX = 250;
  local WIDTH_MIN = 100;

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

  -- these variables are now networked
  local health = 0;
  local enemy;

  --[[
    Returns the current health colour
    @return {Color} colour
  ]]
  local function GetHealthColour()
    -- added color for being at full health
    local fullCol = HOLOHUD.ELEMENTS:ConfigValue(PANEL_NAME, "full_colour");
    local goodCol = HOLOHUD.ELEMENTS:ConfigValue(PANEL_NAME, "good_colour");
    local warnCol = HOLOHUD.ELEMENTS:ConfigValue(PANEL_NAME, "warn_colour");
    local critCol = HOLOHUD.ELEMENTS:ConfigValue(PANEL_NAME, "crit_colour");

    -- local value = 1 - colour;
	if (colour > 2) then
		local value = 3 - colour
		return HOLOHUD:IntersectColour(goodCol, fullCol, value);
	elseif (colour > 1) then
		local value = 2 - colour
		return HOLOHUD:IntersectColour(warnCol, goodCol, value);
	else
		local value = 1 - colour
		return HOLOHUD:IntersectColour(critCol, warnCol, value);
	end
  end

  --[[
    Animates the health bar colour
    @void
  ]]
  local function AnimateColour(health)
	if (health <= 0.25) then
		colour = Lerp(FrameTime() * 6, colour, 0);
    elseif (health <= 0.50) then
		colour = Lerp(FrameTime() * 3, colour, 1);
	elseif health < 1 then
		colour = Lerp(FrameTime(), colour, 2)
	else
		colour = Lerp(FrameTime(), colour, 3);
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
    @param {boolean} right aligned bar
    @void
  ]]
  local function DrawHealth(x, y, w, h, target, barCol, enemyCol, nameColour, armourCol, shouldLerp, right_align, var_length)
    local bright = HOLOHUD:GetHighlight(PANEL_NAME);
    -- local name, health, maxHealth, armour = "", -1, -1, -1;
    local name, maxHealth, armour = "", -1, -1;
    barCol = barCol or Color(100, 255, 100, 200);
    nameColour = nameColour or Color(255, 255, 255, 200);

    -- Check if target is valid
    if (IsValid(target) and target:Health() > 0) then
      -- health = target:Health();
      if (target:IsPlayer()) then
        maxHealth = 100;
        armour = target:Armor();
        name = target:Nick();
        barCol = GetHealthColour();
        AnimateColour(health);
      elseif (IsNPC(target)) then
        maxHealth = target:GetNWInt(SHARED_VALUE);
        name = language.GetPhrase(target:GetClass());
        -- if (IsFriendEntityName(target:GetClass())) then
        if (enemy) then
          -- barCol = allyCol or Color(100, 255, 100, 200);
          barCol = enemyCol or Color(255, 100, 72, 200);
        end
      end

      -- Trigger highlight
      if (lastHp ~= health) then
        HOLOHUD:TriggerHighlight(PANEL_NAME);
        lastHp = health;
      end

      if (shouldLerp) and lerp >= 0 then -- update immediately if we're not focused, otherwise it takes a while
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

    -- get the bar drawing function to use
    local bar_func = HOLOHUD.DrawBar
    if right_align then bar_func = HOLOHUD.DrawBarRight end

    -- If it's a player display it differently
    if (armour > -1) then
      HOLOHUD:DrawText(x + (w * 0.5), y + 3, name, "holohud_target", nameColour, bright, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP);
      bar_func(HOLOHUD, x + 6, y + h - 20, w + 4, 23, barCol, lerp / maxHealth, bright);
      HOLOHUD:DrawHorizontalBar(x + w - SUIT_V - 5, y + h - 16, armourCol or ARMOUR_COLOUR, apLerp / 100, bright);
    else
      HOLOHUD:DrawText(x + (w * 0.5), y + 4, name, "holohud_weapon_name", nameColour, bright, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP);
	  if var_length then
		  local bar = HEALTH_MAX
		  local l = lerp
		  local i = 1
		  local ihatenamingvariables = maxHealth -- don't judge me
		  local offset = 0
		  local hp = health
		  -- while maxHealth > i*bar and i <= 39 do
		  while maxHealth > i*bar and i <= 39 do
			offset = 6
			if hp > bar then
				l = l - bar
				ihatenamingvariables = ihatenamingvariables - bar
				if i == 1 then
				  barCol.a = 50
				  bar_func(HOLOHUD, x + 7, y + h - 11 - offset, HEALTH_MAX * HEALTH_LENGTH, 23, barCol, 1, bright);
				end
			end
			hp = hp - bar
			barCol.a = 255
			bar_func(HOLOHUD, x + (HEALTH_MAX * HEALTH_LENGTH) - (i*18) - 12, y + h - 4, 33, 15, barCol, hp > 0 and 1 or 0, bright);
			i = i + 1
		  end
		  w2 = math.Clamp(ihatenamingvariables, 10, HEALTH_MAX) * HEALTH_LENGTH
		  bar_func(HOLOHUD, x + w - w2 + 7, y + h - 11 - offset, w2, 23, barCol, l / math.min(ihatenamingvariables, bar), bright);
	  else
		bar_func(HOLOHUD, x + 5, y + h - 11, w + 4, 23, barCol, lerp / maxHealth, bright);
	  end
    end
  end

  net.Receive("holohud_target_whatever", function(len, ply)
	index = net.ReadInt(32)
	health = net.ReadFloat()
	enemy = net.ReadBool()
    time = CurTime() + TIME
	-- print("test")
  end)

  --[[
    Controls whether the panel should be drawn, and draws it
    @param {function} configuration
    @void
  ]]
  local offset = 0;
  local function DrawPanel(config)
    -- local trace = LocalPlayer():GetEyeTrace();

    -- -- Is entity valid
    -- if (trace ~= nil and IsValid(trace.Entity) and (trace.Entity:IsPlayer() or IsNPC(trace.Entity))) then
      -- index = trace.Entity:EntIndex();
      -- time = CurTime() + TIME;
    -- end

    local entity = ents.GetByIndex(index) or nil;

    -- Get screen offset and panel size
    local w, h = WIDTH, HEIGHT;
    -- local x, y = HOLOHUD.ELEMENTS:GetElementSize("compass");
	-- slightly more efficient way of calculating offsets
	local x = MARGIN
	local y = MARGIN + (ScrH() - MARGIN*2 - h) * config("npc_offset")
    if (entity ~= nil) then
	  if IsValid(entity) and config("var_length") then
		  local maxHealth = entity:GetNWInt(SHARED_VALUE);
		  if maxHealth <= 0 then
			maxHealth = entity:GetMaxHealth()
		  end
		  -- w = math.Clamp(maxHealth * HEALTH_LENGTH, WIDTH_MIN, HEALTH_MAX)
		  w = math.Clamp(maxHealth * HEALTH_LENGTH, WIDTH_MIN, HEALTH_MAX * HEALTH_LENGTH)
		  -- if maxHealth > HEALTH_MAX / HEALTH_LENGTH then
		  if maxHealth > HEALTH_MAX then
			h = h + 6
		  end
	  end

      if (entity:IsPlayer()) then -- Player panel size and offset
        surface.SetFont("holohud_small");
        local u, v = surface.GetTextSize(entity:Nick());
        h = P_HEIGHT;
        w = u + MARGIN * 2;
		y = MARGIN + (ScrH() - MARGIN*2 - h) * config("player_offset")
      end

      -- Remove reference if time passed
      if (time < CurTime() and (not HOLOHUD:IsPanelActive(PANEL_NAME) or HOLOHUD.EditMode)) then
        entity = nil;
      end

    end
	
	x = x + (ScrW() - MARGIN*2 - w) * config("h_offset")

    -- Activate and draw panel
    local align = TEXT_ALIGN_TOP;
    if (IsValid(entity) and entity:IsPlayer()) then align = TEXT_ALIGN_BOTTOM; end
    HOLOHUD:SetPanelActive(PANEL_NAME, IsValid(entity) and (entity:IsPlayer() or IsNPC(entity)) and time > CurTime());
    HOLOHUD:DrawFragmentAlign(x, y, w, h, DrawHealth, PANEL_NAME, align, nil, config("alpha"), nil, entity, config("ally"), config("enemy"), config("name"), config("armour"), config("lerp"), config("right_align"), config("var_length"));
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
      h_offset = { name = "Horizontal panel offset", value = 0.5, minValue = 0, maxValue = 1 },
      name = { name = "Name colour", value = Color(255, 255, 255)},
      ally = { name = "Ally colour", value = Color(100, 255, 100) },
      enemy = { name = "Enemy colour", value = Color(255, 100, 72) },
      full_colour = { name = "Full colour", value = HEALTH_FULL },
      good_colour = { name = "Normal colour", value = HEALTH_GOOD },
      warn_colour = { name = "Warning colour", value = HEALTH_WARN },
      crit_colour = { name = "Critical colour", value = HEALTH_CRIT },
      armour = { name = "Armour colour", value = ARMOUR_COLOUR },
      lerp = { name = "Enable smooth animation", value = true },
      right_align = { name = "Right aligned bar", value = false },
      var_length = { name = "More health = longer/multiple bars", value = false }
    },
    DrawPanel
  );

  -- Hide default
  hook.Add("HUDDrawTargetID", "holohud_target", function()
    if (HOLOHUD:IsHUDEnabled()) then return true; end
  end);

end

if SERVER then
  util.AddNetworkString("holohud_target_whatever")
  
  local function SendTarget(ent, ply)
	if !IsValid(ent) or (!ent:IsPlayer() and !IsNPC(ent)) then return end
	local i = ent:EntIndex()
	local health = ent:Health()
	local enemy = ent:IsNPC() and ent:Disposition(ply) == D_HT
	-- print(ents.GetByIndex(i), health)
	net.Start("holohud_target_whatever")
	net.WriteInt(i, 32)
	net.WriteFloat(health)
	net.WriteBool(enemy)
	net.Send(ply)
  end
  
  -- checks players serverside
  hook.Add("Think", "holohud_target_think", function()
    for k, p in pairs(player.GetAll()) do
	  local trace = p:GetEyeTrace();
	  if trace ~= nil then
		local ent = trace.Entity
		SendTarget(ent, p)
	  end
	end
  end)

  -- upon dealing damage, display health momentarily
  hook.Add("PostEntityTakeDamage", "holohud_target_damage", function(target, dmginfo, took)
	if !took then return end
	local attacker = dmginfo:GetAttacker()
	if IsValid(attacker) and attacker:IsPlayer() and attacker != target then
	  SendTarget(target, attacker)
	end
  end)


  -- Use a networked value to know maximum health
  hook.Add("OnEntityCreated", "holohud_target_maxhealth", function(ent)
    if (not IsValid(ent) or ent == NULL or not IsNPC(ent) or ent.Health == nil) then return; end
    timer.Simple(0.1, function()
      if (not IsValid(ent) or ent == NULL or not IsNPC(ent) or ent.Health == nil) then return; end
      ent:SetNWInt(SHARED_VALUE, ent:Health());
    end);
  end);

end
