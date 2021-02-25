local function GetTriangleArea2d(x1, y1, x2, y2, x3, y3)
	return (x1 - x2)*(y2-y3) - (x2-x3)*(y1-y2)
end

local function GetBarycentricCoordinates(point, triA, triB, triC)
	local areaScalar = 1 / GetTriangleArea2d(triA.X, triA.Y, triB.X, triB.Y, triC.X, triC.Y)
	local u = GetTriangleArea2d(point.X, point.Y, triB.X, triB.Y, triC.X, triC.Y) * areaScalar
	local v = GetTriangleArea2d(point.X, point.Y, triC.X, triC.Y, triA.X, triA.Y) * areaScalar
	local w = 1 - u - v

	return u, v, w
end

local function TestIntersectionOfPointAndTriangle2d(point, triA, triB, triC)
	local u, v, w = GetBarycentricCoordinates(point, triA, triB, triC)
	return u >= 0 and v >= 0 and w >= 0
end

return TestIntersectionOfPointAndTriangle2d
