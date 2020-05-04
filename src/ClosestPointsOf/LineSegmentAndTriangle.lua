local ClosestPointOnPlaneToPoint = require(script.Parent.Parent.ClosestPointOn.PlaneToPoint)
local ClosestPointOnTriangleToPoint = require(script.Parent.Parent.ClosestPointOn.TriangleToPoint)
local ClosestPointOnLineSegmentToPoint = require(script.Parent.Parent.ClosestPointOn.LineSegmentToPoint)
local ClosestPointOnLineSegmentToLineSegment2d = require(script.Parent.Parent.ClosestPointOn.LineSegmentToLineSegment2d)
local ClosestPointsOfLineSegments = require(script.Parent.LineSegments)
local Utils = require(script.Parent.Parent.Utils)

local triA2d = Vector2.new()
local triB2d, triC2d

local function getIntersectionForTriangleRegion2d(segA2d, segB2d, triEdgeAB, triEdgeAC, planeXAxis, planeYAxis, region)
	if region == 0 then
		-- No intersection
		return segA2d
	elseif region == 1 then
		-- Segment intersects AB
		triB2d = triB2d or Vector2.new(triEdgeAB.Magnitude, 0)
		return ClosestPointOnLineSegmentToLineSegment2d(triA2d, triB2d, segA2d, segB2d)
	elseif region == 3 then
		-- Segment intersects BC
		triB2d = triB2d or Vector2.new(triEdgeAB.Magnitude, 0)
		triC2d = triC2d or Vector2.new(triEdgeAC:Dot(planeXAxis), triEdgeAC:Dot(planeYAxis))
		return ClosestPointOnLineSegmentToLineSegment2d(triB2d, triC2d, segA2d, segB2d)
	elseif region == 5 then
		-- Segment intersects AC
		triC2d = triC2d or Vector2.new(triEdgeAC:Dot(planeXAxis), triEdgeAC:Dot(planeYAxis))
		return ClosestPointOnLineSegmentToLineSegment2d(triA2d, triC2d, segA2d, segB2d)
	elseif region == 2 then
		-- Segment intersects either AB or BC
		triB2d = triB2d or Vector2.new(triEdgeAB.Magnitude, 0)
		triC2d = triC2d or Vector2.new(triEdgeAC:Dot(planeXAxis), triEdgeAC:Dot(planeYAxis))
		return Utils.intersectCorner2d(triA2d, triC2d, triB2d, segA2d, segB2d)
	elseif region == 4 then
		-- Segment intersects either BC or AC
		triB2d = triB2d or Vector2.new(triEdgeAB.Magnitude, 0)
		triC2d = triC2d or Vector2.new(triEdgeAC:Dot(planeXAxis), triEdgeAC:Dot(planeYAxis))
		return Utils.intersectCorner2d(triB2d, triA2d, triC2d, segA2d, segB2d)
	elseif region == 6 then
		-- Segment intersects either AC or AB
		triC2d = triC2d or Vector2.new(triEdgeAC:Dot(planeXAxis), triEdgeAC:Dot(planeYAxis))
		return Utils.intersectCorner2d(triC2d, triB2d, triA2d, segA2d, segB2d)
	end
end

