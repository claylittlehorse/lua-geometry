local Constants = require(script.Parent.Parent.Constants)
local EPSILON = Constants.EPSILON

local function IntersectionPointsOfLines2d(a1, a2, b1, b2)
	local segAVector = a2 - a1
	local segBVector = b2 - b1

	local segmentVectorsCrossProduct = segAVector:Cross(segBVector)

	local a1ToB1Vector = b1 - a1
	local a1ToB1VectorCrossSegAVector = (a1ToB1Vector):Cross(segAVector)

	local segAIntersectionPointScalar = (a1ToB1Vector):Cross(segBVector) / segmentVectorsCrossProduct

	if segmentVectorsCrossProduct < EPSILON and segmentVectorsCrossProduct > -EPSILON then
		if a1ToB1VectorCrossSegAVector < EPSILON and a1ToB1VectorCrossSegAVector > -EPSILON then
			return a1
		end

		return nil
	end

	return a1 + (segAVector * segAIntersectionPointScalar)
end

return IntersectionPointsOfLines2d
