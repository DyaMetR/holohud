--[[------------------------------------------------------------------
  PLAYER STATUS DISPLAY
  Health and armour display
]]--------------------------------------------------------------------

if CLIENT then

	-- Namespace
	HOLOHUD.ELEMENTS.HEALTH = {};

	-- Panels
	HOLOHUD.ELEMENTS.HEALTH.PANELS = { -- Panel names
		DEFAULT = "health",
		KEVLAR = "armour"
	};

	-- Highlights
	HOLOHUD.ELEMENTS.HEALTH.HIGHLIGHT = { -- Highlight panels
		HEALTH = "health",
		ARMOUR = "armour"
	};

	--[[
	-- Include panels
	include("health/default.lua");
	include("health/heartrate.lua");
	include("health/classic.lua");
	]]

end

HOLOHUD:IncludeFile("health/default.lua");
HOLOHUD:IncludeFile("health/heartrate.lua");
HOLOHUD:IncludeFile("health/classic.lua");

if CLIENT then

	-- Colours
	local HEALTH_GOOD, HEALTH_WARN, HEALTH_CRIT = Color(100, 255, 100, 200), Color(255, 233, 100, 200), Color(255, 100, 72, 200);
	local ARMOUR_COLOUR = Color(100, 166, 255);

	-- Register panels
	HOLOHUD:AddFlashPanel(HOLOHUD.ELEMENTS.HEALTH.PANELS.DEFAULT);
	HOLOHUD:AddFlashPanel(HOLOHUD.ELEMENTS.HEALTH.PANELS.KEVLAR);

	-- Register highlight
	HOLOHUD:AddHighlight(HOLOHUD.ELEMENTS.HEALTH.HIGHLIGHT.HEALTH);
	HOLOHUD:AddHighlight(HOLOHUD.ELEMENTS.HEALTH.HIGHLIGHT.ARMOUR);

	-- Parameters
	local TIME = 5; -- Time to display panel after changing modes
	local ELEMENT_NAME = "health";

	-- Variables
	local tick = 0; -- Low health blink ticker
	local time = 0; -- Display time
	local colour = 0; -- Current health colour
	local lastMode = -1; -- Last mode issued

	--[[
		Highlights the HUD when a variable changes
		@param {number} health
		@param {number} armour
		@param {number} mode
		@void
	]]
	local lastHp, lastAp = 100, 0;
	local function Animate(health, armour, mode)

		-- Mode changes, display new indicators
		if (lastMode ~= mode) then
			if (lastMode > -1) then
				time = CurTime() + TIME;
			end
			lastMode = mode;
		end

		-- Trigger panel if variables change
		if (lastHp ~= health or (lastAp ~= armour and mode ~= 3)) then
			time = CurTime() + 5 + 3 * (1 - (health - 50)/50);

			-- Highlight health
			if (lastHp ~= health) then
				HOLOHUD:TriggerHighlight(HOLOHUD.ELEMENTS.HEALTH.HIGHLIGHT.HEALTH);
				lastHp = health;
			end

			-- Highlight armour
			if (lastAp ~= armour) then
				HOLOHUD:TriggerHighlight(HOLOHUD.ELEMENTS.HEALTH.HIGHLIGHT.ARMOUR);
				lastAp = armour;
			end
		end

		-- Health colour fade out
		if (health > 25 and health < 50) then
			colour = Lerp(FrameTime() * 3, colour, 1);
		elseif (health <= 25) then
			colour = Lerp(FrameTime() * 6, colour, 2);
		else
			colour = Lerp(FrameTime(), colour, 0);
		end

		-- Low health animation
		if (health <= 10 and tick < CurTime()) then
			HOLOHUD:TriggerHighlight(HOLOHUD.ELEMENTS.HEALTH.HIGHLIGHT.HEALTH);
			tick = CurTime() + 0.84;
		end
	end

	--[[
		Returns the current health colour
		@return {Color} colour
	]]
	function HOLOHUD.ELEMENTS.HEALTH:GetHealthColour()
		local healthGood = HOLOHUD.ELEMENTS:ConfigValue(ELEMENT_NAME, "health_good");
		local healthWarn = HOLOHUD.ELEMENTS:ConfigValue(ELEMENT_NAME, "health_warn");
		local healthCrit = HOLOHUD.ELEMENTS:ConfigValue(ELEMENT_NAME, "health_crit");
		local value = 1 - colour;
		if (colour > 1) then
			value = (1 - (colour - 1));
			return HOLOHUD:IntersectColour(healthWarn, healthCrit, value);
		else
			return HOLOHUD:IntersectColour(healthGood, healthWarn, value);
		end
	end

	--[[
		Returns the current armour colour
		@return {Color} colour
	]]
	function HOLOHUD.ELEMENTS.HEALTH:GetArmourColour()
		return HOLOHUD.ELEMENTS:GetElementUserConfigParam(ELEMENT_NAME, "armour");
	end

  --[[
		Animates and draws the full panel
		@param {table} config
		@return {width}
		@return {height}
	]]
	local function DrawPanel(config)
		local health, armour = LocalPlayer():Health(), LocalPlayer():Armor();
		local mode = config("mode");

		-- Animate
		Animate(health, armour, mode);

		-- Should activate
		HOLOHUD:SetPanelActive(HOLOHUD.ELEMENTS.HEALTH.PANELS.DEFAULT, config("always") or time > CurTime() or health < config("hide"));
		HOLOHUD:SetPanelActive(HOLOHUD.ELEMENTS.HEALTH.PANELS.KEVLAR, armour > 0 and mode == 3);

		-- Draw
		if (mode == 1) then
			return HOLOHUD.ELEMENTS.HEALTH:DefaultPanel(math.max(health, 0), armour, config("right_align"));
		elseif (mode == 4) then
			return HOLOHUD.ELEMENTS.HEALTH:ClassicPanel(math.max(health, 0), armour, config("classic_hide_armour"));
		else
			return HOLOHUD.ELEMENTS.HEALTH:HeartratePanel(math.max(health, 0), armour, mode == 3, config("heartrate_hide_number"));
		end

	end

	-- Add element
	HOLOHUD.ELEMENTS:AddElement(ELEMENT_NAME,
		"#holohud.settings.health.name",
		"#holohud.settings.health.description",
		{"CHudHealth", "CHudBattery"},
		{
			always = { name = "#holohud.settings.health.always_displayed", value = false },
			mode = { name = "#holohud.settings.health.mode", value = 1, options = {"#holohud.settings.health.mode.default", "#holohud.settings.health.mode.heart_rate", "#holohud.settings.health.mode.heart_rate_kevlar", "#holohud.settings.health.mode.classic"} },
			hide = { name = "#holohud.settings.health.dont_hide_under", desc = "#holohud.settings.health.dont_hide_under.description", value = 50 },
			classic_hide_armour = { name = "#holohud.settings.health.classic_hide_armour", value = false },
			heartrate_hide_number = { name = "#holohud.settings.health.heart_rate_hide_number", value = false},
			health_good = { name = "#holohud.settings.health.good_color", value = HEALTH_GOOD },
			health_warn = { name = "#holohud.settings.health.warn_color", value = HEALTH_WARN },
			health_crit = { name = "#holohud.settings.health.low_color", value = HEALTH_CRIT },
			armour = { name = "#holohud.settings.health.armor_color", value = ARMOUR_COLOUR },
			right_align = { name = "#holohud.settings.health.right_align", value = false }
		},
		DrawPanel
	);

end
