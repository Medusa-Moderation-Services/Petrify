--!nonstrict

local module: any = {}
local rService: RunService = game:GetService("RunService")
local MinimunTimeRegister: BindableEvent = Instance.new("BindableEvent")
local Registers = {}

rService.Heartbeat:Connect(function(dt)
	MinimunTimeRegister:Fire()

	for Register, Time in pairs(Registers) do
		Time -= dt

		if Time < 0 then
			Register:Fire()
			Registers[Register] = 0
		else
			Registers[Register] = Time
		end
	end
end)

local function GetRegister(Time)
	for Register, RegisterTime in pairs(Registers) do
		if RegisterTime == 0 then
			Registers[Register] = Time
			return Register
		end
	end

	local NewBindable = Instance.new("BindableEvent")
	Registers[NewBindable] = Time

	return NewBindable
end

local Function = setmetatable({}, {
	__call = function(_, Time) 
		if not Time or Time == 0 then
			MinimunTimeRegister.Event:Wait()
		else
			local Register = GetRegister(Time)
			Register.Event:Wait()
		end
	end
})

module.Wait = Function

return module