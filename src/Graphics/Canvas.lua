JL.Graphics.Canvas = {}
JL.Graphics.Canvas.__index = function(t, k)
	if (JL.Graphics.Canvas[k]) then 	return JL.Graphics.Canvas[k]; end
	if (JL.Graphics[k]) then 			return JL.Graphics[k]; end
end

function JL.Graphics.Canvas.new(X, Y, Width, Height)
	local X = X or 0;
	local Y = Y or 0;
	local Width = Width or -1
	local Height = Height or -1
	if Width == -1 then
		Width = X;
		Height = Y;
		X = 0;
		Y = 0;
	end
	local t = setmetatable(JL.Graphics.new(X, Y), JL.Graphics.Canvas);
	t.canvas = love.graphics.newCanvas(Width, Height);
	t.canvas:setFilter("linear", "nearest")
	t.height = Height;
	t.x = X;
	t.y = Y;
	return t;
end

function JL.Graphics.Canvas:bind()
	love.graphics.setCanvas(self.canvas)
end

function JL.Graphics.Canvas:unbind()
	love.graphics.setCanvas()
end

function JL.Graphics.Canvas:render(X, Y, parent)
	local X = X or 0;
	local Y = Y or 0;
	--if (type(parent) == "number") then y = x; x = parent; parent = nil; end
	if parent ~= nil then
		X = X + parent.x
		Y = Y + parent.y
	end
	love.graphics.draw(self.canvas,
	self.x + X, self.y + Y, math.rad(self.angle),
	self.scale.x*-self:getFlipX(), self.scale.y*-self:getFlipY(),
	self.origin.x, self.origin.y,
	self.shear.x, self.shear.y);

end

function JL.Graphics.Canvas:clear()
	self.canvas:clear();
end
