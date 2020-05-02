-- Reference: http://www.r-5.org/files/books/computers/algo-list/realtime-3d/Christer_Ericson-Real-Time_Collision_Detection-EN.pdf
-- Page 130-132: Closest Point on AABB to Point

local function ClosestPointOnAABBToPoint(pointA, AABBmax, AABBmin)
	local clampedX = math.clamp(pointA.x, AABBmax.x, AABBmin.x)
	local clampedY = math.clamp(pointA.y, AABBmax.y, AABBmin.y)
	local clampedZ = math.clamp(pointA.z, AABBmax.z, AABBmin.z)
	return Vector3.new(clampedX, clampedY, clampedZ)
end

return ClosestPointOnAABBToPoint