local function clampSegmentPointsToTriangle(triA, triB, triC, segARegion, segBRegion, projectedSegA, projectedSegB, triEdgeAB, triEdgeAC, triNormalUnit)
	if segARegion == segBRegion then
		if segARegion == 0 then
			return projectedSegA, projectedSegB
		elseif segARegion == 6 then
			return triA
		elseif segARegion == 2 then
			return triB
		elseif segARegion == 4 then
			return triC
		end
	end

	if (segARegion == 1 or segARegion == 2) and (segBRegion == 1 or segBRegion == 2 or segBRegion == 6) then
		return triA, triB
	elseif (segARegion == 2 or segARegion == 3) and (segBRegion == 3 or segBRegion == 4) then
		return triB, triC
	elseif (segARegion == 4 or segARegion == 5) and (segBRegion == 5 or segBRegion == 6) then
		return triC, triA
	end

	local planeXAxis = triEdgeAB.Unit
	local planeYAxis = triNormalUnit:Cross(planeXAxis)

	local lineTriASegA = projectedSegA - triA
	local lineTriASegB = projectedSegB - triA

	local segA2d = Vector2.new(lineTriASegA:Dot(planeXAxis), lineTriASegA:Dot(planeYAxis))
	local segB2d = Vector2.new(lineTriASegB:Dot(planeXAxis), lineTriASegB:Dot(planeYAxis))

	triB2d, triC2d = nil, nil
	local clampedA2d = getIntersectionForTriangleRegion2d(segA2d, segB2d, triEdgeAB, triEdgeAC, planeXAxis, planeYAxis, segARegion)
	local clampedB2d = getIntersectionForTriangleRegion2d(segB2d, segA2d, triEdgeAB, triEdgeAC, planeXAxis, planeYAxis, segBRegion)

	return triA + (planeXAxis * clampedA2d.X) + (planeYAxis * clampedA2d.Y),
		   triA + (planeXAxis * clampedB2d.X) + (planeYAxis * clampedB2d.Y)
end

local function ClosestPointsOfLineSegmentAndTriangle(segA, segB, triA, triB, triC)
	local triEdgeAB = triB - triA
	local triEdgeAC = triC - triA
	-- \local triEdgeBC = triC - triB

	local triNormal = triEdgeAB:Cross(triEdgeAC)
	local triNormalUnit = triNormal.unit

	local segmentUnit = (segB - segA).unit
	local segmentTriNormalDotProduct = segmentUnit:Dot(triNormalUnit)
	if segmentTriNormalDotProduct == 1 or segmentTriNormalDotProduct == -1 then
		local triPoint = ClosestPointOnTriangleToPoint(triA, triB, triC, segA)
		local segPoint = ClosestPointOnLineSegmentToPoint(segA, segB, triPoint)

		return segPoint, triPoint, nil, nil, ClosestPointOnPlaneToPoint(segA, triA, triNormalUnit), ClosestPointOnPlaneToPoint(segB, triA, triNormalUnit)
	end

	local triArea2 = triNormal:Dot(triNormal)

	-- Project points A and B of line segment onto plane of triangle
	local projectedSegA = ClosestPointOnPlaneToPoint(segA, triA, triNormalUnit)
	local projectedSegB = ClosestPointOnPlaneToPoint(segB, triA, triNormalUnit)

	-- Get U, V, W barymetric coordinates for segA and segB projections
	-- Seg A
	local triCSegA = projectedSegA - triC
	local triASegA = projectedSegA - triA

	local uSegA = triNormal:Dot(triEdgeAB:Cross(triASegA)) / triArea2
	local vSegA = triNormal:Dot(triCSegA:Cross(triEdgeAC)) / triArea2
	local wSegA = 1 - uSegA - vSegA

	--Seg B
	local triCSegB = projectedSegB - triC
	local triASegB = projectedSegB - triA

	local uSegB = triNormal:Dot(triEdgeAB:Cross(triASegB)) / triArea2
	local vSegB = triNormal:Dot(triCSegB:Cross(triEdgeAC)) / triArea2
	local wSegB = 1 - uSegB - vSegB

	local segARegion = Utils.getPlaneRegionFromBarycentricCoordinates(uSegA, vSegA, wSegA)
	local segBRegion = Utils.getPlaneRegionFromBarycentricCoordinates(uSegB, vSegB, wSegB)

	if segBRegion < segARegion then
		segARegion, segBRegion = segBRegion, segARegion
		projectedSegA, projectedSegB = projectedSegB, projectedSegA
	end

	local clampedA, clampedB = clampSegmentPointsToTriangle(triA, triB, triC, segARegion, segBRegion, projectedSegA, projectedSegB, triEdgeAB, triEdgeAC, triNormalUnit)

	if not clampedB then
		return ClosestPointOnLineSegmentToPoint(segA, segB, clampedA), clampedA, nil, nil, projectedSegA, projectedSegB
	end

	return ClosestPointsOfLineSegments(segA, segB, clampedA, clampedB)
end


return ClosestPointsOfLineSegmentAndTriangle
