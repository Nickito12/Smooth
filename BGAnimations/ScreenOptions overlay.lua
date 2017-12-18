t = Def.ActorFrame{}

t[#t+1] = LoadActor("_mainmenu")
local itemH = 25

local sideBarOpts = {
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
		{
			name = "option1",
			clickable = function()
				return true
			end,
			onClick = function(params, i)
				SelectSideBarItem(params, i)
			end,
		},
		{
			name = "option1",
			clickable = function()
				return true
			end,
			onClick = function(params, i)
				SelectSideBarItem(params, i)
			end,
		},
	}
}
t[#t+1] = NewSideBar(sideBarOpts)

return t