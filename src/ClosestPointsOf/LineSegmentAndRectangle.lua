local ClosestPointOnLineSegmentToPoint = require(script.Parent.Parent.ClosestPointOn.LineSegmentToPoint)
local ClosestPointOnPlaneToPoint = require(script.Parent.Parent.ClosestPointOn.PlaneToPoint)
local ClosestPointsOfLineSegments = require(script.Parent.LineSegments)
local Utils = require(script.Parent.Parent.Utils)

-- Edge clamping functions: These are to calculate the point of intersection
-- between a rectangle edge and the 2d-projected line segment. Because of our
-- simplified axis-aligned representation of the 2d rectangle, we can
-- drastically simplify the calculations for these intersection points.

-- Y == 0 edge (AB)
local function clampSegmentToEdgeAB(segA2dX, segA2dY, segB2dX, segB2dY, rectLength)
	local xScalar = segA2dY / (segA2dY - segB2dY)
	local x = segA2dX + xScalar * (segB2dX - segA2dX)

	-- Clamp X between 0 and rectLength
	if x < 0 then
		return 0, 0, false
	elseif x > rectLength then
		return rectLength, 0, false
	else
		return x, 0, true
	end
end
-- Y == rectHeight edge (CD)
local function clampSegmentToEdgeCD(segA2dX, segA2dY, segB2dX, segB2dY, rectLength, rectHeight)
	local xScalar = (rectHeight - segA2dY) / (segB2dY - segA2dY)
	local x = segA2dX + xScalar * (segB2dX - segA2dX)

	-- Clamp X between 0 and rectLength
	if x < 0 then
		return 0, rectHeight, false
	elseif x > rectLength then
		return rectLength, rectHeight, false
	else
		return x, rectHeight, true
	end
end
-- X == 0 edge (DA)
local function clampSegmentToEdgeAD(segA2dX, segA2dY, segB2dX, segB2dY, _, rectHeight)
	local yScalar = segA2dX / (segA2dX - segB2dX)
	local y = segA2dY + yScalar * (segB2dY - segA2dY)

	-- Clamp Y between 0 and rectHeight
	if y < 0 then
		return 0, 0, false
	elseif y > rectHeight then
		return 0, rectHeight, false
	else
		return 0, y, true
	end
end
-- X == rectLength edge (BC)
local function clampSegmentToEdgeBC(segA2dX, segA2dY, segB2dX, segB2dY, rectLength, rectHeight)
	local yScalar = (rectLength - segA2dX) / (segB2dX - segA2dX)
	local y = segA2dY + yScalar * (segB2dY - segA2dY)

	-- Clamp Y between 0 and rectHeight
	if y < 0 then
		return rectLength, 0, false
	elseif y > rectHeight then
		return rectLength, rectHeight, false
	else
		return rectLength, y, true
	end
end

local function clampSegmentToCorner(leftOrRightEdgeClampFunc, topOrBottomEdgeClampFunc, segA2dX, segA2dY, segB2dX, segB2dY, rectLength, rectHeight)
	local clampedX, clampedY, didIntersect = leftOrRightEdgeClampFunc(segA2dX, segA2dY, segB2dX, segB2dY, rectLength, rectHeight)

	if didIntersect then
		return clampedX, clampedY
	end

	return topOrBottomEdgeClampFunc(segA2dX, segA2dY, segB2dX, segB2dY, rectLength, rectHeight)
end

local function getIntersectionForRectangleRegion2d(region, segA2dX, segA2dY, segB2dX, segB2dY, rectLength, rectHeight)
	if region == 0 then
		-- No intersection
		return segA2dX, segA2dY
	elseif region == 1 then
		-- Segment intersects AB
		return clampSegmentToEdgeAB(segA2dX, segA2dY, segB2dX, segB2dY, rectLength)
	elseif region == 3 then
		-- Segment intersects BC
		return clampSegmentToEdgeBC(segA2dX, segA2dY, segB2dX, segB2dY, rectLength, rectHeight)
	elseif region == 5 then
		-- Segment intersects CD
		return clampSegmentToEdgeCD(segA2dX, segA2dY, segB2dX, segB2dY, rectLength, rectHeight)
	elseif region == 7 then
		-- Segment intersects AD
		return clampSegmentToEdgeAD(segA2dX, segA2dY, segB2dX, segB2dY, nil, rectHeight)
	elseif region == 2 then
		-- Segment intersects either AB or BC
		return clampSegmentToCorner(clampSegmentToEdgeBC, clampSegmentToEdgeAB, segA2dX, segA2dY, segB2dX, segB2dY, rectLength, rectHeight)
	elseif region == 4 then
		-- Segment intersects either BC or CD
		return clampSegmentToCorner(clampSegmentToEdgeBC, clampSegmentToEdgeCD, segA2dX, segA2dY, segB2dX, segB2dY, rectLength, rectHeight)
	elseif region == 6 then
		-- Segment intersects either CD or AD
		return clampSegmentToCorner(clampSegmentToEdgeAD, clampSegmentToEdgeCD, segA2dX, segA2dY, segB2dX, segB2dY, rectLength, rectHeight)
	elseif region == 8 then
		-- Segment intersects either AD or AB
		return clampSegmentToCorner(clampSegmentToEdgeAD, clampSegmentToEdgeAB, segA2dX, segA2dY, segB2dX, segB2dY, rectLength, rectHeight)
	end
