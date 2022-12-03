-- Reference: http://www.r-5.org/files/books/computers/algo-list/realtime-3d/Christer_Ericson-Real-Time_Collision_Detection-EN.pdf
-- Page 127-128: Closest Point on Line Segment To Point

local function ClosestPointOnRayToPoint(rayOrigin, rayDirection, pointC)
	local segmentScalar = (pointC - rayOrigin):Dot(rayDirection) / rayDirection:Dot(rayDirection)

	local scaledVector = segmentScalar * rayDirection
	local closestPointOnSegment = rayOrigin + scaledVector

	return closestPointOnSegment
end

return ClosestPointOnRayToPoint
