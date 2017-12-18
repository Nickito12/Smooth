
return Def.ActorFrame{ 
	Def.Quad{
		OnCommand=function(self)
			self:xy(0,0):halign(0):valign(0):zoomto(SCREEN_WIDTH,SCREEN_HEIGHT):diffuse(color("#FFFFFF")):diffusealpha(0.5) 
		end,
		InitCommand=function(self)
			self:xy(0,0):halign(0):valign(0):zoomto(SCREEN_WIDTH,SCREEN_HEIGHT):diffuse(color("#FFFFFF")):diffusealpha(0.5) 
		end
	}
}