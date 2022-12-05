local ClientManager = {}
ClientManager.__index = ClientManager

function ClientManager.new()
	local self = setmetatable({}, ClientManager)

	return self
end

return ClientManager.new()
