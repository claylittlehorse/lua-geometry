-- Reference: http://www.r-5.org/files/books/computers/algo-list/realtime-3d/Christer_Ericson-Real-Time_Collision_Detection-EN.pdf
-- Page 132-134: Distance to Closest Point on OBB squared

local ClosestPointToOBB = require(script.Parent.Parent.ClosestPointOn.PointToOBB)

local function PointToOBB(point, center, u0, u1, u2, extents)
	local closest = ClosestPointToOBB(point, center, u0, u1, u2, extents)
	return math.sqrt((closest - point):Dot(closest - point))
end

return PointToOBB
