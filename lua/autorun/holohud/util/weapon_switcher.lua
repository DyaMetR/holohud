--[[------------------------------------------------------------------
  DyaMetR's weapon switcher script
  September 19th, 2021

  API to be used in a custom weapon selector.
]]--------------------------------------------------------------------

if SERVER then return end -- do not run on server

-- Configuration
local MAX_SLOTS = 6 -- maximum number of weapon slots

-- Constants
local PHYSICS_GUN, CAMERA = 'weapon_physgun', 'gmod_camera'
local SLOT, INV_PREV, INV_NEXT, ATTACK, ATTACK2 = 'slot', 'invprev', 'invnext', '+attack', '+attack2'

-- Variables
local curSlot = 0 -- current slot selected
local curPos = 0 -- current weapon position selected
local weaponCount = 0 -- current weapon count
local cache = {} -- cached weapons sorted per slot
local cacheLength = {} -- how many weapons are there in each slot
local weaponPos = {} -- assigned table position in slot

-- Initialize cache
for slot = 1, MAX_SLOTS do
  cache[slot] = {}
  cacheLength[slot] = 0
end

--[[------------------------------------------------------------------
  Sorting function to order a weapon inventory slot by slot position
  @param {Weapon} a
  @param {Weapon} b
]]--------------------------------------------------------------------
local function sortWeaponSlot(a, b)
  return a:GetSlotPos() < b:GetSlotPos()
end

--[[------------------------------------------------------------------
  Caches the current weapons the player has
  @param {boolean} force cache
]]--------------------------------------------------------------------
local function cacheWeapons(force)
  -- get current weapons
  local weapons = LocalPlayer():GetWeapons()

  -- only cache when weapon count is different
  if not force and weaponCount == #weapons then return end

  -- reset cache
  for slot = 1, MAX_SLOTS do
    for pos = 0, cacheLength[slot] do
      cache[slot][pos] = nil
    end
    cacheLength[slot] = 0
  end
  table.Empty(weaponPos)

  -- update weapon count
  weaponCount = #weapons

  -- add weapons
  for _, weapon in pairs(weapons) do
    -- weapon slots start at 0, so we need to make it start at 1 because of lua tables
    local slot = weapon:GetSlot() + 1

    -- do not add if the slot is out of bounds
    if slot <= 0 or slot > MAX_SLOTS then continue end

    -- cache weapon
    table.insert(cache[slot], weapon)
    cacheLength[slot] = cacheLength[slot] + 1
  end

  -- sort slots
  for slot = 1, MAX_SLOTS do
    table.sort(cache[slot], sortWeaponSlot)

    -- get sorted weapons' positions
    for pos, weapon in pairs(cache[slot]) do
      weaponPos[weapon] = pos
    end
  end

  -- check whether we're out of bounds
  if curSlot > 0 then
    if weaponCount <= 0 then
      curSlot = 0
      curPos = 1
    else
      curPos = math.min(curPos, cacheLength[curSlot])
    end
  end
end

--[[------------------------------------------------------------------
  Finds the next slot with weapons
  @param {number} starting slot
  @param {boolean} move forward
  @return {number} slot found
]]--------------------------------------------------------------------
local function findSlot(slot, forward)
  -- do not search if there are no weapons
  if weaponCount <= 0 then return slot end

  -- otherwise, search for the next slot with weapons
  while (not cacheLength[slot] or cacheLength[slot] <= 0) do
    if forward then
      if slot < MAX_SLOTS then
        slot = slot + 1
      else
        slot = 1
      end
    else
      if slot > 1 then
        slot = slot - 1
      else
        slot = MAX_SLOTS
      end
    end
  end

  return slot
end

--[[------------------------------------------------------------------
  Finds the next weapon with ammo to select
  @param {number} starting slot
  @param {number} starting slot position
  @param {boolean} move forward
  @return {number} slot found
  @return {number} slot position found
]]--------------------------------------------------------------------
local function findWeapon(slot, pos, forward)
  -- do not search if there are no weapons
  if weaponCount <= 0 then return slot, pos end

  if forward then
    if pos < cacheLength[slot] then
      pos = pos + 1
    else
      pos = 1
      slot = findSlot(slot + 1, true)
    end
  else
    if pos > 1 then
      pos = pos - 1
    else
      slot = findSlot(slot - 1, false)
      pos = cacheLength[slot]
    end
  end

  return slot, pos
