local CircularProgress = {}

function ShiftRange(Range1, Range2, Value)
	return Range2[1] + ((Range2[2] - Range2[1]) / (Range1[2] - Range1[1])) * (Value - Range1[1])
end

local function UpdateFill(self, Property)
	local Circle = self.Instance.Circle
	local QuarterCircle = Circle.QuarterCircle

	local Rotation = self.Rotation -- new rotation
	if Property == "Progress" then
		Rotation = self.Progress * 3.6
	end
	Rotation = math.fmod(Rotation, 360.1)

	--Set fill
	local Right = Circle.RightClip.Circle.UIGradient
	local Left = Circle.LeftClip.Circle.UIGradient
	if Rotation < 180 and Rotation > -180 then
		Circle.RightClip.HideCircle.Visible = true
		Right.Rotation = Rotation
		Left.Rotation = 0
	else
		Circle.RightClip.HideCircle.Visible = false
		Right.Rotation = 180
		Left.Rotation = Rotation - 180
	end

	--Check if the fill should be rounded
	if self.Rounded == true then
		--Create dot
		local Dot = QuarterCircle:FindFirstChild("Dot")
		if not Dot then
			Dot = QuarterCircle.CenterDot:Clone()
			Dot.Name = "Dot"
			Dot.Parent = QuarterCircle
		end

		--Set dot pos
		local MathRotation
		if Rotation <= 90 then MathRotation = (360-90) + Rotation else MathRotation = Rotation - 90 end
		MathRotation = math.rad(MathRotation)

		local X = math.cos(MathRotation)
		local Y = math.sin(MathRotation)

		local Range1 = {-1, 1}
		local Range2 = {0, 1}
		Dot.AnchorPoint = Vector2.new(ShiftRange(Range1, Range2, X), ShiftRange(Range1, Range2, Y))	
		Dot.Position = UDim2.fromScale(X, Y)

		self.Progress = Rotation / 3.6
		self.Rotation = Rotation
	end
end

--All the functions for updating properties
local Update = {
	Progress = function(self) UpdateFill(self, "Progress") end;
	Rotation = function(self) UpdateFill(self) end;


	Position = function(self) self.Instance.Position = self.Position end;
	AnchorPoint = function(self) self.Instance.AnchorPoint = self.AnchorPoint end;
	Size = function(self) self.Instance.Size = UDim2.fromScale(self.Size, self.Size) end;
	CircleSize = function(self) self.Instance.Circle.Size = UDim2.fromScale(self.CircleSize, self.CircleSize) end;


	Color = function(self) 
		self.Instance.Circle.LeftClip.Circle.BackgroundColor3 = self.Color
		self.Instance.Circle.RightClip.Circle.BackgroundColor3 = self.Color
		for i, v in pairs(self.Instance.Circle.QuarterCircle:GetChildren()) do
			if v.Name == "Dot" or v.Name == "CenterDot" then v.BackgroundColor3 = self.Color end
		end
	end;
	BGColor = function(self)
		self.Instance.BG.BackgroundColor3 = self.BGColor
		for i, v in pairs(self.Instance.Circle:GetDescendants()) do
			if v.Name == "HideCircle" then v.BackgroundColor3 = self.BGColor end
		end
	end;
	Thickness = function(self)
		local Thickness = 1 - self.Thickness

		self.Instance.Circle.HideCircle.Visible = true
		if self.Thickness == 1 then self.Instance.Circle.HideCircle.Visible = false end

		self.Instance.Circle.HideCircle.Size = UDim2.fromScale(Thickness, Thickness)
		for i, v in pairs(self.Instance.Circle.QuarterCircle:GetChildren()) do
			if v.Name == "Dot" or v.Name == "CenterDot" then
				local NewSize = self.Thickness
				v.Size = UDim2.fromScale(self.Thickness, self.Thickness)
			end
		end
	end;
	BGRoundness = function(self) self.Instance.BG.UICorner.CornerRadius = UDim.new(self.BGRoundness) end;


	Rounded = function(self)
		for i, v in pairs(self.Instance.Circle.QuarterCircle:GetChildren()) do
			v.Visible = self.Rounded
		end
	end;


	Parent = function(self) 
		if self.Parent == nil then
			local ScreenGui = Instance.new("ScreenGui")
			ScreenGui.Parent = game.Players.LocalPlayer.PlayerGui
			ScreenGui.Name = "CircularProgress"
			self.Instance.Parent = ScreenGui
			self.Parent = ScreenGui
		else
			self.Instance.Parent = self.Parent
		end
	end
}

local RunningTweens = {}

