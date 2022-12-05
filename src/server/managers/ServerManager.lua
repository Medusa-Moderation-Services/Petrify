local ServerManager = {}
ServerManager.__index = ServerManager

function ServerManager.new()
	local self = setmetatable({}, ServerManager)

	return self
end

return ServerManager.new()
