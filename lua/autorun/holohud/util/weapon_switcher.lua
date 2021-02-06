--[[------------------------------------------------------------------
  DyaMetR's Weapon Switcher
  A script that mimics the weapon selector logic without overriding
  any other addons that use the inventory binds.
  https://github.com/DyaMetR/Weapon-Switcher

  Use the 'DrawHUD' function to display your custom weapon selector!
  Use the rest of functions below CONFIGURATION to customize it to your liking
  If you're not including this anywhere, place it on 'lua/autorun/client'

  Inspired by code_gs's weapon switcher skeleton:
  https://github.com/Kefta/Weapon-Switcher-Skeleton/blob/master/gs_switcher.lua
]]--------------------------------------------------------------------

if CLIENT then

--[[ VARIABLES -- used when drawing the HUD component ]]--

local temp = {} -- table used when sorting weapons per slot position
local slot_cache = {} -- weapons divided in slots
local slot_length = {} -- amount of weapons per slot
local weapons_slot = {} -- where each weapon is in the cache
local weapon_count = 0 -- total amount of cached weapons
local last_slot_occupied = 0 -- the last slot with weapons
local cur_slot = 0 -- current slot selected -- 0 is invalid, won't show the HUD
local cur_pos = 1 -- position inside the slot

--[[ HOLOHUD ]]--

-- declare draw function
local function DrawWeaponHUD(config) HOLOHUD:DrawWeaponSelector(config("x"), config("y"), slot_cache, cur_slot, cur_pos, slot_length, config); end

-- add element
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

--[[ CONFIGURATION -- what you mainly want to put your hands on ]]--

local HOOK_NAME = 'dmr_weapon_switch_holohud' -- name used by hooks -- change it to avoid conflicts!
local MAX_SLOTS = 6 -- maximum amount of slots in the weapons inventory
local MOVE_SOUND = "Player.WeaponSelectionMoveSlot" -- sound played when moving through a slot
local SELECT_SOUND = "Player.WeaponSelected" -- sound played when selecting a weapon
local CANCEL_SOUND = "" -- sound played when the player closes the inventory
local OVERRIDE_CL_DRAWHUD = false -- whether it should still draw with cl_drawhud disabled
local TIME = 6 -- how much time until it automatically closes -- 0 is never


--[[------------------------------------------------------------------
  Called to check whether the weapon switcher should work at all
  @return {boolean} should work
]]--------------------------------------------------------------------
local function IsEnabled()

  return HOLOHUD:IsHUDEnabled()

end

--[[------------------------------------------------------------------
  How much time is the inventory open
  @return {number} time
]]--------------------------------------------------------------------
local function GetTime()

  return TIME

end

--[[------------------------------------------------------------------
  Weapon table to select weapon from
  @return {table} weapon table
]]--------------------------------------------------------------------
local function GetWeaponTable()

    return slot_cache

end

--[[------------------------------------------------------------------
  Called when the HUD is painted -- draw your own selector here!
]]--------------------------------------------------------------------
local function DrawHUD() return end

--[[------------------------------------------------------------------
  Called on the slot clearing process before registering weapons
  @param {number} slot
]]--------------------------------------------------------------------
local function ClearSlot(slot)
end

--[[------------------------------------------------------------------
  Called when a weapon is registered
  @param {Weapon} weapon
  @param {number} slot
  @param {number} position in slot
]]--------------------------------------------------------------------
local function WeaponRegistered(weapon, slot, pos)
end

