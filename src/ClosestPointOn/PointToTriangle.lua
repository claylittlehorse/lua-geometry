-- Reference: https://gdbooks.gitbooks.io/3dcollisions/content/Chapter4/closest_point_to_triangle.html
-- License: https://gdbooks.gitbooks.io/3dcollisions/content/
-- transcribed by cosmoit

local LineSegmentToPoint = require(script.Parent.LineSegmentToPoint)
local PlaneToPoint = require(script.Parent.PlaneToPoint)

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

local function distSquared(vector)
	return vector:Dot(vector)
end

local function PointToTriangle(a, b, c, p)
    local n = (b - a):Cross(c - a).unit
    local projectedPoint = PlaneToPoint(p, (a + b + c) / 3, n)
    if IsPointInTriangle(a, b, c, projectedPoint) then
        return projectedPoint
    end
    
    local c1 = LineSegmentToPoint(a, b, p)
    local c2 = LineSegmentToPoint(b, c, p)
    local c3 = LineSegmentToPoint(c, a, p)
    
    local d1 = distSquared(p - c1)
    local d2 = distSquared(p - c2)
    local d3 = distSquared(p - c3)
    
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

return PointToTriangle
