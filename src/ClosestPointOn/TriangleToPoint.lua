local Utils = require(script.Parent.Parent.Utils)
local ClosestPointOnLineSegmentToPoint = require(script.Parent.LineSegmentToPoint)
local ClosestPointOnPlaneToPoint = require(script.Parent.PlaneToPoint)

local function ClosestPointOnTriangleToPoint(triA, triB, triC, point)
	local triEdgeAB = triB - triA
	local triEdgeAC = triC - triA
	-- \local triEdgeBC = triC - triB

	local triNormal = triEdgeAB:Cross(triEdgeAC)
	local triArea2 = triNormal:Dot(triNormal)

	-- Project points A and B of line segment onto plane of triangle
	local triNormalUnit = triNormal.unit
	local projectedPoint = ClosestPointOnPlaneToPoint(point, triA, triNormalUnit)

	-- Get U, V, W barymetric coordinates for segA and segB projections
	-- Seg A
	local pointToTriC = projectedPoint - triC
	local pointToTriA = projectedPoint - triA

	local u = triNormal:Dot(triEdgeAB:Cross(pointToTriA)) / triArea2
	local v = triNormal:Dot(pointToTriC:Cross(triEdgeAC)) / triArea2
	local w = 1 - u - v

	local region = Utils.getPlaneRegionFromBarycentricCoordinates(u, v, w)

	if region == 0 then
		return projectedPoint
	elseif region == 6 then
		return triA
	elseif region == 2 then
		return triB
	elseif region == 4 then
		return triC
	elseif region == 1 then
		return ClosestPointOnLineSegmentToPoint(triA, triB, point)
	elseif region == 3 then
		return ClosestPointOnLineSegmentToPoint(triB, triC, point)
	elseif region == 5 then
		return ClosestPointOnLineSegmentToPoint(triA, triC, point)
	end
end

return ClosestPointOnTriangleToPoint
