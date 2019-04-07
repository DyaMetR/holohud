--[[------------------------------------------------------------------
  INTERSECTIONS
  Functions for intersecting values
]]--------------------------------------------------------------------

if CLIENT then

	--[[
		Given a value, determines how much of each one is shown
		@param {number} a
		@param {number} b
		@param {number} value
		@return {number} result
	]]
	function HOLOHUD:Intersect(a, b, value)
		return (a * value) + (b * (1-value));
	end

	--[[
		Intersects two colours based on a value
		@param {number} a
		@param {number} b
		@param {number} value
		@param {Color} result
	]]
	function HOLOHUD:IntersectColour(a, b, value)
		return Color(HOLOHUD:Intersect(a.r, b.r, value), HOLOHUD:Intersect(a.g, b.g, value), HOLOHUD:Intersect(a.b, b.b, value), HOLOHUD:Intersect(a.a, b.a, value));
	end

end
