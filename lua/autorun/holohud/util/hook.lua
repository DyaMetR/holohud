--[[------------------------------------------------------------------
  Avoid conflicts with regular hooks by running after these did
]]--------------------------------------------------------------------

if dyametr_hook_replacement then return end -- avoid running the same script twice

-- store old hook functions
local _add = _add or hook.Add
local _call = _call or hook.Call
local _g_call = _g_call or gamemode.Call
local _run = _run or hook.Run

-- hooks
local hooks = {}

--[[------------------------------------------------------------------
  Whether another addon that does a similar function is already running
  In case of a conflict, let that other addon do their thing instead of us
  @return {boolean} there's a conflict
]]--------------------------------------------------------------------
local function detectConflicts()
  return _G.DLib ~= nil or ix ~= nil
end

--[[------------------------------------------------------------------
  Adds a hook that will run after all of the regular hook functions did
  @param {string} hook
  @param {string} identifier
  @param {function} function
  @param {number} priority
]]--------------------------------------------------------------------
local function add(_hook, id, func, priority)
  priority = priority or 1
  if not hooks[_hook] then hooks[_hook] = {} end
  if not hooks[_hook][priority] then hooks[_hook][priority] = {} end
  hooks[_hook][priority][id] = func
end

--[[------------------------------------------------------------------
  Runs all functions of the given hook
  @param {string} hook
  @param {varargs} arguments
]]--------------------------------------------------------------------
local function run(name, ...)
  if not hooks[name] then return end

  -- declare return values
  local a, b, c, d, e, f

  -- run hooks ordered by priority
  for priority, _hooks in pairs(hooks[name]) do
    for _hook, func in pairs(_hooks) do
      a, b, c, d, e, f = func(...)

      -- hook returned a value, halt execution
      if a ~= nil then
        return a, b, c, d, e, f
      end
    end
  end
end

--[[------------------------------------------------------------------
  Called instead of hook.Add
]]--------------------------------------------------------------------
local function hookAdd(_hook, id, func, priority, ...)
  if not func then return end
  if detectConflicts() then _add(_hook, id, func, priority, ...) return end
  if not priority then _add(_hook, id, func) return end
  add(_hook, id, func, priority)
end

--[[------------------------------------------------------------------
  Called instead of hook.Call
]]--------------------------------------------------------------------
local function hookCall(name, gm, ...)
  if detectConflicts() then return _call(name, gm, ...) end

  local a, b, c, d, e, f -- return values

  -- run vanilla hooks first
  local hookTable = hook.GetTable()[name]
  if hookTable then
    for k, v in pairs(hookTable) do
			if (isstring(k)) then
				-- if it's a string, run as usual
				a, b, c, d, e, f = v(...)
			else
        -- if it isn't a string, it's something IsValid works on
				if (IsValid(k)) then
					-- if the object is valid - pass it as the first argument (self)
					a, b, c, d, e, f = v(k, ...)
				else
					-- if the object has become invalid - remove it
					hookTable[k] = nil
				end
			end
			-- hook returned a value - it overrides the gamemode and PostHook functions
			if (a ~= nil) then
				return a, b, c, d, e, f
			end
		end
  end

  -- run prioritized hooks second
  if hooks[name] then
    a, b, c, d, e, f = run(name, ...)
    -- hook returned a value - it overrides the gamemode function
    if ( a ~= nil ) then
      return a, b, c, d, e, f
    end
  end

  -- call the gamemode function
  if ( !gm ) then return end

	local gamemodeFunction = gm[ name ]
	if ( gamemodeFunction == nil ) then return end

	return gamemodeFunction( gm, ... )
end

--[[------------------------------------------------------------------
  Called instead of gamemode.Call
]]--------------------------------------------------------------------
local function gamemodeCall(name, ...)
  if detectConflicts() then return _g_call(name, ...) end
  local gm = gmod.GetGamemode()
  if (gm && gm[name] == nil) then return false end
  return hookCall(name, gm, ...)
end

--[[------------------------------------------------------------------
  Called instead of hook.Run
]]--------------------------------------------------------------------
local function hookRun(name, ...)
  if detectConflicts() then return _run(name, ...) end
  return hookCall(name, gmod and gmod.GetGamemode() or nil, ...)
end

-- override default functions
hook.Add = hookAdd
hook.Call = hookCall
gamemode.Call = gamemodeCall
hook.Run = hookRun

dyametr_hook_replacement = true -- mark the replacement as already made
