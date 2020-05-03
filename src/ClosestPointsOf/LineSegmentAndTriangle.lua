local ClosestPointOnPlaneToPoint = require(script.Parent.Parent.ClosestPointOn.PlaneToPoint)
local ClosestPointOnLineSegmentToPoint = require(script.Parent.Parent.ClosestPointOn.LineSegmentToPoint)
local ClosestPointsOfLineSegments = require(script.Parent.LineSegments)
local IntersectionPointOfLineSegments2d = require(script.Parent.Parent.InteresctionPointOf.LineSegments2d)

local function getPlaneRegionFromBarycentricCoordinates(u, v, w)
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

local function getPlaneAxesAnd2dSegmentPoints(triA, triEdgeAB, triNormalUnit, primaryPoint, secondaryPoint)
	local planeXAxis = triEdgeAB.Unit
	local planeYAxis = triNormalUnit:Cross(planeXAxis)

	local primaryRelativeToTriA = primaryPoint - triA
	local primaryPoint2d = Vector2.new(primaryRelativeToTriA:Dot(planeXAxis), primaryRelativeToTriA:Dot(planeYAxis))
	local secondaryRelativeToTriA = secondaryPoint - triA
	local secondaryPoint2d = Vector2.new(secondaryRelativeToTriA:Dot(planeXAxis), secondaryRelativeToTriA:Dot(planeYAxis))

	return planeXAxis, planeYAxis, primaryPoint2d, secondaryPoint2d
end

local function intersectEitherTriEdge(edge1point, edge2point, sharedPoint, primaryPoint2d, secondaryPoint2d)
	return IntersectionPointOfLineSegments2d(edge1point, sharedPoint, primaryPoint2d, secondaryPoint2d)
		or IntersectionPointOfLineSegments2d(edge2point, sharedPoint, primaryPoint2d, secondaryPoint2d)
end

