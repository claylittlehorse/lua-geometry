-- Reference: http://www.r-5.org/files/books/computers/algo-list/realtime-3d/Christer_Ericson-Real-Time_Collision_Detection-EN.pdf
-- Page 130-132: Distance to Closest Point on AABB

local function PointToAABBSquared(pointA, AABBmax, AABBmin)
	local px, py, pz = pointA.x, pointA.y, pointA.z
	local sqDist = 0
	if px < AABBmax.x then sqDist = sqDist + (AABBmax.x - px)^2 end
	if px > AABBmin.x then sqDist = sqDist + (px - AABBmin.x)^2 end
	if py < AABBmax.y then sqDist = sqDist + (AABBmax.y - py)^2 end
	if py > AABBmin.y then sqDist = sqDist + (py - AABBmin.y)^2 end
	if pz < AABBmax.z then sqDist = sqDist + (AABBmax.z - pz)^2 end
	if pz > AABBmin.z then sqDist = sqDist + (pz - AABBmin.z)^2 end
	return sqDist
end

return PointToAABBSquared
