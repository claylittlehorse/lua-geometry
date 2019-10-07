-- Reference: http://www.r-5.org/files/books/computers/algo-list/realtime-3d/Christer_Ericson-Real-Time_Collision_Detection-EN.pdf
-- Page 130-132: Distance to Closest Point on AABB

local PointToAABBSquared = require(script.Parent.PointToAABBSquared)

local function PointToAABB(pointA, AABBmax, AABBmin)
	local distanceSquared = PointToAABBSquared(pointA, AABBmax, AABBmin)
	return math.sqrt(distanceSquared)
end

return PointToAABB
