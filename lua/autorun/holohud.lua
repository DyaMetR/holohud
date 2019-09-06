--[[------------
     H0L-D4
 Version 1.6.1
    24/08/19
By DyaMetR
]]--------------

-- Main framework table
HOLOHUD = {};

-- Version and patch notes
HOLOHUD.Version = {
  Major = 1, Minor = 6, Patch = 1
};

--[[
  METHODS
]]

--[[
  Correctly includes a file
  @param {string} file
  @void
]]--
function HOLOHUD:IncludeFile(file)
  if SERVER then
    include(file);
    AddCSLuaFile(file);
  end
  if CLIENT then
    include(file);
  end
end

--[[
  INCLUDES
]]
HOLOHUD:IncludeFile("holohud/core.lua");
