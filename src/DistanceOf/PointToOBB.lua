-- Reference: http://www.r-5.org/files/books/computers/algo-list/realtime-3d/Christer_Ericson-Real-Time_Collision_Detection-EN.pdf
-- Page 132-134: Distance to Closest Point on OBB squared

local ClosestPointOnOBBToPoint = require(script.Parent.Parent.ClosestPointOn.OBBToPoint)

local function PointToOBB(point, center, u0, u1, u2, extents)
	local closest = ClosestPointOnOBBToPoint(point, center, u0, u1, u2, extents)
	return math.sqrt((closest - point):Dot(closest - point))
end

return PointToOBB
