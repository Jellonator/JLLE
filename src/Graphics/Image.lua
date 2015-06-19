JL.Graphics.Image = {};
JL.Graphics.Image.__index = function(t, k)
	if (JL.Graphics.Image[k]) then 	return JL.Graphics.Image[k]; end
	if (JL.Graphics[k]) then 		return JL.Graphics[k]; end
end

function JL.Graphics.Image.new(F, X, Y, Rect)
	local X = X or 0;
	local Y = Y or 0;
	local g = setmetatable(JL.Graphics.new(X, Y), JL.Graphics.Image);
	if type(F) == "string" then F = love.graphics.newImage(F);end
	g.image = F;
	g.image:setFilter("linear", "nearest")
	g.image:setWrap("clamp", "clamp");
	g.quad = love.graphics.newQuad(0, 0, g.image:getWidth(), g.image:getHeight(), g.image:getWidth(), g.image:getHeight());
	return g;
end;

function JL.Graphics.Image:setWrap(X, Y)
	self.image:setWrap(X, Y);
end

function JL.Graphics.Image:render(parent, x, y)
	local x = x or 0;
	local y = y or 0;
	if (type(parent) == "number") then y = x; x = parent; parent = nil; end
	local parent_x = 0;
	local parent_y = 0;
	local parent_angle = 0;
	if parent then parent_x = parent.x; parent_y = parent.y; parent_angle = parent.angle or 0 end
	love.graphics.draw(self.image, self.quad,
	self.x + parent_x + x, self.y + parent_y + y, math.rad(self.angle + parent_angle),
	self.scale.x*-self:getFlipX(), self.scale.y*-self:getFlipY(),
	self.origin.x, self.origin.y,
	self.shear.x, self.shear.y);
end
function JL.Graphics.Image:setSize(width, height)
	local x,y,w,h = self.quad:getViewport();
	self:setScale(width/w,height/h);
end
function JL.Graphics.Image:centerOrigin()
	self:setOrigin(self.image:getWidth()/2, self.image:getHeight()/2);
end;
function JL.Graphics.Image:setRect(Rect)
	self.quad:setViewport(Rect[1], Rect[2], Rect[3], Rect[4]);
end;

function JL.Graphics.Image:getSize()
	return self.image:getWidth(), self.image:getHeight();
end

JL.Graphics.Image.meta = {}
function JL.Graphics.Image.meta.__call(t, ...)
	return t.new(...);
end
setmetatable(JL.Graphics.Image, JL.Graphics.Image.meta);
