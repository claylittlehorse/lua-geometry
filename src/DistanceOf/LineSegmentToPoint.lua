-- Reference: http://www.r-5.org/files/books/computers/algo-list/realtime-3d/Christer_Ericson-Real-Time_Collision_Detection-EN.pdf
-- Page 129-130: Distance of Point to Segment

local LineSegmentToPointSquared = require(script.Parent.LineSegmentToPointSquared)

local function LineSegmentToPoint(segmentPointA, segmentPointB, pointC)
	local distanceSquared = LineSegmentToPointSquared(segmentPointA, segmentPointB, pointC)
	return math.sqrt(distanceSquared)
end

return LineSegmentToPoint
