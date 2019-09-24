-- Reference: http://www.r-5.org/files/books/computers/algo-list/realtime-3d/Christer_Ericson-Real-Time_Collision_Detection-EN.pdf
-- Page 129-130: Distance of Point to Segment

-- Distance squared allows for more efficient distance checks, if the value
-- you're checking against is also squared. Essentially, solving out the root
-- allows the calculation to be done much faster.
local function LineSegmentToPointSquared(segmentPointA, segmentPointB, pointC)
	local ab = segmentPointB - segmentPointA
	local ac = pointC - segmentPointA
	local bc = pointC - segmentPointB
	local e = ac:Dot(ab)

	-- Cases where C projects outside AB
	if e <= 0 then
		return ac:Dot(ac)
	end

	local f = ab:dot(ab)
	if e >= f then
		return bc:Dot(bc)
	end

	-- Cases where C projects onto AB
	return ac:Dot(ac) - e * e / f
end

return LineSegmentToPointSquared