local function ClosestPointsOfLineSegmentAndTriangle(segA, segB, triA, triB, triC)
	local triEdgeAB = triB - triA
	local triEdgeAC = triC - triA
	-- local triEdgeBC = triC - triB

	local triNormal = triEdgeAB:Cross(triEdgeAC)
	local triArea2 = triNormal:Dot(triNormal)

	-- Project points A and B of line segment onto plane of triangle
	local triNormalUnit = triNormal.unit
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

	-- Using barycentric coordinates, we can partition the plane which the
	-- triangle resides on into 7 regions. Region 0 is the space within the
	-- triangle, while regions 1-6 represent areas outside of the triangle. (You
	-- can visualize each of these regions with this reference image here:
	-- https://imgur.com/a/FCWtrrZ)
	local segARegion = getPlaneRegionFromBarycentricCoordinates(uSegA, vSegA, wSegA)
	local segBRegion = getPlaneRegionFromBarycentricCoordinates(uSegB, vSegB, wSegB)

	-- Ensure that primary region is always lower than secondary region. This
	-- makes our logic breakdown simpler
	local primaryRegion, secondaryRegion, primaryPoint, secondaryPoint do
		if segARegion >= segBRegion then
			primaryRegion = segARegion
			secondaryRegion = segBRegion
			primaryPoint = projectedSegA
			secondaryPoint = projectedSegB
		elseif segARegion <= segBRegion then
			primaryRegion = segBRegion
			secondaryRegion = segARegion
			primaryPoint = projectedSegB
			secondaryPoint = projectedSegA
		end
	end

	if primaryRegion == 0 then
		if secondaryRegion == 0 then
			return ClosestPointsOfLineSegments(segA, segB, primaryPoint, secondaryPoint)
		elseif secondaryRegion == 1 then
			local planeXAxis, planeYAxis, primaryPoint2d, secondaryPoint2d = getPlaneAxesAnd2dSegmentPoints(triA, triEdgeAB, triNormalUnit, primaryPoint, secondaryPoint)

			local triA2d = Vector2.new()
			local triB2d = Vector2.new(triEdgeAB.Magntiude, 0)

			local segmentEdgeIntersection2d = IntersectionPointOfLineSegments2d(triA2d, triB2d, primaryPoint2d, secondaryPoint2d)

			-- Convert intersection point back to 3d
			local segmentEdgeIntersection = triA + (planeXAxis * segmentEdgeIntersection2d.X) + (planeYAxis * segmentEdgeIntersection2d.Y)
			return ClosestPointsOfLineSegments(segA, segB, primaryPoint, segmentEdgeIntersection)
		elseif secondaryRegion == 2 then
			-- Projected segment intersects triEdgeAB or triEdgeBC
			local planeXAxis = triEdgeAB.Unit
			local planeYAxis = triNormalUnit:Cross(planeXAxis)

			local triA2d = Vector2.new()
			local triB2d = Vector2.new(triEdgeAB.Magntiude, 0)
			local triC2d = Vector2.new(triEdgeAC:Dot(planeXAxis), triEdgeAC:Dot(planeYAxis))

			local primaryRelativeToTriA = primaryPoint - triA
			local primaryPoint2d = Vector2.new(primaryRelativeToTriA:Dot(planeXAxis), primaryRelativeToTriA:Dot(planeYAxis))
			local secondaryRelativeToTriA = secondaryPoint - triA
			local secondaryPoint2d =  Vector2.new(secondaryRelativeToTriA:Dot(planeXAxis), secondaryRelativeToTriA:Dot(planeYAxis))

			local segmentEdgeIntersection2d do
				local edge1SegmentIntersection = IntersectionPointOfLineSegments2d(triA2d, triB2d, primaryPoint2d, secondaryPoint2d)
				if edge1SegmentIntersection then
					segmentEdgeIntersection2d = edge1SegmentIntersection
				else
					segmentEdgeIntersection2d = IntersectionPointOfLineSegments2d(triC2d, triB2d, primaryPoint2d, secondaryPoint2d)
				end
			end

			-- Convert intersection point back to 3d
			local segmentEdgeIntersection = triA + (planeXAxis * segmentEdgeIntersection2d.X) + (planeYAxis * segmentEdgeIntersection2d.Y)
			return ClosestPointsOfLineSegments(segA, segB, primaryPoint, segmentEdgeIntersection)
		elseif secondaryRegion == 3 then
			-- Projected segment intersects triEdgeBC
			local planeXAxis = triEdgeAB.Unit
			local planeYAxis = triNormalUnit:Cross(planeXAxis)

			local triB2d = Vector2.new(triEdgeAB.Magntiude, 0)
			local triC2d = Vector2.new(triEdgeAC:Dot(planeXAxis), triEdgeAC:Dot(planeYAxis))

			local primaryRelativeToTriA = primaryPoint - triA
			local primaryPoint2d = Vector2.new(primaryRelativeToTriA:Dot(planeXAxis), primaryRelativeToTriA:Dot(planeYAxis))
			local secondaryRelativeToTriA = secondaryPoint - triA
			local secondaryPoint2d =  Vector2.new(secondaryRelativeToTriA:Dot(planeXAxis), secondaryRelativeToTriA:Dot(planeYAxis))

			local segmentEdgeIntersection2d = IntersectionPointOfLineSegments2d(triC2d, triB2d, primaryPoint2d, secondaryPoint2d)

			-- Convert intersection point back to 3d
			local segmentEdgeIntersection = triA + (planeXAxis * segmentEdgeIntersection2d.X) + (planeYAxis * segmentEdgeIntersection2d.Y)
			return ClosestPointsOfLineSegments(segA, segB, primaryPoint, segmentEdgeIntersection)
		elseif secondaryRegion == 4 then
			-- Projected segment intersects triEdgeBC or triEdgeAC
			local planeXAxis = triEdgeAB.Unit
			local planeYAxis = triNormalUnit:Cross(planeXAxis)

			local triA2d = Vector2.new()
			local triB2d = Vector2.new(triEdgeAB.Magntiude, 0)
			local triC2d = Vector2.new(triEdgeAC:Dot(planeXAxis), triEdgeAC:Dot(planeYAxis))

			local primaryRelativeToTriA = primaryPoint - triA
			local primaryPoint2d = Vector2.new(primaryRelativeToTriA:Dot(planeXAxis), primaryRelativeToTriA:Dot(planeYAxis))
			local secondaryRelativeToTriA = secondaryPoint - triA
			local secondaryPoint2d =  Vector2.new(secondaryRelativeToTriA:Dot(planeXAxis), secondaryRelativeToTriA:Dot(planeYAxis))

			local segmentEdgeIntersection2d do
				local edge1SegmentIntersection = IntersectionPointOfLineSegments2d(triC2d, triB2d, primaryPoint2d, secondaryPoint2d)
				if edge1SegmentIntersection then
					segmentEdgeIntersection2d = edge1SegmentIntersection
				else
					segmentEdgeIntersection2d = IntersectionPointOfLineSegments2d(triC2d, triA2d, primaryPoint2d, secondaryPoint2d)
				end
			end

			-- Convert intersection point back to 3d
			local segmentEdgeIntersection = triA + (planeXAxis * segmentEdgeIntersection2d.X) + (planeYAxis * segmentEdgeIntersection2d.Y)
			return ClosestPointsOfLineSegments(segA, segB, primaryPoint, segmentEdgeIntersection)
		elseif secondaryRegion == 5 then
			-- Projected segment intersects triEdgeBC
			local planeXAxis = triEdgeAB.Unit
			local planeYAxis = triNormalUnit:Cross(planeXAxis)

			local triA2d = Vector2.new()
			local triC2d = Vector2.new(triEdgeAC:Dot(planeXAxis), triEdgeAC:Dot(planeYAxis))

			local primaryRelativeToTriA = primaryPoint - triA
			local primaryPoint2d = Vector2.new(primaryRelativeToTriA:Dot(planeXAxis), primaryRelativeToTriA:Dot(planeYAxis))
			local secondaryRelativeToTriA = secondaryPoint - triA
			local secondaryPoint2d =  Vector2.new(secondaryRelativeToTriA:Dot(planeXAxis), secondaryRelativeToTriA:Dot(planeYAxis))

			local segmentEdgeIntersection2d = IntersectionPointOfLineSegments2d(triC2d, triA2d, primaryPoint2d, secondaryPoint2d)

			-- Convert intersection point back to 3d
			local segmentEdgeIntersection = triA + (planeXAxis * segmentEdgeIntersection2d.X) + (planeYAxis * segmentEdgeIntersection2d.Y)
			return ClosestPointsOfLineSegments(segA, segB, primaryPoint, segmentEdgeIntersection)
		elseif secondaryRegion == 6 then
			-- Projected segment intersects TriEdgeAC or triEdgeAB
			local planeXAxis = triEdgeAB.Unit
			local planeYAxis = triNormalUnit:Cross(planeXAxis)

			local triA2d = Vector2.new()
			local triB2d = Vector2.new(triEdgeAB.Magntiude, 0)
			local triC2d = Vector2.new(triEdgeAC:Dot(planeXAxis), triEdgeAC:Dot(planeYAxis))

			local primaryRelativeToTriA = primaryPoint - triA
			local primaryPoint2d = Vector2.new(primaryRelativeToTriA:Dot(planeXAxis), primaryRelativeToTriA:Dot(planeYAxis))
			local secondaryRelativeToTriA = secondaryPoint - triA
			local secondaryPoint2d =  Vector2.new(secondaryRelativeToTriA:Dot(planeXAxis), secondaryRelativeToTriA:Dot(planeYAxis))

			local segmentEdgeIntersection2d do
				local edge1SegmentIntersection = IntersectionPointOfLineSegments2d(triA2d, triC2d, primaryPoint2d, secondaryPoint2d)
				if edge1SegmentIntersection then
					segmentEdgeIntersection2d = edge1SegmentIntersection
				else
					segmentEdgeIntersection2d = IntersectionPointOfLineSegments2d(triA2d, triB2d, primaryPoint2d, secondaryPoint2d)
				end
			end

			-- Convert intersection point back to 3d
			local segmentEdgeIntersection = triA + (planeXAxis * segmentEdgeIntersection2d.X) + (planeYAxis * segmentEdgeIntersection2d.Y)
			return ClosestPointsOfLineSegments(segA, segB, primaryPoint, segmentEdgeIntersection)
		end
	elseif primaryRegion == 1 then
		if secondaryRegion == 1 or secondaryRegion == 2 or secondaryRegion == 6 then
			return ClosestPointsOfLineSegments(segA, segB, triA, triB)
		elseif secondaryRegion == 3 then
			-- Intersect triEdgeAB and triEdgeBC
		elseif secondaryRegion == 4 then
			-- Intersect triEdgeAB, Test Intersect triEdgeBC and triEdgeAC
		elseif secondaryRegion == 5 then
			-- Intersect triEdgeAC
		end
	elseif primaryRegion == 2 then
		if secondaryRegion == 2 then
			return ClosestPointOnLineSegmentToPoint(segA, segB, triB), triB
		elseif secondaryRegion == 3 or secondaryRegion == 4 then
			return ClosestPointsOfLineSegments(segA, segB, triB, triC)
		elseif secondaryRegion == 5 then
			-- Intersect triEdgeAC, test triEdgeAB triEdgeBC
		elseif secondaryRegion == 6 then
			return ClosestPointsOfLineSegments(segA, segB, triA, triB)
		end
	elseif primaryRegion == 3 then
		if secondaryRegion == 3 or secondaryRegion == 4 then 
			return ClosestPointsOfLineSegments(segA, segB, triB, triC)
		elseif secondaryRegion == 5 then
			-- Intersect triEdgeBC, triEdgeAC
		elseif secondaryRegion == 6 then
			-- Intersect triEdgeBC, Test triEdgeAB and triEdgeAC
		end
	elseif primaryRegion == 4 or primaryRegion == 5 then
		-- Secondary region must be 4, 5, or 6.
		if secondaryRegion == 4 then -- Primary region must be 4
			return ClosestPointOnLineSegmentToPoint(segA, segB, triC), triC
		end

		return ClosestPointsOfLineSegments(segA, segB, triA, triC)
	elseif primaryRegion == 6 then
		-- Secondary region must be 6
		return ClosestPointOnLineSegmentToPoint(segA, segB, triA), triA
	end
end

return ClosestPointsOfLineSegmentAndTriangle
