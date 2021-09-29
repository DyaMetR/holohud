--[[------------
     H0L-D4
 Version 1.9.3
    29/09/21
By DyaMetR
]]--------------

-- Main framework table
HOLOHUD = {};

-- Version and patch notes
HOLOHUD.Version = {
  Major = 1, Minor = 9, Patch = 3
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
