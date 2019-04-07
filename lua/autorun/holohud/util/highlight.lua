--[[------------------------------------------------------------------
  HIGHLIGHTING
  Creates animations for when metrics change values in the HUD
]]--------------------------------------------------------------------

if CLIENT then

  -- Parameters
  local ADD_AMOUNT = 0.07;
  local SUBSTRACT_AMOUNT = 0.01;

  -- Variables
  HOLOHUD.Highlight = {};
  local tick = 0;

  --[[
    Adds a value to the highlight animation list
    @param {string} id
    @void
  ]]
  function HOLOHUD:AddHighlight(id)
    HOLOHUD.Highlight[id] = {active = false, amount = 0};
  end

  --[[
    Removes a highlight animation from the list
    @param {string} id
    @void
  ]]
  function HOLOHUD:RemoveHighlight(id)
    HOLOHUD.Highlight[id] = nil;
  end

  --[[
    Triggers a highlight component's animation
    @param {string} id
    @void
  ]]
  function HOLOHUD:TriggerHighlight(id)
    if (self.Highlight[id] == nil) then return end;
    self.Highlight[id].active = true;
  end

  --[[
    Returns the amount of highlighting from a value
    @param {string} id
    @param {number} value
  ]]
  function HOLOHUD:GetHighlight(id)
    if (self.Highlight[id] == nil) then return 0 end;
    return self.Highlight[id].amount;
  end

  --[[
    Runs the highlight animations
  ]]
  local function Animate()
    if (tick < CurTime()) then
      for id, value in pairs(HOLOHUD.Highlight) do
        if (value.active) then
          if (value.amount < 1) then
            HOLOHUD.Highlight[id].amount = math.Clamp(value.amount + ADD_AMOUNT, 0, 1);
          else
            value.active = false;
          end
        else
          if (value.amount > 0) then
            HOLOHUD.Highlight[id].amount = math.Clamp(value.amount - SUBSTRACT_AMOUNT, 0, 1);
          end
        end
      end
      tick = CurTime() + 0.01;
    end
  end

  -- Animate
  hook.Add("Think", "holohud_highlight_animate", function()
    Animate();
  end);

end
