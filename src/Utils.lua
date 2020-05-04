local IntersectionPointOfLineSegments2d = require(script.Parent.IntersectionPointOf.LineSegments2d)

local Utils = {}

-- Using barycentric coordinates, we can partition the plane which a
-- triangle resides on into 7 regions. Region 0 is the space within the
-- triangle, while regions 1-6 represent areas outside of the triangle. (You
-- can visualize each of these regions with this reference image here:
-- https://imgur.com/a/FCWtrrZ)
function Utils.getPlaneRegionFromBarycentricCoordinates(u, v, w)
	local isUNegative = u < 0
	local isVNegative = v < 0
	local isWNegative = w < 0

	if isUNegative and not isVNegative and not isWNegative then
		return 1
	elseif isUNegative and not isVNegative and isWNegative then
		return 2
	elseif not isUNegative and not isVNegative and isWNegative then
		return 3
	elseif not isUNegative and isVNegative and isWNegative then
		return 4
	elseif not isUNegative and isVNegative and not isWNegative then
		return 5
	elseif isUNegative and isVNegative and not isWNegative then
		return 6
	else
		return 0
	end
end

function Utils.intersectCorner2d(edge1Point, edge2Point, cornerPoint, segA2d, segB2d)
	return IntersectionPointOfLineSegments2d(edge1Point, cornerPoint, segA2d, segB2d)
		or IntersectionPointOfLineSegments2d(edge2Point, cornerPoint, segA2d, segB2d)
end

return Utils
