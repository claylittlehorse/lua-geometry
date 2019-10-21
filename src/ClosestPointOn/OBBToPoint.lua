-- Reference: http://www.r-5.org/files/books/computers/algo-list/realtime-3d/Christer_Ericson-Real-Time_Collision_Detection-EN.pdf
-- Page 132-134: Distance to Closest Point on OBB

local function OBBToPoint(point, center, u0, u1, u2, extents)
	local d = center - point
	local qx = math.clamp(-u0:Dot(d), -extents.x, extents.x)
	local qy = math.clamp(-u1:Dot(d), -extents.y, extents.y)
	local qz = math.clamp(-u2:Dot(d), -extents.z, extents.z)
	return center + qx * u0 + qy * u1 + qz * u2
end

return OBBToPoint
