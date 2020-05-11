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

-- Partitions
-- https://imgur.com/a/S186utY
function Utils.getPlaneRegionFromRectangle(x, rectLength, y, rectHeight)
	if x < 0 then
		if y < 0 then
			return 8
		elseif y < rectHeight then
			return 7
		else
			return 6
		end
	elseif x < rectLength then
		if y < 0 then
			return 1
		elseif y < rectHeight then
			return 0
		else
			return 5
		end
	else
		if y < 0 then
			return 2
		elseif y < rectHeight then
			return 3
		else
			return 4
		end
	end
end

function Utils.getSpaceRegionFromRectangle(x, rectLength, y, rectHeight, rectDepth, z)
	if y < 0 then
		if x < 0 then
			if z < 0 then
				return 8
			elseif z < rectDepth then
				return 7
			else
				return 6
			end
		elseif x < rectLength then
			if z < 0 then
				return 1
			elseif z < rectDepth then
				return 9
			else
				return 5
			end
		else
			if z < 0 then
				return 2
			elseif z < rectDepth then
				return 3
			else
				return 4
			end
		end
	elseif y < rectHeight then
		if x < 0 then
			if z < 0 then
				return 18
			elseif z < rectDepth then
				return 17
			else
				return 16
			end
		elseif x < rectLength then
			if z < 0 then
				return 11
			elseif z < rectDepth then
				return 0
			else
				return 15
			end
		else
			if z < 0 then
				return 12
			elseif z < rectDepth then
				return 13
			else
				return 14
			end
		end
	else
		if x < 0 then
			if z < 0 then
				return 28
			elseif z < rectDepth then
				return 27
			else
				return 26
			end
		elseif x < rectLength then
			if z < 0 then
				return 21
			elseif z < rectDepth then
				return 29
			else
				return 25
			end
		else
			if z < 0 then
				return 22
			elseif z < rectDepth then
				return 23
			else
				return 24
			end
		end
	end
end

return Utils
