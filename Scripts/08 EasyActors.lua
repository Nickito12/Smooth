
function fillNilTableFieldsFrom(table1, defaultTable)
	 for key,value in pairs(defaultTable) do
		if table1[key] == nil then
			table1[key] = defaultTable[key]
		end
	end
end

local defaultLabel = {
	x=0,
	y=0,
	scale=1.0,
	text="",
	width=nil,
	color=color("#FFFFFF"),
	init=nil
}
Def.Label = function(params)
	fillNilTableFieldsFrom(params, defaultLabel)
	return LoadFont("Common Normal") .. {
		InitCommand=function(self)
			self:xy(params.x, params.y):zoom(params.scale)
			if width then
				self:maxwidth(params.width)
			end
			if params.init then params.init(self) end
		end,
		BeginCommand=function(self)
			self:settext(params.text):diffuse(params.color)
		end
	}
end

local defaultRectangle = {
	x=0,
	y=0,
	width=100,
	height=100,
	color=color("#FFFFFF"),
	onClick=nil,
	init=nil
}
Def.Rectangle = function(params)
	fillNilTableFieldsFrom(params, defaultRectangle)
	return Def.Quad {
			InitCommand=function(self)
				self:xy(params.x + params.width/2,params.y + params.height/2):zoomto(params.width,params.height)
				if params.init then params.init(self) end
			end;
			OnCommand=function(self)
				self:diffuse(params.color)
			end;
			LeftClickMessageCommand=function(self)
				if params.onClick and isOver(self) then
					params.onClick()
				end
			end,
		}
end


local defaultBorders = {
	x=0,
	y=0,
	color=color("#FFFFFF"),
	width=100,
	height=100,
	borderWidth=10,
	init=nil,
}
Def.Borders = function(params)
	fillNilTableFieldsFrom(params, defaultBorders)
	return Def.ActorFrame {
		InitCommand=function(self)
			self:xy(params.x,params.y)
			if params.init then params.init(self) end
		end,
		--4 border quads
		Def.Rectangle({width=params.borderWidth, height=params.height, color=params.color}), --left
		Def.Rectangle({width=params.width, height=params.borderWidth, color=params.color}), --top
		Def.Rectangle({x=params.width-params.borderWidth, width=params.borderWidth, height=params.height, color=params.color}), --right
		Def.Rectangle({y=params.height-params.borderWidth, width=params.width, height=params.borderWidth, color=params.color}), --bottom
	}
end

local defaultButton = {
	x=0,
	y=0,
	width=100,
	height=100,
	bgColor=color("#FFFFFF"),
	fontScale=0.5,
	fontColor=color("#000000"),
	borderWidth=nil,
	borderColor=color("#888888"),
	text="",
	onClick=nil,
	init=nil
}
Def.Button = function(params)
	fillNilTableFieldsFrom(params, defaultButton)
	return Def.ActorFrame {
		InitCommand=function(self)
			self:xy(params.x,params.y)
			if params.init then params.init(self) end
		end,
		Def.Rectangle({width=params.width, height=params.height, color=params.bgColor, onClick=params.OnClick}),
		Def.Label(params.width/2,params.height/2, params.fontScale, params.text, params.fontColor, params.width*0.9, function(s) s:halign(0.5) end),
		(params.borderWidth and params.borderWidth > 0 and Def.Borders({borderWidth=borderWidth, color=borderColor, width=width, height=height}) or nil),
	}
end


function calc_circle_verts(radius, chords, start_angle, end_angle, color)
	if start_angle == end_angle then
		end_angle= start_angle + (math.pi*2)
	end
	local chord_angle= (end_angle - start_angle) / chords
	local verts= {}
	for c= 0, chords do
		local angle= start_angle + (chord_angle * c)
		verts[c+1]= {{radius * math.cos(angle), radius * math.sin(angle), 0}, color}
	end
	return verts
end
function circle(x, y, r, color, out_color, chords)
	x= x or 0
	y= y or 0
	r= r or 4
	chords= chords or r
	out_color= out_color or color
	return Def.ActorMultiVertex{
		InitCommand= function(self)
			local verts= calc_circle_verts(r, chords, 0, 0, out_color)
			table.insert(verts, 1, {{0, 0, 0}, color})
			for i, v in ipairs(verts) do
				v[2]= out_color
			end
			verts[1][2]= color
			self:xy(x, y):SetDrawState{Mode="DrawMode_Fan"}:SetVertices(verts)
	end}
end

local function gen_arrow_verts(size, point_vert, leg_width, leg_len, stem_width)
	return {
		point_vert,
		{point_vert[1]-leg_len, point_vert[2]+leg_len, 0},
		{point_vert[1]+leg_width, point_vert[2]+leg_width, 0},

		{point_vert[1]-leg_len, point_vert[2]+leg_len, 0},
		{point_vert[1]-leg_len+leg_width, point_vert[2]+leg_len+leg_width, 0},
		{point_vert[1]+leg_width, point_vert[2]+leg_width, 0},

		{point_vert[1]-leg_len, point_vert[2]+leg_len, 0},
		{point_vert[1]-leg_len, point_vert[2]+leg_len+leg_width, 0},
		{point_vert[1]-leg_len+leg_width, point_vert[2]+leg_len+leg_width, 0},

		point_vert,
		{point_vert[1]+leg_len, point_vert[2]+leg_len, 0},
		{point_vert[1]-leg_width, point_vert[2]+leg_width, 0},

		{point_vert[1]+leg_len, point_vert[2]+leg_len, 0},
		{point_vert[1]+leg_len-leg_width, point_vert[2]+leg_len+leg_width, 0},
		{point_vert[1]-leg_width, point_vert[2]+leg_width, 0},

		{point_vert[1]+leg_len, point_vert[2]+leg_len, 0},
		{point_vert[1]+leg_len, point_vert[2]+leg_len+leg_width, 0},
		{point_vert[1]+leg_len-leg_width, point_vert[2]+leg_len+leg_width, 0},

	}
end

function arrow_actor(x, y, r, size, out_color, in_color)
	x= x or 0
	y= y or 0
	r= r or 0
	size= size or 8
	local point_vert= {0, -size/2, 0}
	local leg_width= 8
	local leg_len= size/2 - leg_width^.5
	local stem_width= 4 * 2^.5
	local insize= size-8
	local in_point_vert= {0, -insize/2, 0}
	local inlw= leg_width-4
	local inll= leg_len-2
	local insw= stem_width-2
	return Def.ActorMultiVertex{
		InitCommand= function(self)
			local out_verts= gen_arrow_verts(size, point_vert, leg_width, leg_len, stem_width)
			local in_verts= gen_arrow_verts(insize, in_point_vert, inlw, inll, insw)
			local verts= {}
			for i, v in ipairs(out_verts) do
				verts[#verts+1]= {v, out_color}
			end
			for i, v in ipairs(in_verts) do
				verts[#verts+1]= {v, in_color}
			end
			self:xy(x, y):rotationz(r):SetDrawState{Mode="DrawMode_Triangles"}
				:SetVertices(verts)
		end
	}
end