--[[ IMPLEMENTATION -- do not touch unless you know what you're doing! ]]--

local WEAPON_PHYSGUN = 'weapon_physgun' -- physgun weapon class
local GMOD_CAMERA = 'gmod_camera' -- camera weapon class
local CANCEL_SELECT = 'cancelselect' -- command to close inventory
local INV_NEXT = 'invnext' -- command to move inventory cursor forward
local INV_PREV = 'invprev' -- command to move inventory backwards
local SLOT = 'slot' -- command to select an inventory slot
local LAST_INV = 'lastinv' -- command to select the last weapon used
local ATTACK, ATTACK2 = '+attack', '+attack2' -- commands to select or cancel selection
local DRAWHUD = GetConVar('cl_drawhud')
local FASTSWITCH = GetConVar('hud_fastswitch') -- weapons fast switch console variable
local last_weapon_count = 0 -- variable to check for weapon table changes
local time = 0 -- time until the HUD decides to hide

-- initialize weapons table with empty values
for i=1, MAX_SLOTS do
  temp[i] = {}
  slot_cache[i] = {}
  slot_length[i] = 0
end

--[[------------------------------------------------------------------
  Puts the inventory cursor on the currently active weapon
]]--------------------------------------------------------------------
local function SetCursorOnActiveWeapon()
  local weapon = LocalPlayer():GetActiveWeapon()
  if IsValid( weapon ) then
    local cur_weapon = weapons_slot[weapon:GetClass()]
    cur_slot = cur_weapon[1]
    cur_pos = cur_weapon[2]
  else
    cur_slot = 0
    cur_pos = 1
  end
end

--[[------------------------------------------------------------------
  Saves the given weapons into an ordered table by slot and slot position
]]--------------------------------------------------------------------
local function CacheWeapons()
  local weapons = table.Copy(LocalPlayer():GetWeapons()) -- defaults to LocalPlayer's weapons

  -- update the current weapon count
  weapon_count = #weapons

  -- reset the cache
  last_slot_occupied = 0
  for i=1, MAX_SLOTS do
    -- empty the cached weapons on the given slot
    table.Empty(slot_cache[i])
    -- reset the slot's length
    slot_length[i] = 0

    ClearSlot(i)
  end

   -- do not cache weapons if there are none
  if weapon_count <= 0 then
    cur_slot = 0
    cur_pos = 1
    return
  end

  -- sort weapons by their slot position
  for i=1, weapon_count do
    -- get weapon slot
    local slot = weapons[i]:GetSlot() + 1
    -- get next position
    local pos = slot_length[slot] + 1
    slot_length[slot] = pos
    -- add weapon to temporary cache
    temp[slot][pos] = weapons[i]
    -- sort slot
    table.sort( temp[slot], function( a, b ) return a:GetSlotPos() < b:GetSlotPos() end )
  end

  -- store weapons in cache
  for slot, _weapons in pairs(temp) do
    for pos, _weapon in pairs(_weapons) do
      slot_cache[slot][pos] = _weapon -- store in cache
      weapons_slot[_weapon:GetClass()] = { slot, pos } -- store position and slot per weapon
      last_slot_occupied = math.max(last_slot_occupied, slot)
      WeaponRegistered(_weapon, slot, pos) -- call custom function
    end
    -- empty the temporary cache once finished
    table.Empty(temp[slot])
  end

  -- check whether the cursor is out of bounds
  if cur_slot > 0 and ( slot_length[cur_slot] <= 0 or not slot_cache[cur_slot][cur_pos] ) then
    SetCursorOnActiveWeapon()
  end
end

--[[------------------------------------------------------------------
  Moves the position cursor by one; will move slots if bounds are met
  @param {boolean} move cursor forward
]]--------------------------------------------------------------------
local function MoveCursor(forward)
  -- open inventory
  if cur_slot <= 0 then
    SetCursorOnActiveWeapon()
  end
  -- move cursor
  if forward then
    if cur_pos >= slot_length[cur_slot] then
      cur_pos = 1

      -- look for the next slot with weapons
      repeat
        if cur_slot >= MAX_SLOTS then
          cur_slot = 1
        else
          cur_slot = cur_slot + 1
        end
      until( slot_length[cur_slot] > 0 )
    else
      cur_pos = math.min(cur_pos + 1, slot_length[cur_slot])
    end
  else
    if cur_pos <= 1 then
      -- look for the next slot with weapons
      repeat
        if cur_slot <= 1 then
          cur_slot = MAX_SLOTS
        else
          cur_slot = cur_slot - 1
        end
      until( slot_length[cur_slot] > 0 )

      -- put the cursor on the last weapon
      cur_pos = slot_length[cur_slot]
    else
      cur_pos = math.max(cur_pos - 1, 1)
    end
  end

  -- reset timer
  time = CurTime() + GetTime()
end

--[[------------------------------------------------------------------
  Cycles between the weapons of the given slot
  @param {number} slot
]]--------------------------------------------------------------------
local function SelectSlot(slot)
  -- move slot cursor if is not there
  if slot ~= cur_slot then
    cur_pos = 1
    cur_slot = slot
  else
    -- cycle through slot weapons
    if cur_pos < slot_length[slot] then
      cur_pos = math.min(cur_pos + 1, slot_length[slot])
    else
      cur_pos = 1
    end
  end

  -- reset timer
  time = CurTime() + GetTime()
end

--[[------------------------------------------------------------------
  Whether the weapon selector should draw
  @return {boolean} should draw
]]--------------------------------------------------------------------
local function ShouldDraw()
  return IsEnabled() and (OVERRIDE_CL_DRAWHUD or DRAWHUD:GetBool())
end

--[[------------------------------------------------------------------
  Processes PlayerBindPress event
  @param {Player} player
  @param {string} bind
  @param {boolean} pressed
]]--------------------------------------------------------------------
local function PlayerBindPress(player, bind, pressed)
  if not pressed or not ShouldDraw() or FASTSWITCH:GetBool() or not player:Alive() or (player:InVehicle() and not player:GetAllowWeaponsInVehicle()) then return end

  bind = string.lower(bind)

  -- close menu
  if (bind == CANCEL_SELECT or bind == ATTACK2) and cur_slot > 0 then
    cur_slot = 0
    player:EmitSound( CANCEL_SOUND )
    if bind == ATTACK2 then return true end -- override only if secondary attack is pressed
  end

  -- last weapon
  if bind == LAST_INV then
    local last_weapon = player:GetPreviousWeapon()
    if last_weapon:IsWeapon() then
      input.SelectWeapon(last_weapon)
    end
  end

  if weapon_count <= 0 then return end -- don't do anything past this point if there are no weapons present

  -- slot
  if string.sub(bind, 1, 4) == SLOT then
    local slot = tonumber(string.sub(bind, 5, 6))

    -- check whether there's a valid slot
    if slot ~= nil then
      -- make sure it doesn't go out of bounds
      if slot >= 1 and slot <= MAX_SLOTS then
        SelectSlot( slot )
        player:EmitSound( MOVE_SOUND )
        return true
      end
    end
  end

  -- select weapon
  local weapons = GetWeaponTable()
  if bind == ATTACK and pressed and cur_slot > 0 and weapons[cur_slot][cur_pos] then
    input.SelectWeapon( weapons[cur_slot][cur_pos] )
    cur_slot = 0
    player:EmitSound( SELECT_SOUND )
    return true
  end

  -- disable mousewheel functions if the physgun is being used
  if IsValid(player:GetActiveWeapon()) and player:GetActiveWeapon():GetClass() == WEAPON_PHYSGUN and player:KeyDown(IN_ATTACK) then return end

  -- next weapon
  if bind == INV_NEXT then
    MoveCursor( true )
    player:EmitSound( MOVE_SOUND )
    return true
  end

  -- previous weapon
  if bind == INV_PREV then
    MoveCursor( false )
    player:EmitSound( MOVE_SOUND )
    return true
  end
end

-- add hook with priority -- DLib support
hook.Add('PlayerBindPress', HOOK_NAME, PlayerBindPress, 2)

-- seek for weapon table changes
hook.Add('PostDrawHUD', HOOK_NAME, function()
  if not ShouldDraw() or LocalPlayer().GetWeapons == nil then return end
  -- check if weapons changed
  if last_weapon_count ~= #LocalPlayer():GetWeapons() then
    CacheWeapons()
    last_weapon_count = weapon_count
  end
  -- close inventory
  if GetTime() > 0 and time < CurTime() then
    cur_slot = 0
  end
end)

-- draw the HUD
hook.Add('HUDPaint', HOOK_NAME, function()
  -- don't draw if hud_fastswitch is enabled or if the inventory is closed
  if not ShouldDraw() or FASTSWITCH:GetBool() or cur_slot <= 0 then return end

  -- draw HUD
  DrawHUD()
end)

-- only draw on overlay if the camera is equipped, otherwise draw it behind Derma
hook.Add('DrawOverlay', HOOK_NAME, function()
  -- don't draw if either fastswitch is enabled, the menu's up, inventory is inactive or the player isn't using the camera
  if not ShouldDraw() or gui.IsGameUIVisible() or not IsValid(LocalPlayer():GetActiveWeapon()) or LocalPlayer():GetActiveWeapon():GetClass() ~= GMOD_CAMERA or FASTSWITCH:GetBool() or cur_slot <= 0 then return end

  -- draw HUD
  DrawHUD()

  -- draw HOLOHUD
  DrawWeaponHUD(function(param) return HOLOHUD.ELEMENTS:ConfigValue("weapon_selector", param); end);
end)

end