end

--[[------------------------------------------------------------------
  Moves the cursor one position going to across all slots
  @param {boolean} move forward
]]--------------------------------------------------------------------
local function moveCursor(forward)
  -- do not move cursor if there are no weapons to cycle through
  if weaponCount <= 0 then return end

  -- if slot is out of bounds, get the current weapon's
  if curSlot <= 0 then
    local weapon = LocalPlayer():GetActiveWeapon()

    -- if there are no weapons equipped, start at the first slot
    if IsValid(weapon) then
      -- check if the weapon has been cached -- otherwise recache again
      if not weaponPos[weapon] then cacheWeapons(true) end

      -- get weapon data
      curSlot = math.Clamp(weapon:GetSlot() + 1, 1, MAX_SLOTS)
      curPos = math.Clamp(weaponPos[weapon] or 0, 0, cacheLength[curSlot])
    else
      curSlot = 1
      curPos = 0
    end
  end

  -- move cursor
  curSlot, curPos = findWeapon(curSlot, curPos, forward)
end

--[[------------------------------------------------------------------
  Moves the cursor inside a slot
  @param {number} slot
]]--------------------------------------------------------------------
local function cycleSlot(slot)
  -- do not move cursor if there are no weapons to cycle through
  if cacheLength[slot] <= 0 then
    curSlot = slot
    curPos = 0
    return
  end

  -- if current slot is out of bounds
  if curSlot <= 0 then
    local weapon = LocalPlayer():GetActiveWeapon()
    -- check if the weapon has been cached -- otherwise recache again
    if not weaponPos[weapon] then cacheWeapons(true) end

    -- if there are no weapons equipped, start at the first pos
    if IsValid(weapon) and weapon:GetSlot() == slot - 1 then
      curPos = weaponPos[weapon] - 1
    else
      curPos = 0
    end

    curSlot = slot
  else
    -- if the slot is different from what it was, reset position
    if curSlot ~= slot then
      curPos = 0
      curSlot = slot
    end
  end

  -- cycle through slot
  if curPos < cacheLength[curSlot] then
    curPos = curPos + 1
  else
    curPos = 1
  end
end

--[[------------------------------------------------------------------
  Selects the weapon highlighted in the switcher
]]--------------------------------------------------------------------
local function equipSelectedWeapon()
  local weapon = cache[curSlot][curPos]
  if not weapon or not IsValid(weapon) then return end
  input.SelectWeapon(weapon)
end

--[[------------------------------------------------------------------
  Implementation
]]--------------------------------------------------------------------

local cl_drawhud = GetConVar('cl_drawhud')
local hud_fastswitch = GetConVar('hud_fastswitch')
local ELEMENT_NAME = 'weapon_selector'

-- sounds
local UNABLE_SOUND = 'buttons/button2.wav'
local START_SOUND = 'buttons/button3.wav'
local CANCEL_SOUND = 'buttons/button10.wav'
local MOVE_SOUND = 'buttons/button14.wav'
local SELECT_SOUND = 'buttons/button17.wav'
local SOUND_LEVEL = 60

-- Initiate the auto-close timer (if enabled)
local function autoCloseTimer()
  local timeout = HOLOHUD.ELEMENTS:ConfigValue(ELEMENT_NAME, 'timeout') or 5
  if timeout <= 0 then return end
  -- create a timer to decide when to automatically close the weapon selector
  timer.Create('holohud_' .. ELEMENT_NAME, timeout, 1, function()
    curSlot = 0
  end)
end

-- emits a sound from the weapon selector
local function emitSound(sound, pitch)
  local volume = HOLOHUD.ELEMENTS:ConfigValue(ELEMENT_NAME, 'volume')
  LocalPlayer():EmitSound(sound, SOUND_LEVEL, pitch, volume, CHAN_WEAPON)
end

-- draws the weapon selector
local function drawHUD(config)
  -- cache weapons
  cacheWeapons()

  -- draw
  HOLOHUD:DrawWeaponSelector(config('x'), config('y'), cache, curSlot, curPos, cacheLength, config)
