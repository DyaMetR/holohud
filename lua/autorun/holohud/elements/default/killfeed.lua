--[[------------------------------------------------------------------
  KILLFEED
  Displays a list of lethal PvP, PvE or EvE encounters
]]--------------------------------------------------------------------

local NET = "killfeed";

if CLIENT then

  -- Parameters
  local PANEL_NAME = "killfeed";
  local PANEL_SUBFIX = "killfeed_";
  local FONT = "holohud_killfeed";
  local TIME = 7;
  local HEIGHT, VER_MARGIN, HOR_MARGIN, OUT_MARGIN = 24, 2, 6, 7;
  local SCREEN_OFFSET = 20;
  local UNKNOWN = "worldspawn";
  local WEAPON_COLOUR, NPC_COLOUR = Color(255, 255, 255), Color(255, 100, 100);
  local BREAK_LINE = "\n";

  -- Variables
  local killfeed = {};

  --[[
    Removes \n from a string and trims it
    @param {string} string
    @return {string} trimmed string
  ]]
  local function TrimString(string)
    return string.Trim(string.Replace(string, BREAK_LINE, " "));
  end

  --[[
    Adds a kill to the tray
    @param {string} attacker's name
    @param {string} weapon's name
    @param {string} victim's name
    @param {boolean} was it a suicide
    @param {boolean} was the attacker the same as the inflictor
    @param {Color} attacker's colour
    @param {Color} victim's colour
    @void
  ]]
  local function AddKill(attacker, weapon, victim, suicide, sameAsAttack, isWeapon, attackerColour, victimColour)
    if (sameAsAttack) then weapon = UNKNOWN; end
    table.insert(killfeed, {attacker = attacker, weapon = weapon, victim = victim, suicide = suicide, sameAsAttack = sameAsAttack, isWeapon = isWeapon, attCol = attackerColour, vicCol = victimColour, time = CurTime() + TIME});
    HOLOHUD:AddFlashPanel(PANEL_SUBFIX .. table.Count(killfeed));
  end

  --[[
    Removes a kill from the tray
    @param {number} i
    @void
  ]]
  local function RemoveKill(pos)
    table.remove(killfeed, pos);
    HOLOHUD:RemovePanel(PANEL_SUBFIX .. pos);

    -- Rename the followed panels
    for i=pos + 1, table.Count(killfeed) + 1 do
      HOLOHUD:RenamePanel(PANEL_SUBFIX .. i, PANEL_SUBFIX .. i - 1);
    end
  end

  --[[
    Animates and controls the killfeed lifetime
    @void
  ]]
  local function Animate(limit)
    for i, kill in pairs(killfeed) do
      -- Reset time if it hasn't been shown yet
      if (i > limit and limit > 0) then
        killfeed[i].time = CurTime() + TIME;
      end

      -- Draw and remove if the time has passed
      HOLOHUD:SetPanelActive(PANEL_SUBFIX .. i, kill.time >= CurTime() and ((i <= limit and limit > 0) or limit <= 0), true);
      if (kill.time < CurTime() and not HOLOHUD:IsPanelActive(PANEL_SUBFIX .. i)) then
        RemoveKill(i);
      end
    end
  end

  --[[
    Draws a kill feed entry
    @param {number} x
    @param {number} y
    @param {number} w
    @param {number} h
    @param {string} attacker
    @param {string} weapon class
    @param {string} weapon name
    @param {string} victim
    @param {boolean} was it a suicide
    @param {Color} attacker's colour
    @param {Color} victim's colour
    @param {Color} weapon's colour
    @void
  ]]
  local function DrawKill(x, y, w, h, attacker, wepClass, printName, victim, suicide, attCol, vicCol, wepCol)
    wepCol = wepCol or WEAPON_COLOUR;

    -- Get offset and sizes
    surface.SetFont(FONT);
    local att, wep, vic = language.GetPhrase(attacker), "[" .. printName .. "]", language.GetPhrase(victim);
    local offset = surface.GetTextSize(att);
    local weaponWidth = surface.GetTextSize(wep);

    -- Get excess of height in weapon name
    local u, v = surface.GetTextSize(wep);
    if (v > draw.GetFontHeight(FONT)) then wep = printName; end

    -- Was it a suicide
    if (suicide) then offset = -HOR_MARGIN; att = ""; end

    -- Draw attacker's name
    HOLOHUD:DrawText(x + OUT_MARGIN, y + (h * 0.5) - 1, att, FONT, attCol, 0, nil, TEXT_ALIGN_CENTER);

    -- Draw kill icon
    if (HOLOHUD.ICONS:HasKillIcon(wepClass)) then
      HOLOHUD.ICONS:DrawKillIcon(x + OUT_MARGIN + HOR_MARGIN + offset, y + (h * 0.5) + 1, wepClass, nil, TEXT_ALIGN_CENTER, wepCol);
      weaponWidth = HOLOHUD.ICONS:GetIconSize(HOLOHUD.ICONS.KillIcons, wepClass);
    else
      HOLOHUD:DrawText(x + OUT_MARGIN + offset + (weaponWidth * 0.5) + HOR_MARGIN, y + (h * 0.5) - 1, wep, FONT, wepCol, 0, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER);
    end

    -- Draw victim's name
    HOLOHUD:DrawText(x + OUT_MARGIN + offset + weaponWidth + (HOR_MARGIN * 2), y + (h * 0.5) - 1, vic, FONT, vicCol, 0, nil, TEXT_ALIGN_CENTER);
  end

  --[[
    Animates and draws the panel
    @param {config}
    @return {number} w
    @return {number} h
  ]]
  local function DrawPanel(config)
    -- Animate
    Animate(config("limit"));

    -- Offset
    local offset = 0;
    if (HOLOHUD.ELEMENTS:IsElementEnabled("compass")) then
      local w, h = HOLOHUD.ELEMENTS:GetElementSize("compass");
      offset = offset + h + 35;
    else
      if (HOLOHUD:IsPanelActive("ping")) then
        local w, h = HOLOHUD.ELEMENTS:GetElementSize("ping");
        offset = offset + h + 5;
      end
    end


    -- Draw the killfeed
    local y = 0;
    for i, kill in pairs(killfeed) do
      -- Get size
      surface.SetFont(FONT);

      -- Weapon print name
      local wepClass = kill.weapon;
      local printName = language.GetPhrase(wepClass);
      if (config("escape")) then printName = TrimString(printName); end
      if (string.len(printName) <= 0 or (not kill.isWeapon and printName == wepClass)) then
        if (config("unknown")) then
          wepClass = UNKNOWN;
        else
          printName = wepClass;
        end
      end

      -- Height
      local h = HEIGHT;
      local u, v = surface.GetTextSize(printName);
      if (v > draw.GetFontHeight(FONT)) then h = v; end

      -- Attacker name size
      local attW = surface.GetTextSize(language.GetPhrase(kill.attacker));
      if (kill.suicide) then attW = -HOR_MARGIN; end

      -- Base width
      local w = surface.GetTextSize(language.GetPhrase(kill.victim)) +
                (HOR_MARGIN * 2) + (OUT_MARGIN * 2) + attW;

      -- If weapon is the same as attacker
      if (kill.sameAsAttack and HOLOHUD.ICONS:HasKillIcon(kill.attacker)) then wepClass = kill.attacker; end

      -- Either kill icon or name
      if (HOLOHUD.ICONS:HasKillIcon(wepClass)) then
        w = w + HOLOHUD.ICONS:GetIconSize(HOLOHUD.ICONS.KillIcons, wepClass) + 3;
      else
        w = w + surface.GetTextSize("[" .. printName .. "]");
      end

      -- Draw
      HOLOHUD:DrawFragmentAlign(ScrW() - SCREEN_OFFSET - w, SCREEN_OFFSET + y + offset + (VER_MARGIN * (i - 1)), w, h, DrawKill, PANEL_SUBFIX .. i, TEXT_ALIGN_RIGHT, nil, nil, 1, kill.attacker, wepClass, printName, kill.victim, kill.suicide, kill.attCol, kill.vicCol, config("colour"));
      y = y + h;
    end
  end

  -- Add element
	HOLOHUD.ELEMENTS:AddElement(PANEL_NAME,
		"Killfeed",
		"List of lethal PvP, PvE or EvE encounters",
		nil,
		{
      limit = { name = "Max. entries (0 = unlimited)", value = 0, minValue = 0, maxValue = math.Round(ScrH() / HEIGHT) },
      escape = { name = "Remove line breaks", desc = "Places the weapon/inflictor name in one line", value = true },
      unknown = { name = "Generic icon if unnamed", desc = "Will place a generic death icon if the entity does not have a name registered", value = true },
      colour = { name = "Weapon colour", value = WEAPON_COLOUR }
    },
    DrawPanel
	);

  -- Hide default
  hook.Add("DrawDeathNotice", "holohud_killfeed", function(x, y)
    if (not HOLOHUD:IsHUDEnabled() or not HOLOHUD.ELEMENTS:IsElementEnabled(PANEL_NAME)) then return end;
    return false;
  end);

  -- Receive kill feed data
  net.Receive(NET, function(len)
    -- Data
    local attacker = net.ReadString();
    local attTeam = net.ReadFloat();
    local suicide = net.ReadBool();
    local isWeapon = net.ReadBool();
    local weapon = "player";
    if (isWeapon) then
      local ent = net.ReadEntity();
      if (IsValid(ent) and ent ~= nil) then
        weapon = ent:GetPrintName();
      end
    else
      weapon = net.ReadString();
    end
    local same = net.ReadBool();
    local victim = net.ReadString();
    local vicTeam = net.ReadFloat();

    -- Colours
    local attCol = NPC_COLOUR;
    local vicCol = NPC_COLOUR;

    if (attTeam > -1) then
      attCol = team.GetColor(attTeam);
    end

    if (vicTeam > -1) then
      vicCol = team.GetColor(vicTeam);
    end

    -- Add kill
    AddKill(attacker, weapon, victim, suicide, same, isWeapon, attCol, vicCol);
  end);

