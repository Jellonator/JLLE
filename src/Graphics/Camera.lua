JL.Graphics.Camera = {}
JL.Graphics.Camera.__index = JL.Graphics.Camera;
function JL.Graphics.Camera.new()
	local w = setmetatable({
		angle = 0,
		view = {
			x = 0,
			y = 0,
			width = love.graphics.getWidth(),
			height = love.graphics.getHeight(),
		},
		enabled = false,
		shader = nil,
		scale = {x = 1, y = 1},
		offset = {x = 0, y = 0},
		color = nil,
		crop = nil,
	},JL.Graphics.Camera);
	return w;
end

do --special functions
	function JL.Graphics.Camera:target(w, h)
		if (h == nil) then h = w/self:getRatio() end
		if (w == nil) then w = h*self:getRatio() end
		self:setScale(self.view.width/w, self.view.height/h);
	end
	function JL.Graphics.Camera:border(w)
		local width, height = love.graphics.getWidth(), love.graphics.getHeight();
		if (self.target) then width, height = self.target.x, self.target.y end
		self:setView(w,w,width-w*2,height-w*2);
	end
	function JL.Graphics.Camera:letterbox(width, height, zoom, x, y, NoCrop)--Note for X and Y: 0 means left/top, 1 means right/bottom.
		if not(width and height) then return end
		local zoom = zoom or 0;
		local xx = width;
		local yy = height;
		local r = 0;
		local x = x or 0.5;
		local y = y or 0.5;
		local NoCrop = (NoCrop ~= nil) and NoCrop or false;
		local window_width = love.graphics.getWidth();
		local window_height = love.graphics.getHeight();
		local width_ratio = window_width/width;
		local height_ratio = window_height/height;
		local window_ratio = window_width/window_height;
		local ratio = width/height;
		local scale_to = 0;

		if (window_ratio > ratio) then
			width = zoom*(width * width_ratio) + (1-zoom)*(width * height_ratio);
			height = zoom*(height * width_ratio) + (1-zoom)*(height * height_ratio);
			scale_to = zoom*(width_ratio) + (1-zoom)*(height_ratio);
		else
			width = (1-zoom)*(width * width_ratio) + zoom*(width * height_ratio);
			height = (1-zoom)*(height * width_ratio) + zoom*(height * height_ratio);
			scale_to = (1-zoom)*(width_ratio) + zoom*(height_ratio);
		end
		
		x = (window_width - width)*x/scale_to;
		y = (window_height - height)*y/scale_to;
		if not NoCrop then
			self:setCrop(math.max(0, x*scale_to), math.max(0, y*scale_to), math.min(width, window_width), math.min(window_height, height));
		end
		self:offSet(x, y);
		self:setScale(scale_to);
	end
	function JL.Graphics.Camera:disableCrop()
		self.crop = nil;
	end
	function JL.Graphics.Camera:setCrop(X, Y, Width, Height)
		self.crop = {x=X, y=Y, w=Width, h=Height};
	end
end
do --set properties
	function JL.Graphics.Camera:setView(x, y, width, height)
		self.view.x = x or self.view.x;
		self.view.y = y or self.view.y;
		self.view.width = width or self.view.width;
		self.view.height = height or self.view.height;
	end
	function JL.Graphics.Camera:setScale(x, y)
		local x = x or 1;
		local y = y or x;
		self.scale.x = x;
		self.scale.y = y;
	end
	function JL.Graphics.Camera:offSet(x, y)
		local x = x or 0;
		local y = y or 0;
		self.offset.x = x;
		self.offset.y = y;
	end
	JL.Graphics.Camera.setOffset = JL.Graphics.Camera.offSet;
	function JL.Graphics.Camera:setColor(R, G, B, A)
		A = A or 255;
		self.color.r = R;
		self.color.g = G;
		self.color.b = B;
		self.color.a = A;
	end
