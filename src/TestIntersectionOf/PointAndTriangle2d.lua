local Utils = require(script.Parent.Parent.Utils)

local function TestIntersectionOfPointAndTriangle2d(point, triA, triB, triC)
	local u, v, w = Utils.GetBarycentricCoordinates2d(point, triA, triB, triC)
	return u >= 0 and v >= 0 and w >= 0
end

return TestIntersectionOfPointAndTriangle2d
