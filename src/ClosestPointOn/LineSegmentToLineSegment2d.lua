local function ClosestPointOnLineSegmentToLineSegment2d(a1, a2, b1, b2)
	local segAVector = a2 - a1
	local segBVector = b2 - b1

	-- Declare variables for these expressions, since we use them more than once.
	local a1ToB1Vector = b1 - a1

	-- segAIntersectionPointScalar * segAVector = Point of intersection on segment A
	local segAIntersectionPointScalar = (a1ToB1Vector):Cross(segBVector) / segAVector:Cross(segBVector)

	if segAIntersectionPointScalar < 0 then
		segAIntersectionPointScalar = 0
	elseif segAIntersectionPointScalar > 1 then
		segAIntersectionPointScalar = 1
	end

	return a1 + (segAVector * segAIntersectionPointScalar)
end

return ClosestPointOnLineSegmentToLineSegment2d