end
do --get properties

	function JL.Graphics.Camera:getRatio()
		return self.view.width/self.view.height;
	end

	--[[function JL.Graphics.Camera:getViewScale()
		return self.view.width, self.view.height;
	end]]

	function JL.Graphics.Camera:getOffset()
		return math.floor(self.offset.x*self.scale.x), math.floor(self.offset.y*self.scale.y);
	end

	function JL.Graphics.Camera:getAngle()
		return self.angle;
	end

	function JL.Graphics.Camera:getScale()
		return self.scale.x, self.scale.y;
	end

	function JL.Graphics.Camera:getView()
		return self.view.x,self.view.y,self.view.width,self.view.height;
	end

	function JL.Graphics.Camera:getColor()
		return self.color.r, self.color.g, self.color.b, self.color.a;
	end
	
	function JL.Graphics.Camera:getLogicalSize()
		local window_width = love.window.getWidth()
		local window_height = love.window.getHeight()
		if self.crop ~= nil then
			window_width = self.crop.w
			window_height = self.crop.h
		end
		local width, height = window_width / self.scale.x, window_height / self.scale.y
		return width, height;
	end	
	
	function JL.Graphics.Camera:getLogicalBounds()
		local window_x = 0;
		local window_y = 0;
		local window_width = love.window.getWidth()
		local window_height = love.window.getHeight()
		if self.crop ~= nil then
			window_x = self.crop.x;
			window_y = self.crop.y;
			window_width = self.crop.w
			window_height = self.crop.h
		end
		local x, y, width, height = window_x / self.scale.x, window_y / self.scale.y, window_width / self.scale.x, window_height / self.scale.y
		return x, y, width, height;
	end
	
	function JL.Graphics.Camera:limit(X, Y, Width, Height)
		local c_x, c_y, c_width, c_height = self:getLogicalBounds()
		if self.offset.x > -X + c_x then self.offset.x = math.floor(-X + c_x) end
		if self.offset.y > -Y + c_y then self.offset.y = math.floor(-Y + c_y) end
		if self.offset.x < -Width + c_width + c_x then self.offset.x = math.ceil(-Width + c_width + c_x) end
		if self.offset.y < -Height + c_height + c_y then self.offset.y = math.ceil(-Height + c_height + c_y) end
	end
	
	function JL.Graphics.Camera:getPoint(X, Y)
		local ox, oy = self:getOffset();
		return (X - ox)/self.scale.x, (Y - oy)/self.scale.y;
	end
	
	function JL.Graphics.Camera:getLeft(offset)
		local offset = offset or 0;
		local x, y = self:getPoint(0, 0);
		return x + offset;
	end
	
	function JL.Graphics.Camera:getRight(offset)
		local offset = offset or 0;
		local ignore_x, ignore_y, width, height = self:getLogicalBounds();
		local x, y = self:getPoint(width * self.scale.x, 0);
		return x - offset;
	end	
	
	function JL.Graphics.Camera:getTop(offset)
		local offset = offset or 0;
		local x, y = self:getPoint(0, 0);
		return y + offset;
	end
	
	function JL.Graphics.Camera:getBottom(offset)
		local offset = offset or 0;
		local ignore_x, ignore_y, width, height = self:getLogicalBounds();
		local x, y = self:getPoint(0, height*self.scale.y);
		return y - offset;
	end
	
	function JL.Graphics.Camera:getCenter(posx, posy)
		local posx = posx or 0.5;
		local posy = posy or 0.5;
		
		return (1-posx) * self:getLeft() + posx * self:getRight(), (1-posy) * self:getTop() + posy * self:getBottom();
	end
	
end

function JL.Graphics.Camera:setShader(Shader)
	self.shader = Shader;
end

function JL.Graphics.Camera:enable()
	if (self.enabled) then self:disable(); end
	self.enabled = true;
	love.graphics.push();
	love.graphics.translate(self:getOffset());
	love.graphics.scale(self:getScale());
	love.graphics.rotate(self:getAngle());
	if (self.shader) then
		love.graphics.setShader(self.shader);
	end
	if (self.crop) then 
		love.graphics.setScissor(self.crop.x, self.crop.y, self.crop.w, self.crop.h);
	end
	if(self.color)then love.graphics.setColor(self:getColor()); end
