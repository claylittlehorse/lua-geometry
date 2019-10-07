-- Reference: http://www.r-5.org/files/books/computers/algo-list/realtime-3d/Christer_Ericson-Real-Time_Collision_Detection-EN.pdf
-- Page 126-127: Distance of Plane to Point

-- ||planeNormal|| == 1;
local function PlaneToPoint(pointA, planePosition, planeNormal)
	return pointA:Dot(planeNormal) - planePosition
end

return PlaneToPoint
