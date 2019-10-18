-- Reference: http://www.r-5.org/files/books/computers/algo-list/realtime-3d/Christer_Ericson-Real-Time_Collision_Detection-EN.pdf
-- Page 155-156: Closest Points of Two Triangles

local LineSegmentToTriangle = require(script.Parent.Parent.ClosestPointsOf.LineSegmentToTriangle)
local LineSegments = require(script.Parent.Parent.ClosestPointsOf.LineSegments)
local PointToTriangle = require(script.Parent.Parent.ClosestPointOn.PointToTriangle)

--[[
					A0
                /|
			  / |
	        /  |
	      /	  |
	    /    |
	  /	    |
	/______|
	B0		C0

					A1
                /|
			  / |
	        /  |
	      /	  |
	    /    |
	  /	    |
	/______|
	B1		C1
	-- 6 vertex to triangle tests
	A0 to triangle BA, BB, BC
	B0 to triangle BA, BB, BC
	C0 to triangle BA, BB, BC
	A1 to triangle AA, AB, AC
	B1 to triangle AA, AB, AC
	C1 to triangle AA, AB, AC

	-- 9 edge segment tests
	A0B0 to A1B1
	A0B0 to B1C1
	A0B0 to C1A1
	B0C0 to A1B1
	B0C0 to B1C1
	B0C0 to C1A1
	C0A0 to A1B1
	C0A0 to B1C1
	C0A0 to C1A1
]]

local function TriangleToTriangle(A0, B0, C0, A1, B1, C1)
	local testPairs = {
		PointToTriangle(A0, B0, C0, A1),
		PointToTriangle(A0, B0, C0, B1),
		PointToTriangle(A0, B0, C0, C1),
		PointToTriangle(A1, B1, C1, A0),
		PointToTriangle(A1, B1, C1, B0),
		PointToTriangle(A1, B1, C1, C0),
		LineSegments(A0, B0, A1, B1),
		LineSegments(A0, B0, B1, C1),
		LineSegments(A0, B0, C1, A1),
		LineSegments(B0, C0, A1, B1),
		LineSegments(B0, C0, B1, C1),
		LineSegments(B0, C0, C1, A1),
		LineSegments(C0, A0, A1, B1),
		LineSegments(C0, A0, B1, C1),
		LineSegments(C0, A0, C1, A1),
	}

	local dist, pair0, pair1 = math.huge
	for i = 1, (9 + 6) * 2, 2 do
		local val, nex = testPairs[i], testPairs[i + 1]
		if val and nex then
			local d = (val - nex):Dot(val - nex)
			if d < dist then
				dist = d
				pair0 = val
				pair1 = nex
			end
		end
	end

	return pair0, pair1
end

return TriangleToTriangle
