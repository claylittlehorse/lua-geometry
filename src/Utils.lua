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
function Utils.getPlaneRegionFromRectangle(x, y, xSize, ySize)
	if x < 0 then
		if y < 0 then
			return 8
		elseif y < ySize then
			return 7
		else
			return 6
		end
	elseif x < xSize then
		if y < 0 then
			return 1
		elseif y < ySize then
			return 0
		else
			return 5
		end
	else
		if y < 0 then
			return 2
		elseif y < ySize then
			return 3
		else
			return 4
		end
	end
end

-- Edge clamping functions: These are to calculate the point of intersection
-- between a rectangle edge and a 2d line segment. Because of our
-- simplified axis-aligned representation of the 2d rectangle, we can
-- drastically simplify the calculations for these intersection points.

-- Y == 0 edge (AB)
local function clampSegmentToBottomEdge(aX, aY, bX, bY, xSize)
	local xScalar = aY / (aY - bY)
	local x = aX + xScalar * (bX - aX)

	-- Clamp X between 0 and xSize
	if x < 0 then
		return 0, 0, false
	elseif x > xSize then
		return xSize, 0, false
	else
		return x, 0, true
	end
end
-- Y == ySize edge (CD)
local function clampSegmentToTopEdge(aX, aY, bX, bY, xSize, ySize)
	local xScalar = (ySize - aY) / (bY - aY)
	local x = aX + xScalar * (bX - aX)

	-- Clamp X between 0 and xSize
	if x < 0 then
		return 0, ySize, false
	elseif x > xSize then
		return xSize, ySize, false
	else
		return x, ySize, true
	end
end
-- X == 0 edge (DA)
local function clampSegmentToLeftEdge(aX, aY, bX, bY, _, ySize)
	local yScalar = aX / (aX - bX)
	local y = aY + yScalar * (bY - aY)

	-- Clamp Y between 0 and ySize
	if y < 0 then
		return 0, 0, false
	elseif y > ySize then
		return 0, ySize, false
	else
		return 0, y, true
	end
end
-- X == xSize edge (BC)
local function clampSegmentToRightEdge(aX, aY, bX, bY, xSize, ySize)
	local yScalar = (xSize - aX) / (bX - aX)
	local y = aY + yScalar * (bY - aY)

	-- Clamp Y between 0 and ySize
	if y < 0 then
		return xSize, 0, false
	elseif y > ySize then
		return xSize, ySize, false
	else
		return xSize, y, true
	end
end

function Utils.getIntersectionForRectangle2dRaw(aX, aY, bX, bY, xSize, ySize)
	if aX < 0 then
		-- Line could intersect left edge.
		local resultX, resultY, didIntersect = clampSegmentToLeftEdge(aX, aY, bX, bY, nil, ySize)

		if didIntersect then
			return resultX, resultY
		end
	elseif aX > xSize then
		-- Line could intersect right edge.
		local resultX, resultY, didIntersect = clampSegmentToRightEdge(aX, aY, bX, bY, xSize, ySize)

		if didIntersect then
			return resultX, resultY
		end
	end

	if aY < 0 then
		-- Line intersects bottom edge
		return clampSegmentToBottomEdge(aX, aY, bX, bY, xSize)
	elseif aY < ySize then
		-- No intersection
		return aX, aY
	else
		-- Line intersects top edge
		return clampSegmentToTopEdge(aX, aY, bX, bY, xSize, ySize)
	end
end

function Utils.getIntersectionForRectangle2d(aX, aY, bX, bY, xSize, ySize)
	local x, y = Utils.getIntersectionForRectangle2dRaw(aX, aY, bX, bY, xSize, ySize)
	return Vector2.new(x, y)
end

return Utils
