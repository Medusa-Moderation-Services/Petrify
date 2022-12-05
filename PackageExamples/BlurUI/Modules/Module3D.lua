local RunService = game:GetService("RunService")

local WaitControl = require(script.Parent.WaitControl)

local ModuleAPI = {}
local Camera = game.Workspace.Camera
local Player = game.Players.LocalPlayer
local GetMouse = Player.GetMouse

local CFrameAngles = CFrame.Angles
local Instancenew = Instance.new
local rad,tan,max,huge,abs = math.rad,math.tan,math.max,math.huge,math.abs
local tableinsert = table.insert

local function GetScreenResolution()
	local Mouse = GetMouse(Player)
	if Mouse then
		local ViewSizeX,ViewSizeY = Mouse.ViewSizeX,Mouse.ViewSizeY
		if ViewSizeX > 0 and ViewSizeY > 0 then
			return ViewSizeX,ViewSizeY
		end
	end
	local PlayerGui = Player:FindFirstChild("PlayerGui")
	if PlayerGui then
		local ScreenGui
		for _,C in pairs(PlayerGui:GetChildren()) do
			if C:IsA("ScreenGui") then
				ScreenGui = C
			end
		end
		if not ScreenGui then
			ScreenGui = Instance.new("ScreenGui",PlayerGui)
			WaitControl.Wait(.1)
		end
		return ScreenGui.AbsoluteSize.X,ScreenGui.AbsoluteSize.Y
	end
	return error("ERROR: Can't get client resolution")
end

local function GetDepthForWidth(PartWidth,VisibleSize,ResolutionX,ResolutionY,FieldOfView)
	local AspectRatio = ResolutionX/ResolutionY
	local HFactor = tan(rad(FieldOfView)/2)
	local WFactor = AspectRatio*HFactor
	
	return abs(-0.5*ResolutionX*PartWidth/(VisibleSize*WFactor))
end

function ModuleAPI:Attach3D(GuiObj,Model,SizeOverride)
	local Index = {}
	local Objs = {}
	Model.Parent = Camera
	table.insert(Objs,Model)
	
	local CF = CFrame.new(0,0,0)
	
	local ModelSize = Model.Size
	local Active = true
	
	local CFramenew,CFrameAngles = CFrame.new,CFrame.Angles
	local components = CFramenew().components
	local HighCF = CFramenew(0,100000,0)
	local ScreenPointToRay = Camera.ScreenPointToRay
	local Width = max(Model.Size.X,Model.Size.Y,Model.Size.Z)
	
	local WasMoved = false
	local MaxFieldOfView = 120
	local function UpdateModel()
		if Active then
			local AbsoluteSize,AbsolutePosition = GuiObj.AbsoluteSize,GuiObj.AbsolutePosition
			local SizeX,SizeY = AbsoluteSize.X,AbsoluteSize.Y
			local PointX,PointY = AbsolutePosition.X + (SizeX/2),AbsolutePosition.Y + (SizeY/2)
			
			Model.BillboardGui.Size = UDim2.new(0,AbsoluteSize.X,0,AbsoluteSize.Y)
			
			local Viewport = Camera.ViewportSize
			local ViewportX,ViewportY = Viewport.X,Viewport.Y
			local FieldOfView = Camera.FieldOfView
			local AngleX,AngleY = (ViewportX/ViewportY) * FieldOfView,FieldOfView
			
			local CenterX,CenterY  = ViewportX/2,ViewportY/2
			local CenterXMult,CenterYMult = (PointX - CenterX)/CenterX,(PointY - CenterY)/CenterY
			if AngleX > MaxFieldOfView then
				AngleY = FieldOfView * (MaxFieldOfView/AngleX)
				AngleX = MaxFieldOfView
			end
			
			local PositionRay = ScreenPointToRay(Camera,PointX,PointY,GetDepthForWidth(Width,(SizeX < SizeY and SizeX or SizeY),ViewportX,ViewportY,FieldOfView))
			local Position = PositionRay.Origin + PositionRay.Direction
			local PositionX,PositionY,PositionZ = Position.X,Position.Y,Position.Z
			local _,_,_,A,B,C,D,E,F,G,H,I = components(Camera.CFrame)
			if PositionX == huge or PositionX == -huge then PositionX = 0 end
			if PositionY == huge or PositionY == -huge then PositionY = 0 end
			if PositionZ == huge or PositionZ == -huge then PositionZ = 0 end
			
			local NewCF = CFramenew(PositionX,PositionY,PositionZ,A,B,C,D,E,F,G,H,I) * CFrameAngles(-rad(AngleY/2) * CenterYMult,-rad(AngleX/2) * CenterXMult,0)
			Model.CFrame = NewCF * CF
			WasMoved = false
		elseif WasMoved == false then
			Model.CFrame = HighCF
			WasMoved = true
		end
	end
	
	local Connections = {}
	tableinsert(Connections,Camera:GetPropertyChangedSignal("FieldOfView"):Connect(UpdateModel))
	tableinsert(Connections,Camera:GetPropertyChangedSignal("CFrame"):Connect(UpdateModel))
	tableinsert(Connections,Camera:GetPropertyChangedSignal("ViewportSize"):Connect(UpdateModel))
	tableinsert(Connections,GuiObj:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateModel))
	tableinsert(Connections,GuiObj:GetPropertyChangedSignal("AbsolutePosition"):Connect(UpdateModel))
	
	UpdateModel()

	function Index:End()
		if #Connections ~= 0 then
			for _,Con in pairs(Connections) do
				Con:disconnect()
			end
			Connections = {}

			M:Destroy()
		end
	end

	Index.Object3D = M
	return Index
end

return ModuleAPI