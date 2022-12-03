local Constants = require(script.Parent.Parent.Constants)
local EPSILON = Constants.EPSILON

local function IntersectionOfLineSegmentAndPlane(segA, segB, planePosition, planeNormal)
	local segVector = segB - segA
	local dot = segVector:Dot(planeNormal)

	if math.abs(dot) > EPSILON then
		local w = segA - planePosition
		local fac = planeNormal:Dot(w) / dot
		segVector *= fac
		return segA + segVector
	end

	return nil
end

return IntersectionOfLineSegmentAndPlane
