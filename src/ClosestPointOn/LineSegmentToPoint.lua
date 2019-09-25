-- Reference: http://www.r-5.org/files/books/computers/algo-list/realtime-3d/Christer_Ericson-Real-Time_Collision_Detection-EN.pdf
-- Page 127-128: Closest Point on Line Segment To Point

local function LineSegmentToPoint(segmentPointA, segmentPointB, pointC)
	local segmentVector = segmentPointB - segmentPointA
	local segmentScalar = (pointC - segmentPointA):Dot(segmentVector) / segmentVector:Dot(segmentVector)

	local scaledVector = (math.clamp(segmentScalar, 0, 1) * segmentVector)
	local closestPointOnSegment = segmentPointA + scaledVector

	return closestPointOnSegment
end

return LineSegmentToPoint
