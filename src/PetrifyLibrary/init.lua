local PetrifyLibrary = {}
PetrifyLibrary.__index = PetrifyLibrary

function PetrifyLibrary.new()
	local self = setmetatable({}, PetrifyLibrary)

	return self
end

return PetrifyLibrary.new()
