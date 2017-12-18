
function fillNilTableFieldsFrom(table1, defaultTable)
	 for key,value in pairs(defaultTable) do
		if table1[key] == nil then
			table1[key] = defaultTable[key]
		end
	end
end
local itemH = 25
local default = {
	width= themeConfig:get_data().positions.sideBarWidth,
	itemWidth = themeConfig:get_data().positions.sideBarWidth,
	x=0,
	y=themeConfig:get_data().positions.mainMenuHeight,
	height = SCREEN_HEIGHT-themeConfig:get_data().positions.mainMenuHeight,
	itemHeight = itemH,
	borderWidth=themeConfig:get_data().positions.borderWidth,
	borderColor=getMainColor('border'),
	currentButtonColor=getMainColor('highlight'),
	bgColor=getMainColor('disabled'),
	fontScale = itemH/50,
	fontColor = color("#FFFFFF"),
	unclickableColor = getMainColor('negative'),
	buttonColor = getMainColor('frames'),
	items = {
		
	}
}
function SelectSideBarItem(params, i)
	currentSideBarItemTable[params.sidebarnum] = i
	MESSAGEMAN:Broadcast("UpdateSideBar")
end
local sidebarqty=1
currentSideBarItemTable= {}
function NewSideBar(params)
	-- fill empty optiins as default
	params.sidebarnum = sidebarqty
	currentSideBarItemTable[params.sidebarnum] = 1
	sidebarqty = sidebarqty+1
	fillNilTableFieldsFrom(params, default)
	local t = Def.ActorFrame{
		--pos
		moving = false,
		InitCommand=function(self)
			self.moving = false
			self:xy(params.x,params.y)
		end,
		EndTweenCommand=function(self)
			self.moving=false
		end,
		HideSideBarMessageCommand=function(self)
			if not self.moving then
				self.moving = true
				self:linear(0.2):x(params.x-params.width):queuecommand("EndTween")
			end
		end,
		ShowSideBarMessageCommand=function(self)
			if not self.moving then
				self.moving = true
				self:linear(0.2):x(params.x):queuecommand("EndTween")
			end
		end,
		--bg
		Def.Quad {
			InitCommand=function(self)
				self:xy(params.width/2,params.height/2):zoomto(params.width,params.height)
				self:diffuse(params.bgColor)
			end;
		},
		--4 border quads
		Def.Quad {
			InitCommand=function(self)
				self:xy(params.borderWidth/2,params.height/2):zoomto(params.borderWidth,params.height)
				self:diffuse(params.borderColor)
			end;
		},
		Def.Quad {
			InitCommand=function(self)
				self:xy(params.width/2,params.borderWidth/2):zoomto(params.width,params.borderWidth)
				self:diffuse(params.borderColor)
			end;
		},
		Def.Quad {
			InitCommand=function(self)
				self:xy(params.borderWidth/2+params.width,params.height/2):zoomto(params.borderWidth,params.height)
				self:diffuse(params.borderColor)
			end;
		},
		Def.Quad {
			InitCommand=function(self)
				self:xy(params.width/2,params.height+params.borderWidth/2):zoomto(params.width,params.borderWidth)
				self:diffuse(params.borderColor)
			end;
		},
	}
	for i=1,#params.items do
		t[#t+1] = Def.ActorFrame {
			--item position
			InitCommand=function(self)
				self:xy(0,params.itemHeight*(i-1))	
			end;
			-- Clickable item bg quad 
			Def.Quad {
				InitCommand=function(self)
					self:xy(params.itemWidth/2,params.itemHeight/2):zoomto(params.itemWidth,params.itemHeight)
					if currentSideBarItemTable[params.sidebarnum] == i then
						self:diffuse(params.currentButtonColor)
					elseif params.items[i].clickable==nil or params.items[i].clickable() then
						self:diffuse(params.buttonColor)
					else
						self:diffuse(params.unclickableColor)
					end
				end;
				OnCommand=function(self)
					if currentSideBarItemTable[params.sidebarnum] == i then
						self:diffuse(params.currentButtonColor)
					elseif params.items[i].clickable==nil or params.items[i].clickable() then
						self:diffuse(params.buttonColor)
					else
						self:diffuse(params.unclickableColor)
					end
				end;
				UpdateSideBarMessageCommand=function(self)
					self:queuecommand("On")
				end;
				LeftClickMessageCommand=function(self)
					if isOver(self) and (not params.items[i].clickable or params.items[i].clickable()) then
						if params.items[i].onClick then
							params.items[i].onClick(params, i)
							MESSAGEMAN:Broadcast("UpdateSideBar")
						end
					end
				end,
			},
			--item label
			LoadFont("Common Large")..{
				InitCommand=function(self)
					self:xy(params.itemWidth/2,params.itemHeight/2):zoom(params.fontScale):maxwidth(params.itemWidth*0.9):diffuse(params.fontColor):halign(0.5)
					self:settext(params.items[i].name)
				end,
			},
		}
	end
	--borders
	t[#t+1] = Def.ActorFrame{
		--4 border quads
		Def.Quad {--left
			InitCommand=function(self)
				self:xy(params.borderWidth/2,params.height/2):zoomto(params.borderWidth,params.height)
				self:diffuse(params.borderColor)
			end;
		},
		Def.Quad {--top
			InitCommand=function(self)
				self:xy(params.width/2,params.borderWidth/2):zoomto(params.width,params.borderWidth)
				self:diffuse(params.borderColor)
			end;
		},
		Def.Quad {--right
			InitCommand=function(self)
				self:xy(params.borderWidth/2+params.width,params.height/2):zoomto(params.borderWidth,params.height)
				self:diffuse(params.borderColor)
			end;
		},
		Def.Quad {--bottom
			InitCommand=function(self)
				self:xy(params.width/2,params.height+params.borderWidth/2):zoomto(params.width,params.borderWidth)
				self:diffuse(params.borderColor)
			end;
		},
	}
	for i=1,#params.items do
		t[#t+1] = Def.Quad {--top
			InitCommand=function(self)
				self:xy(params.width/2,params.itemHeight*(i)+params.borderWidth/2):zoomto(params.width,params.borderWidth)
				self:diffuse(params.borderColor)
			end;
		}
	end
	--retracting button
	t[#t+1] = Def.Quad {
		hidden = false,
		InitCommand=function(self)
			self:xy(params.width,params.height/2):zoomto(25,25):diffusealpha(0)
			self.hidden = false
		end;
		LeftClickMessageCommand=function(self)
			if isOver(self) then
				if self.hidden then
					MESSAGEMAN:Broadcast("HideSideBar")
				else
					MESSAGEMAN:Broadcast("ShowSideBar")
				end
				self.hidden = not self.hidden
			end
		end,
	}
	leftArrow = arrow_actor(params.width, params.height/2, -90,25,params.borderColor, params.buttonColor)
	rightArrow = arrow_actor(params.width, params.height/2, 90,25, params.borderColor, params.buttonColor)
	leftArrow.HideSideBarMessageCommand = function(self)
		self:visible(false)
	end
	rightArrow.HideSideBarMessageCommand = function(self)
		self:visible(true)
	end
	rightArrow.OnCommand = function(self)
		self:visible(false)
	end
	leftArrow.ShowSideBarMessageCommand = function(self)
		self:visible(true)
	end
	rightArrow.ShowSideBarMessageCommand = function(self)
		self:visible(false)
	end
	t[#t+1] = rightArrow
	t[#t+1] = leftArrow
	return t
end