end

local function clampSegmentPointsToRectangle(segA, segB, rectA, rectB, rectC, rectD)
	local rectEdgeAB = rectB - rectA
	local rectEdgeAD = rectD - rectA

	local rectangleXAxis = rectEdgeAB.Unit
	local rectangleYAxis = rectEdgeAD.Unit

	local rectLength = rectEdgeAB.Magnitude
	local rectHeight = rectEdgeAD.Magnitude

	local lineRectASegA = segA - rectA
	local lineRectASegB = segB - rectA

	local segA2dX = lineRectASegA:Dot(rectangleXAxis)
	local segA2dY = lineRectASegA:Dot(rectangleYAxis)

	local segB2dX = lineRectASegB:Dot(rectangleXAxis)
	local segB2dY = lineRectASegB:Dot(rectangleYAxis)

	local segARegion = Utils.getPlaneRegionFromRectangle(segA2dX, rectLength, segA2dY, rectHeight)
	local segBRegion = Utils.getPlaneRegionFromRectangle(segB2dX, rectLength, segB2dY, rectHeight)

	print("A region", segARegion, "B Region", segBRegion)

	if segBRegion < segARegion then
		segARegion, segBRegion = segBRegion, segARegion
		segA2dX, segA2dY, segB2dX, segB2dY = segB2dX, segB2dY, segA2dX, segA2dY
	end

	if segARegion == segBRegion then
		if segARegion == 0 then
			return rectA + rectangleXAxis * segA2dX + rectangleYAxis * segA2dY,
				   rectA + rectangleXAxis * segB2dX + rectangleYAxis * segB2dY
		elseif segARegion == 8 then
			return rectA
		elseif segARegion == 2 then
			return rectB
		elseif segARegion == 4 then
			return rectC
		elseif segARegion == 6 then
			return rectD
		end
	end

	if (segARegion == 1 or segARegion == 2) and (segBRegion == 1 or segBRegion == 2 or segBRegion == 8) then
		return rectA, rectB
	elseif (segARegion == 2 or segARegion == 3) and (segBRegion == 3 or segBRegion == 4) then
		return rectB, rectC
	elseif (segARegion == 4 or segARegion == 5) and (segBRegion == 5 or segBRegion == 6) then
		return rectC, rectD
	elseif (segARegion == 6 or segARegion == 7) and (segBRegion == 7 or segBRegion == 8) then
		return rectD, rectA
	end

	local clampedA2dX, clampedA2dY = getIntersectionForRectangleRegion2d(segARegion, segA2dX, segA2dY, segB2dX, segB2dY, rectLength, rectHeight)
	local clampedB2dX, clampedB2dY = getIntersectionForRectangleRegion2d(segBRegion, segA2dX, segA2dY, segB2dX, segB2dY, rectLength, rectHeight)

	return rectA + rectangleXAxis * clampedA2dX +rectangleYAxis * clampedA2dY,
		   rectA + rectangleXAxis * clampedB2dX + rectangleYAxis * clampedB2dY
end

local function ClosestPointsOfLineSegmentAndRectangle(segA, segB, rectA, rectB, rectC, rectD)
	local clampedA, clampedB = clampSegmentPointsToRectangle(segA, segB, rectA, rectB, rectC, rectD)

	local rectEdgeAB = rectB - rectA
	local rectEdgeAD = rectD - rectA
	local rectangleNormal = rectEdgeAB:Cross(rectEdgeAD).Unit

	local projectedA = ClosestPointOnPlaneToPoint(segA, rectA, rectangleNormal)
	local projectedB = ClosestPointOnPlaneToPoint(segB, rectA, rectangleNormal)

	if not clampedB then
		return ClosestPointOnLineSegmentToPoint(segA, segB, clampedA), clampedA, clampedA, clampedB, projectedA, projectedB
	end

	local resultA, resultB = ClosestPointsOfLineSegments(segA, segB, clampedA, clampedB)

	return  resultA, resultB, clampedA, clampedB, projectedA, projectedB
end

return ClosestPointsOfLineSegmentAndRectangle