end

if SERVER then

  util.AddNetworkString(NET);

  -- Parameters
  local TARGET = "npc_bullseye";

  --[[
    Sends a kill to the players
    @param {Player|Entity} attacker
    @param {Weapon|Entity} weapon
    @param {Player|Entity} victim
  ]]
  local function SendKillfeed(attacker, inflictor, victim)
    if (IsValid(attacker) and attacker:GetClass() == TARGET) or (IsValid(victim) and victim:GetClass() == TARGET) then return; end

    net.Start(NET);

    -- If attacker and/or inflictor aren't valid, subtitute them for the victim
    if (not IsValid(attacker)) then
      attacker = victim;
    end

    if (not IsValid(inflictor)) then
      inflictor = victim;
    end

    -- Attacker's name and team
    if (attacker:IsPlayer()) then
      net.WriteString(attacker:Name());
      net.WriteFloat(attacker:Team());
    else
      net.WriteString(attacker:GetClass());
      net.WriteFloat(-1);
    end

    -- Has the victim suicided?
    net.WriteBool(attacker == victim);

    -- Weapon used

    if (inflictor:IsPlayer() and IsValid(inflictor:GetActiveWeapon())) then
      net.WriteBool(true); -- Is it a weapon?
      net.WriteEntity(inflictor:GetActiveWeapon()); -- Send the entity
      net.WriteBool(false); -- Was it a suicide?
    else
      net.WriteBool(false); -- Is it a weapon?
      net.WriteString(inflictor:GetClass()); -- Send the class name
      net.WriteBool(inflictor == attacker); -- Was it a suicide?
    end

    -- Victim's name and team
    if (victim:IsPlayer()) then
      net.WriteString(victim:Name());
      net.WriteFloat(victim:Team());
    else
      net.WriteString(victim:GetClass());
      net.WriteFloat(-1);
    end

    net.Broadcast();
  end

  -- NPC killed
  hook.Add("OnNPCKilled", "holohud_killfeed_npc", function(npc, attacker, inflictor)
    SendKillfeed(attacker, inflictor, npc);
  end);

  -- Player killed
  hook.Add("PlayerDeath", "holohud_killfeed_player", function(player, inflictor, attacker)
    SendKillfeed(attacker, inflictor, player);
  end);

end
