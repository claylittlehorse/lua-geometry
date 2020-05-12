local ClosestPointOnLineSegmentToPoint = require(script.Parent.Parent.ClosestPointOn.LineSegmentToPoint)
local ClosestPointsOfLineSegments = require(script.Parent.LineSegments)
local Utils = require(script.Parent.Parent.Utils)
local getPlaneRegionFromRectangle = Utils.getPlaneRegionFromRectangle
local getIntersectionForRectangle2dRaw = Utils.getIntersectionForRectangle2dRaw

local function clampSegmentPointsToRectangle(segA, segB, rectA, rectB, rectC, rectD)
	local rectEdgeAB = rectB - rectA
	local rectEdgeAD = rectD - rectA

	local rectangleXAxis = rectEdgeAB.Unit
	local rectangleYAxis = rectEdgeAD.Unit

	local sizeX = rectEdgeAB.Magnitude
	local sizeY = rectEdgeAD.Magnitude

	local lineRectASegA = segA - rectA
	local lineRectASegB = segB - rectA

	local aX = lineRectASegA:Dot(rectangleXAxis)
	local aY = lineRectASegA:Dot(rectangleYAxis)

	local bX = lineRectASegB:Dot(rectangleXAxis)
	local bY = lineRectASegB:Dot(rectangleYAxis)

	local segARegion = getPlaneRegionFromRectangle(aX, aY, sizeX, sizeY)
	local segBRegion = getPlaneRegionFromRectangle(bX, bY, sizeX, sizeY)

	if segBRegion < segARegion then
		segARegion, segBRegion = segBRegion, segARegion
		aX, aY, bX, bY = bX, bY, aX, aY
	end

	if segARegion == segBRegion then
		if segARegion == 0 then
			return rectA + rectangleXAxis * aX + rectangleYAxis * aY,
				   rectA + rectangleXAxis * bX + rectangleYAxis * bY
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

	local aXClamped, aYClamped = getIntersectionForRectangle2dRaw(aX, aY, bX, bY, sizeX, sizeY)
	local bXClamped, bYClamped = getIntersectionForRectangle2dRaw(aX, aY, bX, bY, sizeX, sizeY)

	return rectA + rectangleXAxis * aXClamped + rectangleYAxis * aYClamped,
		   rectA + rectangleXAxis * bXClamped + rectangleYAxis * bYClamped
end

local function ClosestPointsOfLineSegmentAndRectangle(segA, segB, rectA, rectB, rectC, rectD)
	local clampedA, clampedB = clampSegmentPointsToRectangle(segA, segB, rectA, rectB, rectC, rectD)

	if not clampedB then
		return ClosestPointOnLineSegmentToPoint(segA, segB, clampedA), clampedA
	end

	return ClosestPointsOfLineSegments(segA, segB, clampedA, clampedB)
end

return ClosestPointsOfLineSegmentAndRectangle