end

-- add element
HOLOHUD.ELEMENTS:AddElement(ELEMENT_NAME,
  '#holohud.settings.weapon_selector.name',
  '#holohud.settings.weapon_selector.description',
  nil,
  {
    alpha = {name = '#holohud.settings.weapon_selector.alpha', value = 0.1725, maxValue = 1},
    animation = {name = '#holohud.settings.weapon_selector.animated', desc = '#holohud.settings.weapon_selector.animated.description', value = true},
    x = {name = '#holohud.settings.weapon_selector.x', value = ScrH() * 0.1, maxValue = ScrW()},
    y = {name = '#holohud.settings.weapon_selector.y', value = ScrH() * 0.1, maxValue = ScrH()},
    volume = {name = '#holohud.settings.weapon_selector.volume', value = 1, minValue = 0, maxValue = 2},
    colour = { name = '#holohud.settings.weapon_selector.color', value = Color(255, 255, 255) },
    ammo_colour = { name = '#holohud.settings.weapon_selector.ammo_color', value = AMMO_COLOUR },
    crit_colour = { name = '#holohud.settings.weapon_selector.empty_color', value = Color(255, 0, 0)},
    weapon_details = { name = '#holohud.settings.weapon_selector.details', value = false },
    timeout = {name = '#holohud.settings.weapon_selector.timeout', desc = '#holohud.settings.weapon_selector.timeout.description', value = 5}
  }, drawHUD
)

-- paint into overlay if the camera is out
hook.Add('DrawOverlay', 'holohud_switcher_overlay', function()
  if not LocalPlayer or not LocalPlayer().GetActiveWeapon then return end -- avoid pre-init errors
  local weapon = LocalPlayer():GetActiveWeapon()
  if not IsValid(weapon) or weapon:GetClass() ~= CAMERA or gui.IsGameUIVisible() then return end
  drawHUD(function(param) return HOLOHUD.ELEMENTS:ConfigValue(ELEMENT_NAME, param) end)
end)

-- select
UnintrusiveBindPress.add('holohud_legacy', function(_player, bind, pressed, code)
  if not HOLOHUD:IsHUDEnabled() or not HOLOHUD.ELEMENTS:IsElementEnabled(ELEMENT_NAME) or hud_fastswitch:GetBool() or not cl_drawhud:GetBool() then return end -- ignore if it shouldn't draw
  if not pressed then return end -- ignore if bind was not pressed
  if LocalPlayer():InVehicle() then return end -- ignore if player is in a vehicle

  -- check whether the physics gun is in use
  local weapon = LocalPlayer():GetActiveWeapon()
  if IsValid(weapon) and weapon:GetClass() == PHYSICS_GUN and LocalPlayer():KeyDown(IN_ATTACK) and (bind == INV_PREV or bind == INV_NEXT) then return true end

  -- move backwards
  if bind == INV_PREV then
    moveCursor(false)
  	emitSound(MOVE_SOUND, 200)
  	autoCloseTimer()
    return true
  end

  -- move forward
  if bind == INV_NEXT then
    moveCursor(true)
    emitSound(MOVE_SOUND, 200)
    autoCloseTimer()
    return true
  end

  -- cycle through slot
  if string.sub(bind, 1, 4) == SLOT then
    local slot = tonumber(string.sub(bind, 5))
    if slot > 0 and slot <= MAX_SLOTS then
      if curSlot <= 0 then
        emitSound(START_SOUND, 50)
      else
        emitSound(MOVE_SOUND, 200)
      end
      cycleSlot(slot)
      autoCloseTimer()
      return true
    end
  end

  -- select
  if curSlot > 0 and bind == ATTACK then
    if curPos > 0 then
      emitSound(SELECT_SOUND, 200)
    else
      emitSound(UNABLE_SOUND, 175)
    end
    equipSelectedWeapon()
    curSlot = 0
    return true
  end

  -- cancel
  if curSlot > 0 and bind == ATTACK2 then
    emitSound(CANCEL_SOUND, 166)
    curSlot = 0
    return true
  end
end)
