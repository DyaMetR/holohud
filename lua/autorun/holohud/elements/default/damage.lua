--[[------------------------------------------------------------------
  DAMAGE INDICATOR
  Informs the player about where the damage is coming from
]]--------------------------------------------------------------------

local NET = "holohud_damage";

-- Draw indicators
if CLIENT then

  -- Namespace
  HOLOHUD.ELEMENTS.DAMAGE = {};

  --include("damage/triarrow.lua");
end

HOLOHUD:IncludeFile("damage/triarrow.lua");

if CLIENT then

  -- Parameters
  local HIGHLIGHT = "damage_generic";
  local MAX_COUNT = 6; -- Maximum amount of arrows at the same time
  local MAX_TIME = 7; -- Maximum amount of time an arrow will be present on screen
  local MIN_TIME = 2.66; -- Minimum amount of time an arrow will be present on screen

  -- Textures
  local CORNER_W, CORNER_H = 256, 256; -- Generic indicator size
  local CORNER = surface.GetTextureID("holohud/damage/corner");

  -- Variables
  local damage = {}; -- Damage indicators

  HOLOHUD:AddHighlight(HIGHLIGHT);

  --[[
    Draws the corner indicators
    @param {Color} colour
    @void
  ]]
  local function DrawCornerIndicators(colour)
    local corner = HOLOHUD:GetHighlight(HIGHLIGHT);
    if (corner <= 0) then return; end
    surface.SetDrawColor(Color(colour.r, colour.g, colour.b, 255 * corner));
    surface.SetTexture(CORNER);

    surface.DrawTexturedRectUV(0, 0, CORNER_W, CORNER_H, 0, 1, 1, 0);
    surface.DrawTexturedRectUV(ScrW() - CORNER_W, 0, CORNER_W, CORNER_H, 1, 1, 0, 0);
    surface.DrawTexturedRectUV(0, ScrH() - CORNER_H, CORNER_W, CORNER_H, 0, 0, 1, 1);
    surface.DrawTexturedRectUV(ScrW() - CORNER_W, ScrH() - CORNER_H, CORNER_W, CORNER_H, 1, 0, 0, 1);
  end

  --[[
    Draws all damage indicator elements
    @param {function} config
    @void
  ]]
  local function DrawPanel(config)
    -- Draw indicators
    HOLOHUD.ELEMENTS.DAMAGE:TriArrow(config("distance"), damage, config("colour"));

    -- Generic damage indicator
    DrawCornerIndicators(config("colour"));
  end

  -- Add element
	HOLOHUD.ELEMENTS:AddElement("damage",
		"#holohud.settings.damage.name",
		"#holohud.settings.damage.description",
		"CHudDamageIndicator",
		{
      distance = { name = "#holohud.settings.damage.distance", value = 1, minValue = 0, maxValue = 10 },
      colour = { name = "#holohud.settings.damage.color", value = Color(255, 0, 0) },
      maxCount = { name = "#holohud.settings.damage.limit", desc = "holohud.settings.damage.limit.description", value = MAX_COUNT }
    },
		DrawPanel
	);

  net.Receive(NET, function(len)
    local maxCount = HOLOHUD.ELEMENTS:ConfigValue("damage", "maxCount");
    local relative = Vector(LocalPlayer():GetPos().x, LocalPlayer():GetPos().y, 0);
    local yaw = Angle(0, LocalPlayer():EyeAngles().y, 0);

    if (net.ReadBool()) then
      local pos = WorldToLocal(net.ReadVector(), Angle(0, 0, 0), relative, yaw);
      local amount = net.ReadFloat();
      table.insert(damage, {damage = amount, angle = pos:Angle().y, anim = 0, bright = 0, faded = false, fade = 0, brighted = false, time = CurTime() + math.Clamp(MIN_TIME + MAX_TIME * (amount * 0.01), MIN_TIME, MAX_TIME)});
      if (table.Count(damage) >= maxCount) then
        for i=1, table.Count(damage) - maxCount do
          damage[i].time = -1;
        end
      end
    else
      HOLOHUD:TriggerHighlight(HIGHLIGHT);
    end
  end);

end

-- Receive attacker
if SERVER then

  util.AddNetworkString(NET);

  local DMG_CRUSH_VEHICLE = 17;
  local GENERIC_DAMAGE = {DMG_FALL, DMG_DROWN, DMG_CRUSH, DMG_CRUSH_VEHICLE};

  hook.Add("EntityTakeDamage", "holohud_damage", function(player, damage)
    if (not player:IsPlayer()) then return; end

    net.Start(NET);
    net.WriteBool(damage:GetAttacker() ~= nil and not table.HasValue(GENERIC_DAMAGE, damage:GetDamageType()));

    local attacker = damage:GetAttacker();
    if (attacker ~= nil and attacker:IsNPC() or attacker:IsPlayer() and attacker ~= player) then
      net.WriteVector(attacker:GetPos());
    else
      net.WriteVector(damage:GetDamagePosition());
    end
    net.WriteFloat(damage:GetDamage());
    net.Send(player);
  end);

end
