function EnsureProfileIsSelected()
	if not ProfileSelected() then
		return false
	end
	return true
end
function ChangeScreenFunction(screen)
	return function() ChangeScreen(screen) end
end
local items = {
	{name="Play", 
		onClick=ChangeScreenFunction("ScreenSelectMusic"),
		condition=EnsureProfileIsSelected
	},
	{name="Profile", 
		onClick=ChangeScreenFunction("ScreenSelectProfile")
	},
	{name="Multiplayer", 
		onClick = function()
			
		end, 
		condition = function()
			return false
		end
	},
	{name="Online Profile", 
		onClick = function()
		
		end, 
		condition = function()
			return false
		end
	},
	{name="Downloads", 
		onClick = function()
		
		end, 
		condition = function()
			return false
		end
	},
	{name="Options", 
		onClick=ChangeScreenFunction("ScreenOptions"),
	},
	{name="Exit", 
		onClick=ChangeScreenFunction("ScreenExit"),
	},
}
local menuWidth = SCREEN_WIDTH
local menuHeight = themeConfig:get_data().positions["mainMenuHeight"]
local menuY = 0
local menuX = 0
local itemWidth =menuWidth/#items
local itemHeight= menuHeight
local borderWidth = themeConfig:get_data().positions["borderWidth"]
local fontScale=0.75
local borderColor = getMainColor('border')
local disabledColor = getMainColor('negative')
local buttonColor = getMainColor('frames')
local currentButtonColor = getMainColor('highlight')
local fontColor = getMainColor('positive')
local function input(event)
	if event.type ~= "InputEventType_Release" then
		if event.DeviceInput.button == "DeviceButton_left mouse button" then
			MESSAGEMAN:Broadcast("LeftClick")
		elseif event.DeviceInput.button == "DeviceButton_right mouse button" then
			MESSAGEMAN:Broadcast("RightClick")
		end
	end
	return false
end
local moving =false
local t = Def.ActorFrame {
	OnCommand=function(self) 
		SCREENMAN:GetTopScreen():AddInputCallback(input)
		self:xy(menuX, menuY)
	end,
	EndTweenCommand=function(self)
		moving=false
	end,
	HideMainMenuMessageCommand=function(self)
		if not moving then
			moving = true
			self:linear(0.2):y(menuY-menuHeight+borderWidth):queuecommand("EndTween")
		end
	end,
	ShowMainMenuMessageCommand=function(self)
		if not moving then
			moving = true
			self:linear(0.2):y(menuY):queuecommand("EndTween")
		end
	end,
}
for i=1,#items do
	t[#t+1] = Def.ActorFrame {
		InitCommand=function(self)
			self:xy(itemWidth*(i-1),0)
		end;
		Def.Quad {
			InitCommand=function(self)
				self:xy(itemWidth/2,itemHeight/2):zoomto(itemWidth,itemHeight)
				if items[i].condition==nil or items[i].condition() then
					self:diffuse(buttonColor)
				else
					self:diffuse(disabledColor)
				end
			end;
			OnCommand=function(self)
				if items[i].condition==nil or items[i].condition() then
					self:diffuse(buttonColor)
				else
					self:diffuse(disabledColor)
				end
					
			end;
			LeftClickMessageCommand=function(self)
				if items[i].onClick and isOver(self) and (not items[i].condition or items[i].condition()) then
					items[i].onClick()
				end
			end,
		},
		LoadFont("Common Large")..{
			InitCommand=function(self)
				self:xy(itemWidth/2,itemHeight/2):zoom(fontScale):maxwidth(itemWidth*0.9):diffuse(fontColor):halign(0.5)
				self:settext(items[i].name)
			end,
		},
	}
end
t[#t+1] = Def.ActorFrame {
	InitCommand=function(self)
		self:xy(0,0)
	end;
	Def.Quad {
		InitCommand=function(self)
			self:xy(menuWidth/2,borderWidth/2):zoomto(menuWidth,borderWidth)
			self:diffuse(borderColor):fadebottom(0.85)
		end;
	},
	Def.Quad {
		InitCommand=function(self)
			self:xy(menuWidth/2,menuHeight-borderWidth/2):zoomto(menuWidth,borderWidth)
			self:diffuse(borderColor):fadetop(0.85)
		end;
	},
	Def.Quad {
		InitCommand=function(self)
			self:xy(borderWidth/2,menuHeight/2):zoomto(borderWidth,menuHeight)
			self:diffuse(borderColor):faderight(0.85)
		end;
	},
	Def.Quad {
		InitCommand=function(self)
			self:xy(menuWidth-borderWidth/2,menuHeight/2):zoomto(borderWidth,menuHeight)
			self:diffuse(borderColor):fadeleft(0.85)
		end;
	},
}
for i=1,#items do
	t[#t][#(t[#t])+1] = Def.Quad {
		InitCommand=function(self)
			self:xy(itemWidth*i-borderWidth/2,menuHeight/2):zoomto(borderWidth,menuHeight)
			self:diffuse(borderColor)
		end;
	}
end
--retracting button
t[#t+1] = Def.Quad {
	hidden=false,
	InitCommand=function(self)
		self:xy(menuWidth/2,menuHeight):zoomto(25,25):diffusealpha(0)
		self.hidden=false
	end;
	LeftClickMessageCommand=function(self)
		if isOver(self) and not moving then
			if self.hidden then
				MESSAGEMAN:Broadcast("ShowMainMenu")
			else
				MESSAGEMAN:Broadcast("HideMainMenu")
			end
			self.hidden=not self.hidden
		end
	end,
}
downArrow = arrow_actor(menuWidth/2, menuHeight, -180,25, borderColor, buttonColor)
upArrow = arrow_actor(menuWidth/2, menuHeight, 0,25, borderColor, buttonColor)
downArrow.HideMainMenuMessageCommand = function(self)
	self:visible(true)
end
upArrow.HideMainMenuMessageCommand = function(self)
	self:visible(false)
end
downArrow.OnCommand = function(self)
	self:visible(false)
end
upArrow.ShowMainMenuMessageCommand = function(self)
	self:visible(true)
end
downArrow.ShowMainMenuMessageCommand = function(self)
	self:visible(false)
end
t[#t+1] = downArrow
t[#t+1] = upArrow
return t;