function CircularProgress.new(Properties)
	local ProgressCircle = {}

	ProgressCircle.Progress = 0 -- from 0 to 100 -|interchangable
	ProgressCircle.Rotation = 0 -- from 0 to 360 -|interchangable

	ProgressCircle.Position = UDim2.fromScale(0.04, 0.95)
	ProgressCircle.AnchorPoint = Vector2.new(0, 0)
	ProgressCircle.Size = 0.2 -- from 0 to 1
	ProgressCircle.CircleSize = 0.7 -- from 0 to 1

	ProgressCircle.Color = Color3.fromRGB(255, 255, 255)
	ProgressCircle.BGColor = Color3.fromRGB(30, 30, 30)
	ProgressCircle.Thickness = 0.3 -- from 0 to 1
	ProgressCircle.BGRoundness = 0.2 -- from 0 to 1

	ProgressCircle.Rounded = true

	local Object = script.ProgressCircle:Clone()
	ProgressCircle.Parent = nil

	if Properties then
		for i, v in pairs(Properties) do ProgressCircle[i] = v end
	end

	ProgressCircle.Instance = Object

	for i, v in pairs(Update) do
		v(ProgressCircle)
	end
	
	local MetaTable = setmetatable({}, { 
		__index = function(T, Key, Value)
			if ProgressCircle[Key] then
				return ProgressCircle[Key]
			end
			if CircularProgress[Key] then
				return CircularProgress[Key]
			end
		end,
		__newindex = function(T, Property, Value)
			if Update[Property] then
				ProgressCircle[Property] = Value
				Update[Property](ProgressCircle)
			end
		end
	})
	RunningTweens[MetaTable] = {}

	return MetaTable
end

function CircularProgress:Tween(TweenInfo, Properties)
	local TweenService = game:GetService("TweenService")
	local PropertyCache = {}
	
	--Cache the properties to use as the beginning keyframe for tweening
	for i, v in pairs(Properties) do
		PropertyCache[i] = self[i]
	end
	
	local function GetAlphaValue(Start, End, Alpha) return Start + ((End - Start) * Alpha) end

	local TimeGoal = TweenInfo.Time
	local RepeatCount = TweenInfo.RepeatCount
	local TimeDelay = TweenInfo.DelayTime
	local Reversing = false
	local Time = 0
	local UID = {}

	local PlayTween = game:GetService("RunService").RenderStepped:Connect(function(Delta)
		if Reversing == false then Time += Delta else Time -= Delta end
		if Time >= TimeDelay or Reversing then
			--Position in the tween keyframes
			local TimeAlpha = (Time - TimeDelay) / TimeGoal
			
			--Check if repeats have run out
			if RepeatCount <= -1 then
				RunningTweens[self][UID]:Disconnect()
				RunningTweens[self][UID] = nil
				return
			end
			
			--Check if the animation has ended or if it's reversing
			if TimeAlpha >= 1 then
				if TweenInfo.Reverses == true then
					Reversing = true
				else
					Time = 0
					RepeatCount -= 1
				end
			elseif TimeAlpha <= 0 then
				Reversing = false
				Time = 0
				RepeatCount -= 1
			end
			
			--Get the correct alpha value for setting up tween keyframes
			local Alpha = TweenService:GetValue(TimeAlpha, TweenInfo.EasingStyle, TweenInfo.EasingDirection)
			
			--Support other data types
			for i, v in pairs(Properties) do
				if typeof(v) == "number" then
					self[i] = GetAlphaValue(PropertyCache[i], v, Alpha)
				elseif typeof(v) == "UDim2" then
					local NewUdim2 = UDim2.new(GetAlphaValue(PropertyCache[i].X.Scale, v.X.Scale, Alpha), GetAlphaValue(PropertyCache[i].X.Offset, v.X.Offset, Alpha), GetAlphaValue(PropertyCache[i].Y.Scale, v.Y.Scale, Alpha), GetAlphaValue(PropertyCache[i].Y.Offset, v.Y.Offset, Alpha))
					self[i] = NewUdim2
				elseif typeof(v) == "Vector2" then
					local NewVector2 = Vector2.new(GetAlphaValue(PropertyCache[i].X, v.X, Alpha), GetAlphaValue(PropertyCache[i].Y, v.Y, Alpha))
					self[i] = NewVector2
				elseif typeof(v) == "Color3" then
					local NewColor = Color3.new(GetAlphaValue(PropertyCache[i].R, v.R, Alpha), GetAlphaValue(PropertyCache[i].G, v.G, Alpha), GetAlphaValue(PropertyCache[i].B, v.B, Alpha))
					self[i] = NewColor
				end
			end
		end
	end)
	RunningTweens[self][UID] = PlayTween
end

function CircularProgress:Animate(Animation)
	local Animations = require(script.PresetAnimations)
	
	local Loop = Animations[Animation](self)
	
	if Loop then table.insert(RunningTweens[self], Loop) end
end

function CircularProgress:Destroy()
	self.Instance:Destroy()
	
	--Disconnect all connections related to the progress bar
	for i, v in pairs(RunningTweens[self]) do v:Disconnect() end
	RunningTweens[self] = nil
	
	setmetatable(self, nil)
end

return CircularProgress
