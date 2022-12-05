local Class = {}
Class.__index = Class

function Class.new()
	local self = setmetatable({}, Class)

	return self
end

function Class:Destroy() end

return Class.new()
