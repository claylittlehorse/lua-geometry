local LineSegmentToPointSquared = require(script.LineSegmentToPointSquared)

return {
	LineSegmentToPointSquared = LineSegmentToPointSquared,
	LineSegmentToPoint = function(...)
		return LineSegmentToPointSquared(...) ^ 0.5
	end
}
