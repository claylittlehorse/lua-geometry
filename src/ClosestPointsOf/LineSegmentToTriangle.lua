-- Reference: http://www.r-5.org/files/books/computers/algo-list/realtime-3d/Christer_Ericson-Real-Time_Collision_Detection-EN.pdf
-- Page 148-151: Closest Points of a Line Segment and a Triangle
-- Naive implementation

local ClosestPointOn = require(script.Parent.Parent.ClosestPointOn)
local LineSegments = require(script.Parent.LineSegments)

local function distSquared(vector)
	return vector:Dot(vector)
end

local function IsPointInTriangle(a, b, c, p)
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

local function LineSegmentToTriangle(p, q, a, b, c)
	local center = (a + b + c) / 3
	local n = (b - a):Cross(c - a).unit

	local TriP, TriQ
	if IsPointInTriangle(a, b, c, p) then
		TriP = ClosestPointOn.PlaneToPoint(p, center, n)
	end
	if IsPointInTriangle(a, b, c, q) then
		TriQ = ClosestPointOn.PlaneToPoint(q, center, n)
	end

	local PQAB0, PQAB1
	local PQBC0, PQBC1
	local PQCA0, PQCA1
	if not(TriP and TriQ) then
		PQAB0, PQAB1 = LineSegments(p, q, a, b)
		PQBC0, PQBC1 = LineSegments(p, q, b, c)
		PQCA0, PQCA1 = LineSegments(p, q, c, a)
	end

	local pairs = {
		PQAB0, PQAB1, 
		PQBC0, PQBC1, 
		PQCA0, PQCA1,
		TriP and p or nil, TriP,
		TriQ and q or nil, TriQ,
	}

	local dist, pair0, pair1 = math.huge
	for i = 1, #pairs, 2 do
		local val, nex = pairs[i], pairs[i + 1]
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

return LineSegmentToTriangle
