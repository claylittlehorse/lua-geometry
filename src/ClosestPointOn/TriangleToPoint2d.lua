local Utils = require(script.Parent.Parent.Utils)
local ClosestPointOnLineSegmentToPoint = require(script.Parent.LineSegmentToPoint)

local function ClosestPointOnTriangleToPoint(triA, triB, triC, point)
	local u, v, w = Utils.GetBarycentricCoordinates2d(point, triA, triB, triC)

	local region = Utils.getPlaneRegionFromBarycentricCoordinates(u, v, w)

	if region == 0 then
		return point
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