end
--
function JL.Graphics.Camera:disable()
	self.enabled = false;
	love.graphics.setScissor()
	love.graphics.pop();
	love.graphics.setShader();
end
function JL.Graphics.Camera:render(drawable, X, Y, entity)
	local X = X or 0;
	local Y = Y or 0;
	if entity ~= nil then
		X = X + entity.x
		Y = Y + entity.y
	end
	--local x, y  = self:getViewScale();
	--X = X * x * self.scale.x;
	--Y = Y * y * self.scale.y;
	--print(self:getView());
	love.graphics.push();
	love.graphics.translate(self:getOffset());
	love.graphics.scale(self:getScale());
	love.graphics.rotate(self:getAngle());
	if (self.crop) then 
		love.graphics.setScissor(self.crop.x, self.crop.y, self.crop.w, self.crop.h);
	end
	if (self.color)then love.graphics.setColor(self:getColor()); end
	--if (self.shader) then love.graphics.setPixelEffect(self.shader) end
		local t = "";
		if (drawable.type) then t = drawable:type(); end
		local to = false;
		if (drawable.typeOf) then to = drawable:typeOf("Drawable") end
		
		if (t == "Entity" and drawable.graphic ~= nil) then drawable.graphic:render(drawable)
		elseif (t == "World") then drawable.OnRender()
		elseif (to == true) then love.graphics.draw(drawable, X, Y)
		elseif (t == "Graphic") then drawable:render(X, Y)
		elseif (drawable.draw) then drawable:draw(X, Y)
		elseif (drawable.render) then drawable:render(X, Y)
		end
	--if (self.shader) then love.graphics.setPixelEffect() end
	love.graphics.setScissor()
	love.graphics.pop();
end
do--movement
	function JL.Graphics.Camera:moveTo(X, Y, Speed, DT)
		local xd = X-self.offset.x;
		local yd = Y-self.offset.y;
		local DT = DT or JL.dt;
		local Speed = Speed or 20;
		--if (math.abs(xd) < 1 and math.abs(yd) < 1) then self.offset.x = X; self.offset.y = Y;
		--else
			local dis = math.sqrt(math.pow(xd,2) + math.pow(yd,2));
			local angle = math.atan2(Y - self.offset.y, X - self.offset.x);
			local s = dis*DT*Speed;
			local sx = math.cos(angle)*s;
			local sy = math.sin(angle)*s;
			self.offset.x = self.offset.x + sx;
			self.offset.y = self.offset.y + sy;
			if (sx < 0) and (self.offset.x < X) or (sx > 0) and (self.offset.x > X) then self.offset.x = X end
			if (sy < 0) and (self.offset.y < Y) or (sy > 0) and (self.offset.y > Y) then self.offset.y = Y end
		--end
	end
	
	function JL.Graphics.Camera:setPos(X, Y)
		local X = X or 0;
		local Y = Y or 0;
		self.offset.x = X;
		self.offset.y = Y;
	end
end

function JL.Graphics.Camera:center(X, Y, Smooth, Speed, DT)
	local DT = DT or JL.dt;
	local Speed = Speed or 20;
	local view_x, view_y, view_w, view_h = self:getLogicalBounds()
	local to_x, to_y = view_x + view_w / 2 - X, view_y + view_h / 2 - Y;
	if (Smooth == true) then
		self:moveTo(to_x, to_y, Speed, DT);
	else
		self:setPos(to_x, to_y);
	end
end

function JL.Graphics.Camera:isOnScreen(x, y, w, h, range)
	local range = range or 0;
	local x2, y2 = x + w, y + h;
	local cx, cy = self:getCenter();
	return JL.Mask.Box.collideAABB(x, y, x2, y2, self:getLeft(range), self:getTop(range), self:getRight(range), self:getBottom(range));
end

JL.Graphics.Camera.meta = {}
function JL.Graphics.Camera.meta.__call(t, ...)
	return t.new(...);
end
setmetatable(JL.Graphics.Camera, JL.Graphics.Camera.meta);