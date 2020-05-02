return {
	-- Roblox vectors use single precision values, so this is a good quantity for
	-- epsilon. If we were using a lua implementation of vectors (or just lua
	-- numbers in general), our math would have double precision and 1e-09 would probably be better suited.
	EPSILON = 1e-06 -- (0.000001)
}
