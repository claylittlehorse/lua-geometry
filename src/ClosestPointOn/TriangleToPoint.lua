-- Reference: https://gdbooks.gitbooks.io/3dcollisions/content/Chapter4/closest_point_to_triangle.html
-- License: https://gdbooks.gitbooks.io/3dcollisions/content/
-- transcribed by cosmoit

local ClosestPointOnLineSegmentToPoint = require(script.Parent.LineSegmentToPoint)
local ClosestPointOnPlaneToPoint = require(script.Parent.PlaneToPoint)

local function isPointInTriangle(a, b, c, p)
	a = a - p
	b = b - p
	c = c - p

	local u = b:Cross(c)
	local v = c:Cross(a)
	local w = a:Cross(b)

	if u:Dot(v) < 0 or u:Dot(w) < 0 then
		return false
	end

	return true
end

local function squareDistance(vector)
	return vector:Dot(vector)
end

local function ClosestPointOnTriangleToPoint(a, b, c, p)
	local n = (b - a):Cross(c - a).unit
	local projectedPoint = ClosestPointOnPlaneToPoint(p, (a + b + c) / 3, n)
	if isPointInTriangle(a, b, c, projectedPoint) then
		return projectedPoint
	end

	local c1 = ClosestPointOnLineSegmentToPoint(a, b, p)
	local c2 = ClosestPointOnLineSegmentToPoint(b, c, p)
	local c3 = ClosestPointOnLineSegmentToPoint(c, a, p)

	local d1 = squareDistance(p - c1)
	local d2 = squareDistance(p - c2)
	local d3 = squareDistance(p - c3)

	if d1 < d2 then
		if d1 < d3 then
			return c1
		else
			return c3
		end
	else
		if d2 < d3 then
			return c2
		else
			return c3
		end
	end
end

return ClosestPointOnTriangleToPoint
