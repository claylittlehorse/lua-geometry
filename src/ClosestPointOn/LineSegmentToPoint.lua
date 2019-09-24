-- Reference: http://www.r-5.org/files/books/computers/algo-list/realtime-3d/Christer_Ericson-Real-Time_Collision_Detection-EN.pdf
-- Page 127-128: Closest Point on Line Segment To Point

local function LineSegmentToPoint(segmentPointA, segmentPointB, pointC)
	local ab = segmentPointB - segmentPointA
	local t = (pointC - segmentPointA):Dot(ab) / ab:Dot(ab)

	math.clamp(t, 0, 1)
	return segmentPointA + t * ab
end

return LineSegmentToPoint
