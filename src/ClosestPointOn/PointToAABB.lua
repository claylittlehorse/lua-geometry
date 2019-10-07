-- Reference: http://www.r-5.org/files/books/computers/algo-list/realtime-3d/Christer_Ericson-Real-Time_Collision_Detection-EN.pdf
-- Page 130-132: Closest Point on AABB to Point

local function PointToAABB(pointA, AABBmax, AABBmin)
	local qx, qy, qz
	qx = math.clamp(pointA.x, AABBmax.x, AABBmin.x)
	qy = math.clamp(pointA.y, AABBmax.y, AABBmin.y)
	qz = math.clamp(pointA.z, AABBmax.z, AABBmin.z)
	return Vector3.new(qx, qy, qz)
end

return PointToAABB
