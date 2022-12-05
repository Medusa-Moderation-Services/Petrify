local WaitControl = require(script.Modules.WaitControl)
local Module3d = require(script.Modules.Module3D)

local PartClone = script.Part
local Initalized = false
local Model3D = nil

local Frames = {}
local module = {}

--[[

Original Image:
https://i.imgur.com/vl4kAgy.png
]]


function module.Init(ScreenGui)
	if Initalized then return warn("BlurUI has already been initalized.") end
	
	Initalized = true
	Model3D = Module3d:Attach3D(ScreenGui,PartClone,false)
	return true
end

function module.AddFrame(Frame)
	if not Initalized then return warn("BlurUI has not been initalized, you need to initalize it before adding frames!") end
	
	local FrameClone = Frame:Clone()
	FrameClone.Parent = PartClone.BillboardGui
	Frame.Visible = false
	
	Frames[Frame] = FrameClone
	return true
end

function module.RemoveFrame(Frame)
	if not Initalized then return warn("BlurUI has not been initalized, you need to initalize it before removing frames!") end
	
	local FrameFound = Frames[Frame]
	
	if not FrameFound then return warn("This frame could not be found.") end
	
	FrameFound:Destroy()
	Frame.Visible = true
	Frames[Frame] = nil
	
	return true
end

function module.Destroy()
	if not Initalized then return warn("BlurUI has not been initalized, you need to initalize it before you can destroy it!") end
	
	Initalized = false
	PartClone.BillboardGui:ClearAllChildren()
	PartClone.Parent = script
	Frames = {}
	Model3D:End()
end

return module