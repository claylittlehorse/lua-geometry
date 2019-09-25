-- Reference: http://www.r-5.org/files/books/computers/algo-list/realtime-3d/Christer_Ericson-Real-Time_Collision_Detection-EN.pdf
-- Page 148-151: Closest Points of Two Line Segments

local EPSILON = 1e-06 -- (0.000001)
-- Roblox vectors use single precision values, so this is a good quantity for
-- epsilon. If we were using a lua implementation of vectors (or just lua
-- numbers in general), our math would have double precision and 1e-09 would probably be better suited.

local function LineSegments(a1, a2, b1, b2)
	-- Where a1 & a2 are points of segment a, b1 & b2 are points of segment b,
	local aVector = a2 - a1
	local bVector = b2 - b1
	local bOffset = a1 - b1
	local aLengthSq = aVector:Dot(aVector)
	local bLengthSq = bVector:Dot(bVector)
	local bOffsetProjection = bVector:Dot(bOffset)

	-- Check if both segments degenerate into points
	if aLengthSq <= EPSILON and bLengthSq <= EPSILON then
		-- Both segments degenerate into points
		local closestPtA = a1
		local closestPtB = b1
		return closestPtA, closestPtB
	end

	-- Check if either segment a, segement b or neither degenerate into points
	if aLengthSq <= EPSILON then
		-- First segment degenerates into point
		local closestPtA = a1

		local bScalar = math.clamp(bOffsetProjection / bLengthSq, 0, 1)
		local closestPtB = b1 + (bVector * bScalar)

		return closestPtA, closestPtB
	else
		local aOffsetProjection = aVector:Dot(bOffset)
		if bLengthSq <= EPSILON then
			-- Second segment degenerates into point
			local closestPtB = b1

			local aScalar = math.clamp(-aOffsetProjection / aLengthSq, 0, 1)
			local closestPtA = a1 + (aVector * aScalar)

			return closestPtA, closestPtB
		else
			-- Neither segments degenerate into points
			local aVectorProjection = aVector:Dot(bVector)
			local denom = aLengthSq*bLengthSq - aVectorProjection * aVectorProjection

			local aScalar do
				-- If segments are not parallel, compute cloest point on line (not
				-- segment) a to line b and clamp to segment a. Otherwise, pick
				-- arbitrary seg a scalar (0 in this case).
				if denom ~= 0 then
					aScalar = math.clamp((aVectorProjection * bOffsetProjection - aOffsetProjection * bLengthSq) / denom, 0, 1)
				else
					aScalar = 0
				end
			end

			local bScalar = (aVectorProjection * aScalar + bOffsetProjection) / bLengthSq

			-- If bScalar within [0, 1] continue to point computation. Otherwise clamp, and recompute aScalar
			local closestPtB
			if bScalar < 0 then
				closestPtB = b1
				aScalar = math.clamp(-aOffsetProjection / aLengthSq, 0, 1)
			elseif bScalar > 1 then
				closestPtB = b2
				aScalar = math.clamp((aVectorProjection - aOffsetProjection) / aLengthSq, 0, 1)
			end

			local closestPtA = a1 + (aVector * aScalar)
			closestPtB = closestPtB or b1 + (bVector * bScalar)

			return closestPtA, closestPtB
		end
	end
end

return LineSegments
