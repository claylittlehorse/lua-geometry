local ClosestPointOnLineSegmentToPoint = require(script.Parent.Parent.ClosestPointOn.LineSegmentToPoint)
local ClosestPointsOfLineSegments = require(script.Parent.LineSegments)
local Utils = require(script.Parent.Parent.Utils)
local getIntersectionForOBBRaw = Utils.getIntersectionForOBBRaw
local getIntersectionForRectangle2dRaw = Utils.getIntersectionForRectangle2dRaw_centerOrigin

local function clampSegmentPointsToOBB(segA, segB, OBBSize, OBBCFrame)
	local xSize = OBBSize.X / 2
	local ySize = OBBSize.Y / 2
	local zSize = OBBSize.Z / 2

	local boxOrigin = OBBCFrame.p
	local xAxis = OBBCFrame.RightVector
	local yAxis = OBBCFrame.UpVector
	local zAxis = OBBCFrame.LookVector

	local segARelative = segA - boxOrigin
	local segBRelative = segB - boxOrigin

	local aX = (segARelative):Dot(xAxis)
	local aY = (segARelative):Dot(yAxis)
	local aZ = (segARelative):Dot(zAxis)

	local bX = (segBRelative):Dot(xAxis)
	local bY = (segBRelative):Dot(yAxis)
	local bZ = (segBRelative):Dot(zAxis)

	-- Reg is short for Region
	local aXReg = aX < -xSize and -1 or aX < xSize and 0 or 1
	local aYReg = aY < -ySize and -1 or aY < ySize and 0 or 1
	local aZReg = aZ < -zSize and -1 or aZ < zSize and 0 or 1

	local bXReg = bX < -xSize and -1 or bX < xSize and 0 or 1
	local bYReg = bY < -ySize and -1 or bY < ySize and 0 or 1
	local bZReg = bZ < -zSize and -1 or bZ < zSize and 0 or 1

	-- If segment is entirely inside of OBB, return segment unclamped.
	if aXReg == 0 and aYReg == 0 and aZReg == 0 and bXReg == 0 and bYReg == 0 and bZReg == 0 then
		return segA, segB
	end

	-- If one point is within the bounds of the OBB (and by elimination, the
	-- other point is not.), clamp the point which is outside the bounding box
	if bXReg == 0 and bYReg == 0 and bZReg == 0 then
		local aXClamped, aYClamped, aZClamped = getIntersectionForOBBRaw(aX, aY, aZ, bX, bY, bZ, xSize, ySize, zSize)
		return boxOrigin + aXClamped * xAxis + aYClamped * yAxis + aZClamped * zAxis, segB
	elseif aXReg == 0 and aYReg == 0 and aZReg == 0 then
		local bXClamped, bYClamped, bZClamped = getIntersectionForOBBRaw(bX, bY, bZ, aX, aY, aZ, xSize, ySize, zSize)
		return segA, boxOrigin + bXClamped * xAxis + bYClamped * yAxis + bZClamped * zAxis
	end

	local sharedAxes = 0

	if aXReg == bXReg then
		sharedAxes = 1
	end
	if aYReg == bYReg then
		sharedAxes = sharedAxes + 1
	end
	if aZReg == bZReg then
		sharedAxes = sharedAxes + 1
	end

	if sharedAxes == 3 then
		if aXReg ~= 0 and aYReg ~= 0 and aZReg ~= 0 then
			-- Clamp to corner
			return boxOrigin + (aXReg * xSize * xAxis) + (aYReg * ySize * yAxis) + (aZReg * zSize * zAxis)
		else
			-- Edges
			if aXReg == 0 and aYReg ~= 0 and aZReg ~= 0 then
				-- Return edge running along X axis
				local cornerBase = (aYReg * ySize * yAxis) + (aZReg * zSize * zAxis)
				return boxOrigin + (xSize * xAxis) + cornerBase,
					   boxOrigin + (-xSize * xAxis) + cornerBase
			elseif aXReg ~= 0 and aYReg == 0 and aZReg ~= 0 then
				-- Return edge running along Y axis
				local cornerBase = (aXReg * xSize * xAxis) + (aZReg * zSize * zAxis)
				return boxOrigin + (ySize * yAxis) + cornerBase,
					   boxOrigin + (-ySize * yAxis) + cornerBase
			elseif aXReg ~= 0 and aYReg ~= 0 and aZReg == 0 then
				-- Return edge running along Z axis
				local cornerBase = (aXReg * xSize * xAxis) + (aYReg * ySize * yAxis)
				return boxOrigin + (zSize * zAxis) + cornerBase,
					   boxOrigin + (-zSize * zAxis) + cornerBase

			-- Sides
			elseif aXReg == 0 and aYReg == 0 then
				-- Clamp to X-Y Plane (Front / Back side)
				local aXClamped, aYClamped = getIntersectionForRectangle2dRaw(aX, aY, bX, bY, xSize, ySize)
				local bXClamped, bYClamped = getIntersectionForRectangle2dRaw(bX, bY, aX, aY, xSize, ySize)

				local zPos = (aZReg * zSize * zAxis)

				return boxOrigin + aXClamped * xAxis + aYClamped * yAxis + zPos,
					   boxOrigin + bXClamped * xAxis + bYClamped * yAxis + zPos
			elseif aXReg == 0 and aZReg == 0 then
				-- Clamp to X-Z Plane (Top / Bottom side)
				local aXClamped, aZClamped = getIntersectionForRectangle2dRaw(aX, aZ, bX, bZ, xSize, zSize)
				local bXClamped, bZClamped = getIntersectionForRectangle2dRaw(bX, bZ, aX, aZ, xSize, zSize)

				local yPos = (aYReg * ySize * yAxis)

				return boxOrigin + aXClamped * xAxis + aZClamped * zAxis + yPos,
					   boxOrigin + bXClamped * xAxis + bZClamped * zAxis + yPos
			elseif aYReg == 0 and aZReg == 0 then
				-- Clamp to Y-Z Plane (Left / Right side)
				local aYClamped, aZClamped = getIntersectionForRectangle2dRaw(aY, aZ, bY, bZ, ySize, zSize)
				local bYClamped, bZClamped = getIntersectionForRectangle2dRaw(bY, bZ, aY, aZ, ySize, zSize)

				local xPos = (aXReg * xSize * xAxis)

				return boxOrigin + aYClamped * yAxis + aZClamped * zAxis + xPos,
					   boxOrigin + bYClamped * yAxis + bZClamped * zAxis + xPos
			end
		end
	elseif sharedAxes == 2 then
		-- Edges
		if aXReg ~= bXReg and aYReg ~= 0 and aXReg ~= 0 then
			-- Return edge running along X axis
			local cornerBase = (aYReg * ySize * yAxis) + (aZReg * zSize * zAxis)
			return boxOrigin + (xSize * xAxis) + cornerBase,
				   boxOrigin + (-xSize * xAxis) + cornerBase
		elseif aXReg ~= 0 and aYReg ~= bYReg and aZReg ~= 0 then
			-- Return edge running along Y axis
			local cornerBase = (aXReg * xSize * xAxis) + (aZReg * zSize * zAxis)
			return boxOrigin + (ySize * yAxis) + cornerBase,
				   boxOrigin + (-ySize * yAxis) + cornerBase
		elseif aXReg ~= 0 and aYReg ~= 0 and aZReg ~= bZReg then
			-- Return edge running along Z axis
			local cornerBase = (aXReg * xSize * xAxis) + (aYReg * ySize * yAxis)
			return boxOrigin + (zSize * zAxis) + cornerBase,
				   boxOrigin + (-zSize * zAxis) + cornerBase

		-- Sides
		elseif aXReg ~= 0 and ((aYReg == 0 and aZReg ~= bZReg) or (aZReg == 0 and aYReg ~= bYReg)) then
			-- Clamp to Y-Z Plane (Left / Right side)
			local aYClamped, aZClamped = getIntersectionForRectangle2dRaw(aY, aZ, bY, bZ, ySize, zSize)
			local bYClamped, bZClamped = getIntersectionForRectangle2dRaw(bY, bZ, aY, aZ, ySize, zSize)

			local xPos = (aXReg * xSize * xAxis)

			return boxOrigin + aYClamped * yAxis + aZClamped * zAxis + xPos,
				   boxOrigin + bYClamped * yAxis + bZClamped * zAxis + xPos
		elseif aYReg ~= 0 and ((aXReg == 0 and aZReg ~= bZReg) or (aZReg == 0 and aXReg ~= bXReg)) then
			-- Clamp to X-Z Plane (Top / Bottom side)
			local aXClamped, aZClamped = getIntersectionForRectangle2dRaw(aX, aZ, bX, bZ, xSize, zSize)
			local bXClamped, bZClamped = getIntersectionForRectangle2dRaw(bX, bZ, aX, aZ, xSize, zSize)

			local yPos = (aYReg * ySize * yAxis)

			return boxOrigin + aXClamped * xAxis + aZClamped * zAxis + yPos,
				   boxOrigin + bXClamped * xAxis + bZClamped * zAxis + yPos
		elseif aZReg ~= 0 and ((aYReg == 0 and aXReg ~= bXReg) or (aXReg == 0 and aYReg ~= bYReg)) then
			-- Clamp to X-Y Plane (Front / Back side)
			local aXClamped, aYClamped = getIntersectionForRectangle2dRaw(aX, aY, bX, bY, xSize, ySize)
			local bXClamped, bYClamped = getIntersectionForRectangle2dRaw(bX, bY, aX, aY, xSize, ySize)

			local zPos = (aZReg * zSize * zAxis)

			return boxOrigin + aXClamped * xAxis + aYClamped * yAxis + zPos,
				   boxOrigin + bXClamped * xAxis + bYClamped * yAxis + zPos
		end
	elseif sharedAxes == 1 then
		if aXReg ~= 0 and aYReg ~= bYReg and aZReg ~= bZReg then
			-- Clamp to Y-Z Plane (Left / Right side)
			local aYClamped, aZClamped = getIntersectionForRectangle2dRaw(aY, aZ, bY, bZ, ySize, zSize)
			local bYClamped, bZClamped = getIntersectionForRectangle2dRaw(bY, bZ, aY, aZ, ySize, zSize)

			local xPos = (aXReg * xSize * xAxis)

			return boxOrigin + aYClamped * yAxis + aZClamped * zAxis + xPos,
				   boxOrigin + bYClamped * yAxis + bZClamped * zAxis + xPos
		elseif aXReg ~= bXReg and aYReg ~= 0 and aZReg ~= bZReg then
			-- Clamp to X-Z Plane (Top / Bottom side)
			local aXClamped, aZClamped = getIntersectionForRectangle2dRaw(aX, aZ, bX, bZ, xSize, zSize)
			local bXClamped, bZClamped = getIntersectionForRectangle2dRaw(bX, bZ, aX, aZ, xSize, zSize)

			local yPos = (aYReg * ySize * yAxis)

			return boxOrigin + aXClamped * xAxis + aZClamped * zAxis + yPos,
				   boxOrigin + bXClamped * xAxis + bZClamped * zAxis + yPos
		elseif aXReg ~= bXReg and aYReg ~= bYReg and aZReg ~= 0 then
			-- Clamp to X-Y Plane (Front / Back side)
			local aXClamped, aYClamped = getIntersectionForRectangle2dRaw(aX, aY, bX, bY, xSize, ySize)
			local bXClamped, bYClamped = getIntersectionForRectangle2dRaw(bX, bY, aX, aY, xSize, ySize)

			local zPos = (aZReg * zSize * zAxis)

			return boxOrigin + aXClamped * xAxis + aYClamped * yAxis + zPos,
				   boxOrigin + bXClamped * xAxis + bYClamped * yAxis + zPos
		end
	end

	local aXClamped, aYClamped, aZClamped = getIntersectionForOBBRaw(aX, aY, aZ, bX, bY, bZ, xSize, ySize, zSize)
	local bXClamped, bYClamped, bZClamped = getIntersectionForOBBRaw(bX, bY, bZ, aX, aY, aZ, xSize, ySize, zSize)

	return boxOrigin + aXClamped * xAxis + aYClamped * yAxis + aZClamped * zAxis,
		   boxOrigin + bXClamped * xAxis + bYClamped * yAxis + bZClamped * zAxis
end

local function ClosestPointsOfLineSegmentAndOBB(segA, segB, OBBSize, OBBCFrame)
	local clampedA, clampedB = clampSegmentPointsToOBB(segA, segB, OBBSize, OBBCFrame)

	if not clampedB then
		return ClosestPointOnLineSegmentToPoint(segA, segB, clampedA), clampedA
	end

	return ClosestPointsOfLineSegments(segA, segB, clampedA, clampedB)
end

return ClosestPointsOfLineSegmentAndOBB
