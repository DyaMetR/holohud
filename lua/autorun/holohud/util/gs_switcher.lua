--[[------------------------------------------------------------------
  code_gs Weapon Switcher Skeleton
  https://github.com/Kefta/Weapon-Switcher-Skeleton
]]--------------------------------------------------------------------

if CLIENT then

  --[[ Config ]]--

  local MAX_SLOTS = 6
  local CACHE_TIME = 1
  local UNABLE_SOUND = "buttons/button2.wav";
  local START_SOUND = "buttons/button3.wav";
  local CANCEL_SOUND = "buttons/button10.wav";
  local MOVE_SOUND = "buttons/button14.wav"; --"Player.WeaponSelectionMoveSlot"
  local SELECT_SOUND = "buttons/button17.wav"; --"Player.WeaponSelected"
  local SOUND_LEVEL = 60;

  --[[ Instance variables ]]--

  local iCurSlot = 0 -- Currently selected slot. 0 = no selection
  local iCurPos = 1 -- Current position in that slot
  local flNextPrecache = 0 -- Time until next precache
  local flSelectTime = 0 -- Time the weapon selection changed slot/visibility states. Can be used to close the weapon selector after a certain amount of idle time
  local iWeaponCount = 0 -- Total number of weapons on the player

  -- Weapon cache; table of tables. tCache[Slot + 1] contains a table containing that slot's weapons. Table's length is tCacheLength[Slot + 1]
  local tCache = {}

  -- Weapon cache length. tCacheLength[Slot + 1] will contain the number of weapons that slot has
  local tCacheLength = {}

  --[[ Weapon switcher ]]--

  local function DrawWeaponHUD(config)
  	HOLOHUD:DrawWeaponSelector(config("x"), config("y"), tCache, iCurSlot, iCurPos, tCacheLength, config);
  end

  -- Add element
  HOLOHUD.ELEMENTS:AddElement("weapon_selector",
    "Weapon selector",
    "Allows the user to switch between the weapons they currently hold",
    nil,
    {
      alpha = {name = "Background opacity", value = 0.1725, maxValue = 1},
      animation = {name = "Toggle animations", desc = "Animations that play every time you open and/or navigate the inventory", value = true},
      x = {name = "Horizontal margin", value = ScrH() * 0.1, maxValue = ScrW()},
      y = {name = "Vertical margin", value = ScrH() * 0.1, maxValue = ScrH()},
      volume = {name = "Sound volume", value = 1, minValue = 0, maxValue = 2},
      colour = { name = "Colour", value = Color(255, 255, 255) },
      ammo_colour = { name = "Ammo bar colour", value = AMMO_COLOUR },
      crit_colour = { name = "Out of ammo colour", value = Color(255, 0, 0)},
      weapon_details = { name = "Draw weapon details", value = false }
    }, DrawWeaponHUD
  );

  -- Make sure it draws when the camera is equipped
  hook.Add("DrawOverlay", "holohud_camera_weapon_selector", function()
    if (LocalPlayer().GetActiveWeapon == nil) then return; end
    if (not IsValid(LocalPlayer():GetActiveWeapon()) or LocalPlayer():GetActiveWeapon():GetClass() ~= "gmod_camera") then return; end
    DrawWeaponHUD(function(param) return HOLOHUD.ELEMENTS:ConfigValue("weapon_selector", param); end);
  end);

  --[[ Implementation ]]--

  -- Initialize tables with slot number
  for i = 1, MAX_SLOTS do
  	tCache[i] = {}
  	tCacheLength[i] = 0
  end

  local pairs = pairs
  local tonumber = tonumber
  local RealTime = RealTime
  local hook_Add = hook.Add
  local LocalPlayer = LocalPlayer
  local string_lower = string.lower
  local input_SelectWeapon = input.SelectWeapon
  local hud_fastswitch = GetConVar("hud_fastswitch");

  -- Hide the default weapon selection
  hook_Add("HUDShouldDraw", "HOLOHUD_GS_WeaponSelector", function(sName)
    if (not HOLOHUD:IsHUDEnabled() or not HOLOHUD.ELEMENTS:IsElementEnabled("weapon_selector") or hud_fastswitch:GetInt() > 0) then return; end
  	if (sName == "CHudWeaponSelection") then
  		return true
  	end
  end)

  local function PrecacheWeps()
  	-- Reset all table values
  	for i = 1, MAX_SLOTS do
  		for j = 1, tCacheLength[i] do
  			tCache[i][j] = nil
  		end

  		tCacheLength[i] = 0
  	end

  	-- Update the cache time
  	flNextPrecache = RealTime() + CACHE_TIME
  	iWeaponCount = 0

  	-- Discontinuous table
  	for _, pWeapon in pairs(LocalPlayer():GetWeapons()) do
  		iWeaponCount = iWeaponCount + 1

  		-- Weapon slots start internally at "0"
  		-- Here, we will start at "1" to match the slot binds
  		local iSlot = pWeapon:GetSlot() + 1

  		if (iSlot <= MAX_SLOTS) then
  			-- Cache number of weapons in each slot
  			local iLen = tCacheLength[math.max(iSlot, 0)] + 1
  			tCacheLength[iSlot] = iLen
  			tCache[iSlot][iLen] = pWeapon
  		end
  	end

    -- Sort the weapon cache by slotPos
    for i=1, MAX_SLOTS do
      table.sort( tCache[i], function( a, b ) return a:GetSlotPos() < b:GetSlotPos() end );
    end

  	-- Make sure we're not pointing out of bounds
  	if (iCurSlot ~= 0) then
  		local iLen = tCacheLength[iCurSlot]

  		if (iLen < iCurPos) then
  			if (iLen == 0) then
  				iCurSlot = 0
  			else
  				iCurPos = iLen
  			end
  		end
  	end
  end

  local cl_drawhud = GetConVar("cl_drawhud");

  -- Draw weapon selector
  hook_Add("HUDPaint", "HOLOHUD_GS_WeaponSelector", function()
    if (not HOLOHUD:IsHUDEnabled() or not HOLOHUD.ELEMENTS:IsElementEnabled("weapon_selector")) then return; end

    -- Should HUD draw?
    if (iCurSlot == 0 or not cl_drawhud:GetBool() or hud_fastswitch:GetInt() > 0) then
  		return
  	end

  	local pPlayer = LocalPlayer();

  	-- Don't draw in vehicles unless weapons are allowed to be used
  	-- Or while dead!
  	if (pPlayer:IsValid() and pPlayer:Alive() and (not pPlayer:InVehicle() or pPlayer:GetAllowWeaponsInVehicle())) then
  		if (flNextPrecache <= RealTime()) then
  			PrecacheWeps()
  		end
  	else
  		iCurSlot = 0
  	end
  end)

  --[[
    Override AddPlayerOption so it doesn't conflict with the weapon selector
    @experimental
  ]]
  local MetaPlayer = FindMetaTable("Player");
  local addOptionFunction = MetaPlayer.AddPlayerOption;
  local votes = {};
  function MetaPlayer:AddPlayerOption(title, timeout, usrCallback, optionsDraw)
    votes[title] = true;
    function callback(num)
      local result = usrCallback(num);
      if result then
        votes[title] = nil;
      end
      return result;
    end
    addOptionFunction(self, title, timeout, callback, optionsDraw);
  end

  --[[
    Returns whether the current weapon is ACT3 based and whether the inventory is open
    @return {boolean} is ACT3
  ]]
  local function isACT3()
    local pActiveWeapon = LocalPlayer():GetActiveWeapon();
    return IsValid(pActiveWeapon) and (pActiveWeapon.ACT3Weapon ~= nil and pActiveWeapon.ACT3Weapon and pActiveWeapon.State == 4);
  end

  --[[
    Returns whether the current weapon is an ArcCW and the player is scoped in
    @return {boolean} is ArcCW scoped in
  ]]
  local function isArcCWScope()
    local pActiveWeapon = LocalPlayer():GetActiveWeapon();
    return IsValid(pActiveWeapon) and pActiveWeapon.ArcCW and pActiveWeapon:GetState() == ArcCW.STATE_SIGHTS and pActiveWeapon:GetActiveSights().ScrollFunc == ArcCW.SCROLL_ZOOM
  end

  --[[
    Returns whether the mouse wheel can be used
    @return {boolean} can be used
  ]]
  local function canUseWheel()
    local drone = LocalPlayer():GetNWEntity("DronesRewriteDrone");
    local isDrone = IsValid(drone) and drone ~= nil;
    local pActiveWeapon = LocalPlayer():GetActiveWeapon();
    local wireEnt = nil;
    local inp, outs = nil, nil;
    local isWire = false;
    if (IsValid(pActiveWeapon) and LocalPlayer().GetTool ~= nil) then
      wireEnt = pActiveWeapon.CurrentEntity or pActiveWeapon:GetOwner():GetEyeTrace().Entity;
      if (LocalPlayer():GetTool("wire_adv") ~= nil and LocalPlayer():GetTool("wire_adv").GetPorts ~= nil and wireEnt ~= nil) then inp, outs = LocalPlayer():GetTool("wire_adv"):GetPorts(wireEnt); end
      isWire = pActiveWeapon:GetClass() == "gmod_tool" and (inp ~= nil and outs ~= nil);
    end

    return not isACT3() and not isDrone and not isWire and not isArcCWScope();
  end

  --[[
    Returns whether the number for slots can be used
    @return {boolean} can be used
  ]]
  local function canUseSlots()
    local pActiveWeapon = LocalPlayer():GetActiveWeapon();
    local isCW20 = IsValid(pActiveWeapon) and (pActiveWeapon.CW20Weapon ~= nil and pActiveWeapon.CW20Weapon and pActiveWeapon.dt.State == 4);

    return not isCW20 and not isACT3() and table.IsEmpty(votes);
  end

  -- Bind press
  local lSlot = 0;
  hook_Add("PlayerBindPress", "HOLOHUD_GS_WeaponSelector", function(pPlayer, sBind, bPressed)
    if (not HOLOHUD:IsHUDEnabled() or not HOLOHUD.ELEMENTS:IsElementEnabled("weapon_selector") or hud_fastswitch:GetInt() > 0) then return; end

    -- Arctic Stims
    local arcStimBind = input.LookupBinding('+arc_vm_medshot')
    if arcStimBind and input.IsKeyDown(input.GetKeyCode(arcStimBind)) then return end

    -- Don't show if physgun is in use
    local hasPhysgun = IsValid(pPlayer:GetActiveWeapon()) and (pPlayer:KeyDown(IN_ATTACK) or pPlayer:KeyDown(IN_ATTACK2)) and pPlayer:GetActiveWeapon():GetClass() == "weapon_physgun";
    if (hasPhysgun and (sBind == "invprev" or sBind == "invnext")) then return true; end

    if (not pPlayer:Alive() or (pPlayer:InVehicle() and not pPlayer:GetAllowWeaponsInVehicle())) then
  		return
  	end

  	sBind = string_lower(sBind)

    -- Get the sound volume
    local volume = HOLOHUD.ELEMENTS:ConfigValue("weapon_selector", "volume") or 1;

  	-- Close the menu
  	if (sBind == "cancelselect") then
  		if (bPressed) then
  			iCurSlot = 0
  		end

  		return true
  	end

  	-- Move to the weapon before the current
  	if (sBind == "invprev" and canUseWheel()) then
  		if (not bPressed) then
  			return true
  		end

  		PrecacheWeps()

  		if (iWeaponCount == 0) then
  			return true
  		end

  		local bLoop = iCurSlot == 0

  		if (bLoop) then
  			local pActiveWeapon = pPlayer:GetActiveWeapon()

  			if (pActiveWeapon:IsValid()) then
  				local iSlot = pActiveWeapon:GetSlot() + 1
  				local tSlotCache = tCache[iSlot]

  				if (tSlotCache[1] ~= pActiveWeapon) then
  					iCurSlot = iSlot
  					iCurPos = 1

  					for i = 2, tCacheLength[iSlot] do
  						if (tSlotCache[i] == pActiveWeapon) then
  							iCurPos = i - 1

  							break
  						end
  					end

  					flSelectTime = RealTime()
  					pPlayer:EmitSound(MOVE_SOUND, SOUND_LEVEL, 200, math.Clamp(volume, 0, 1), CHAN_AUTO)

  					return true
  				end

  				iCurSlot = iSlot
  			end
  		end

  		if (bLoop or iCurPos == 1) then
  			repeat
  				if (iCurSlot <= 1) then
  					iCurSlot = MAX_SLOTS
  				else
  					iCurSlot = iCurSlot - 1
  				end
  			until(tCacheLength[iCurSlot] ~= 0)

  			iCurPos = tCacheLength[iCurSlot]
  		else
  			iCurPos = iCurPos - 1
  		end

  		flSelectTime = RealTime()
  		pPlayer:EmitSound(MOVE_SOUND, SOUND_LEVEL, 200, math.Clamp(volume, 0, 1), CHAN_AUTO)

  		return true
  	end

  	-- Move to the weapon after the current
  	if (sBind == "invnext" and canUseWheel()) then
  		if (not bPressed) then
  			return true
  		end

  		PrecacheWeps()

  		-- Block the action if there aren't any weapons available
  		if (iWeaponCount == 0) then
  			return true
  		end

  		-- Lua's goto can't jump between child scopes
  		local bLoop = iCurSlot == 0

  		-- Weapon selection isn't currently open, move based on the active weapon's position
  		if (bLoop) then
  			local pActiveWeapon = pPlayer:GetActiveWeapon()

  			if (pActiveWeapon:IsValid()) then
  				local iSlot = pActiveWeapon:GetSlot() + 1
  				local iLen = tCacheLength[iSlot]
  				local tSlotCache = tCache[iSlot]

  				if (tSlotCache[iLen] ~= pActiveWeapon) then
  					iCurSlot = iSlot
  					iCurPos = 1

  					for i = 1, iLen - 1 do
  						if (tSlotCache[i] == pActiveWeapon) then
  							iCurPos = i + 1

  							break
  						end
  					end

  					flSelectTime = RealTime()
  					pPlayer:EmitSound(MOVE_SOUND, SOUND_LEVEL, 200, math.Clamp(volume, 0, 1), CHAN_AUTO)

  					return true
  				end

  				-- At the end of a slot, move to the next one
  				iCurSlot = iSlot
  			end
  		end

  		if (bLoop or iCurPos == tCacheLength[iCurSlot]) then
  			-- Loop through the slots until one has weapons
  			repeat
  				if (iCurSlot == MAX_SLOTS) then
  					iCurSlot = 1
  				else
  					iCurSlot = iCurSlot + 1
  				end
  			until(tCacheLength[iCurSlot] ~= 0)

  			-- Start at the beginning of the new slot
  			iCurPos = 1
  		else
  			-- Bump up the position
  			iCurPos = iCurPos + 1
  		end

  		flSelectTime = RealTime()
  		pPlayer:EmitSound(MOVE_SOUND, SOUND_LEVEL, 200, math.Clamp(volume, 0, 1), CHAN_AUTO)

  		return true
  	end

  	-- Keys 1-6
    if (sBind:sub(1, 4) == "slot" and canUseSlots()) then
  		local iSlot = tonumber(sBind:sub(5))

  		-- If the command is slot#, use it for the weapon HUD
  		-- Otherwise, let it pass through to prevent false positives
  		if (iSlot == nil or iSlot <= 0 or iSlot > MAX_SLOTS) then
  			return
  		end

  		if (not bPressed) then
  			return true
  		end

  		PrecacheWeps()

      if (iCurSlot == 0 and (tCacheLength[iSlot] == nil or tCacheLength[iSlot] > 0)) then
        pPlayer:EmitSound(START_SOUND, SOUND_LEVEL, 50, math.Clamp(0.33 * volume, 0, 1));
      end

  		-- Play a sound even if there aren't any weapons in that slot for "haptic" (really auditory) feedback
  		if (iWeaponCount == 0 or tCacheLength[iSlot] <= 0) then
  			pPlayer:EmitSound(UNABLE_SOUND, SOUND_LEVEL, 175, math.Clamp(0.46 * volume, 0, 1), CHAN_AUTO);

  			return true
  		end

  		-- If the slot number is in the bounds
  		if (iSlot <= MAX_SLOTS) then
        if (iCurSlot > 0) then
          pPlayer:EmitSound(MOVE_SOUND, SOUND_LEVEL, 200, math.Clamp(0.66 * volume, 0, 1), CHAN_AUTO);
        end

  			-- If the slot is already open
  			if (iSlot == iCurSlot) then
  				-- Start back at the beginning
  				if (iCurPos == tCacheLength[iCurSlot]) then
  					iCurPos = 1
  				-- Move one up
  				else
  					iCurPos = iCurPos + 1
  				end
  			-- If there are weapons in this slot, display them
  			elseif (tCacheLength[iSlot] ~= 0) then
  				iCurSlot = iSlot
  				iCurPos = 1
  			end

  			flSelectTime = RealTime()
  		end

  		return true
  	end

  	-- If the weapon selection is currently open
  	if (iCurSlot ~= 0) then
  		if (sBind == "+attack") then
  			-- Hide the selection
  			local pWeapon = tCache[iCurSlot][iCurPos]
  			iCurSlot = 0

  			-- If the weapon still exists and isn't the player's active weapon
  			if (pWeapon:IsValid() and pWeapon ~= pPlayer:GetActiveWeapon()) then
  				input_SelectWeapon(pWeapon)
  			end

  			flSelectTime = RealTime()
  			pPlayer:EmitSound(SELECT_SOUND, SOUND_LEVEL, 200, math.Clamp(0.33 * volume, 0, 1), CHAN_AUTO)

  			return true
  		end

  		-- Another shortcut for closing the selection
  		if (sBind == "+attack2") then
  			flSelectTime = RealTime()
  			iCurSlot = 0

        pPlayer:EmitSound(CANCEL_SOUND, SOUND_LEVEL, 166, math.Clamp(0.88 * volume, 0, 1), CHAN_AUTO);

  			return true
  		end
  	end
  end);
end
