-- Reference: http://www.r-5.org/files/books/computers/algo-list/realtime-3d/Christer_Ericson-Real-Time_Collision_Detection-EN.pdf
-- Page 129-130: Distance of Point to Segment

local DistanceOfLineSegmentToPointSquared = require(script.Parent.LineSegmentToPointSquared)

local function DistanceOfLineSegmentToPoint(segmentPointA, segmentPointB, pointC)
	local distanceSquared = DistanceOfLineSegmentToPointSquared(segmentPointA, segmentPointB, pointC)
	if distanceSquared < 0 then
		return 0
	end

	return math.sqrt(distanceSquared)
end

return DistanceOfLineSegmentToPoint
