--[[------------------------------------------------------------------
  TARGET'S HEALTH BAR
  Display's current health of the target you're looking at
]]--------------------------------------------------------------------

local SHARED_VALUE = "holohud_max_health";
local CLASS_NEXTBOT = "nextbot";
local NET = "holohud_target";

--[[
  Returns whether the entity is a non-player-character
  @param {Entity} entity
  @return {boolean} is NPC
]]
local function IsNPC(entity)
  return IsValid(entity) and (entity:IsNPC() or (entity:IsScripted() and entity.Type == CLASS_NEXTBOT));
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
		@param {boolean} is dynamic sizing enabled
    @void
  ]]
  local function DrawHealth(x, y, w, h, target, barCol, enemyCol, nameColour, armourCol, shouldLerp, right_align, bar_length)
    local bright = HOLOHUD:GetHighlight(PANEL_NAME);
    local name, maxHealth, armour = "", -1, -1;
    barCol = barCol or Color(100, 255, 100, 200);
    nameColour = nameColour or Color(255, 255, 255, 200);

    -- Check if target is valid
    if IsValid(target) then
      if (target:IsPlayer()) then
        maxHealth = target:GetMaxHealth();
				health = target:Health()
        armour = target:Armor();
        name = target:Nick();
        barCol = GetHealthColour();
        AnimateColour(health / maxHealth);
      elseif (IsNPC(target)) then
        maxHealth = target:GetNWInt(SHARED_VALUE);
        name = language.GetPhrase(target:GetClass());
        if (enemy) then
          barCol = enemyCol or Color(255, 100, 72, 200);
        end
      end

      -- Trigger highlight
      if (lastHp ~= health) then
        HOLOHUD:TriggerHighlight(PANEL_NAME);
        lastHp = health;
      end

      if (shouldLerp and lerp >= 0) then -- update immediately if we're not focused, otherwise it takes a while
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
		  if bar_length then
			  local bar = HEALTH_MAX
			  local l = lerp
			  local i = 1
			  local barMaxHealth = maxHealth
			  local offset = 0
			  local hp = health
			  while maxHealth > i*bar and i <= 39 do
					offset = 6
					if hp > bar then
						l = l - bar
						barMaxHealth = barMaxHealth - bar
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

				local w2 = math.Clamp(barMaxHealth, 10, HEALTH_MAX) * HEALTH_LENGTH

				-- compensate for right side alignment
				if right_align then
					x = x + w - w2
				end

				-- draw bar on the foreground
			  bar_func(HOLOHUD, x + 7, y + h - 11 - offset, w2, 23, barCol, l / math.min(barMaxHealth, bar), bright);
		  else
				bar_func(HOLOHUD, x + 5, y + h - 11, w + 4, 23, barCol, lerp / maxHealth, bright);
		  end
    end
  end

	-- Receive enemy information
  net.Receive(NET, function(len, ply)
		index = net.ReadInt(32)
		health = net.ReadFloat()
		enemy = net.ReadBool()
    time = CurTime() + TIME
  end)

  --[[
    Controls whether the panel should be drawn, and draws it
    @param {function} configuration
    @void
  ]]
  local offset = 0;
  local function DrawPanel(config)
		local trace = LocalPlayer():GetEyeTrace()

		-- check whether we're looking at a player
		if trace.Hit and trace.Entity:IsPlayer() then
			time = CurTime() + TIME;
			index = trace.Entity:EntIndex();
		end

		-- get entity
    local entity = ents.GetByIndex(index) or nil;

    -- Get screen offset and panel size
    local w, h = WIDTH, HEIGHT;
		local x = MARGIN
		local y = MARGIN + (ScrH() - MARGIN*2 - h) * config("npc_offset")
    if (entity ~= nil) then
		  if IsValid(entity) and config("bar_length") then
			  local maxHealth = entity:GetNWInt(SHARED_VALUE);
			  if maxHealth <= 0 then
					maxHealth = entity:GetMaxHealth()
			  end
			  w = math.Clamp(maxHealth * HEALTH_LENGTH, WIDTH_MIN, HEALTH_MAX * HEALTH_LENGTH)
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
    end

		x = x + (ScrW() - MARGIN*2 - w) * config("h_offset")

    -- Activate and draw panel
    local align = TEXT_ALIGN_TOP;
    if (IsValid(entity) and entity:IsPlayer()) then align = TEXT_ALIGN_BOTTOM; end
    HOLOHUD:SetPanelActive(PANEL_NAME, IsValid(entity) and (entity:IsPlayer() or IsNPC(entity)) and time > CurTime());
    HOLOHUD:DrawFragmentAlign(x, y, w, h, DrawHealth, PANEL_NAME, align, nil, config("alpha"), nil, entity, config("ally"), config("enemy"), config("name"), config("armour"), config("lerp"), config("right_align"), config("bar_length"));
  end

  -- Add element
  HOLOHUD.ELEMENTS:AddElement(PANEL_NAME,
    "#holohud.settings.target_health.name",
    "#holohud.settings.target_health.description",
    nil,
    {
      alpha = { name = "#holohud.settings.target_health.alpha", value = 0.15, minValue = 0, maxValue = 1 },
      npc_offset = { name = "#holohud.settings.target_health.npc_offset", value = 0.16, minValue = 0, maxValue = 1 },
      player_offset = { name = "#holohud.settings.target_health.player_offset", value = 0.63, minValue = 0, maxValue = 1 },
      h_offset = { name = "#holohud.settings.target_health.x", value = 0.5, minValue = 0, maxValue = 1 },
      name = { name = "#holohud.settings.target_health.name_color", value = Color(255, 255, 255)},
      ally = { name = "#holohud.settings.target_health.ally_color", value = Color(100, 255, 100) },
      enemy = { name = "#holohud.settings.target_health.enemy_color", value = Color(255, 100, 72) },
      full_colour = { name = "#holohud.settings.target_health.full_color", value = HEALTH_FULL },
      good_colour = { name = "#holohud.settings.target_health.good_color", value = HEALTH_GOOD },
      warn_colour = { name = "#holohud.settings.target_health.warn_color", value = HEALTH_WARN },
      crit_colour = { name = "#holohud.settings.target_health.low_color", value = HEALTH_CRIT },
      armour = { name = "#holohud.settings.target_health.armor_color", value = ARMOUR_COLOUR },
      lerp = { name = "#holohud.settings.target_health.smooth_animation", value = true },
      right_align = { name = "#holohud.settings.target_health.right_align", value = false },
      bar_length = { name = "#holohud.settings.target_health.dynamic_sizing", value = false }
    },
    DrawPanel
  );

  -- Hide default
  hook.Add("HUDDrawTargetID", "holohud_target", function()
    if (HOLOHUD:IsHUDEnabled()) then return true; end
  end);

end

if SERVER then
	-- register network string
  util.AddNetworkString(NET)

	--[[
		Sends the NPC's information to the player.
		@param {Entity} entity
		@param {Player} player
	]]
  local function SendTarget(ent, ply)
		if not IsNPC(ent) then return; end
		local i = ent:EntIndex();
		local health = ent:Health();
		local enemy = ent:IsNPC() and ent:Disposition(ply) == D_HT;
		net.Start(NET);
		net.WriteInt(i, 32);
		net.WriteFloat(health);
		net.WriteBool(enemy);
		net.Send(ply);
  end

  -- checks players serverside
  hook.Add("Think", "holohud_target_think", function()
    for _, p in pairs(player.GetAll()) do
		  local trace = p:GetEyeTrace();
		  if trace and trace.Hit then
				SendTarget(trace.Entity, p);
		  end
		end
  end)

  -- upon dealing damage, display health momentarily
  hook.Add("PostEntityTakeDamage", "holohud_target_damage", function(target, dmginfo, took)
		if !took then return; end
		local attacker = dmginfo:GetAttacker();
		if IsValid(attacker) and attacker:IsPlayer() and attacker != target then
		  SendTarget(target, attacker);
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
