-- Reference: http://www.r-5.org/files/books/computers/algo-list/realtime-3d/Christer_Ericson-Real-Time_Collision_Detection-EN.pdf
-- Page 126-127: Distance of Plane to Point

-- planeNormal.Magnitude == 1;
local function ClosestPointOnPlaneToPoint(pointA, planePosition, planeNormal)
	local t = pointA:Dot(planeNormal) - planePosition:Dot(planeNormal)
	return pointA - t * planeNormal
end

return ClosestPointOnPlaneToPoint
