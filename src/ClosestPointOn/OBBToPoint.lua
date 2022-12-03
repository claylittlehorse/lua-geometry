-- Reference: http://www.r-5.org/files/books/computers/algo-list/realtime-3d/Christer_Ericson-Real-Time_Collision_Detection-EN.pdf
-- Page 132-134: Distance to Closest Point on OBB

local function ClosestPointOnOBBToPoint(OBBSize, OBBCFrame, pointA)
	local d = OBBCFrame.Position - pointA
	local u0 = OBBCFrame.RightVector
	local u1 = OBBCFrame.UpVector
	local u2 = OBBCFrame.LookVector

	local qx = math.clamp(-u0:Dot(d), -OBBSize.X, OBBSize.X)
	local qy = math.clamp(-u1:Dot(d), -OBBSize.Y, OBBSize.Y)
	local qz = math.clamp(-u2:Dot(d), -OBBSize.Z, OBBSize.Z)
	return pointA + qx * u0 + qy * u1 + qz * u2
end

return ClosestPointOnOBBToPoint
