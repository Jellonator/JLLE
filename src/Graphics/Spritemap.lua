JL.Graphics.Spritemap = {}
JL.Graphics.Spritemap.__index = function(t, k)
	if (JL.Graphics.Spritemap[k]) then 	return JL.Graphics.Spritemap[k]; end
	if (JL.Graphics[k]) then 		return JL.Graphics[k]; end
end

function JL.Graphics.Spritemap.new(F, X, Y)
	local g = setmetatable(JL.Graphics.new(X, Y),JL.Graphics.Spritemap);
	if type(F) == "string" then F = love.graphics.newImage(F) end
	g.image = F;
	g.image:setFilter("linear", "nearest")
	g.image:setWrap("clamp", "clamp");
	g.size = {x = g.image:getWidth(), y = g.image:getHeight()}
	g.quads = {};--GLORIOUS quads
	g.anims = {};
	g.current = "_nil_";
	g.frame = 1;
	g.time = 0;
	g.ctime = 0;
	g.auto = true;
	g.loop = true;
	g.playing = false;
	return g;
end;

function JL.Graphics.Spritemap:addFrame(X, Y, Width, Height, Num)
	local Num = Num or #self.quads + 1;
	self.quads[Num] = love.graphics.newQuad(X, Y, Width, Height, self.size.x, self.size.y);
end
function JL.Graphics.Spritemap:addAnimation(Name, Speed, Frames)
	self.anims[Name] = {f = Frames, s = Speed, };
end
function JL.Graphics.Spritemap:play(Name, Reset, Frame, Loop)
	local l = true;
	if (Loop ~= nil) then l = Loop end
	local Reset = Reset or false;
	local Frame = Frame or 1;
	if (Reset == false and Name == self.current) then return end;
	self.current = Name;
	self.frame = Frame;
	self.loop = l;
	self.ctime = 0;
	self.playing = true;
end
function JL.Graphics.Spritemap:update(dt)
	if (self.auto and self.playing) then
		if (self.current == "_nil_") then return end;
		self.time = self.time + 60*dt;
		self.ctime = self.ctime + 60*dt;
		while (self.time > 60/self.anims[self.current].s) do
			self.time = self.time - 60/self.anims[self.current].s;
			self:setFrame(self.frame + 1);
		end
	end
end
function JL.Graphics.Spritemap:getSeconds()
	return self.ctime/60;
end
function JL.Graphics.Spritemap:getMaxSeconds()
	return table.getn(self.anims[self.current].f)*(60/self.anims[self.current].s) / 60
end
function JL.Graphics.Spritemap:getPos()
	return self:getSeconds()/self:getMaxSeconds()
end
function JL.Graphics.Spritemap:render(Entity, X, Y)

	if self.current == "_nil_" then return end
	if self.anims[self.current] == nil then return end
	if self.anims[self.current].f[self.frame] == nil then return end
	if self.quads[self.anims[self.current].f[self.frame]] == nil then return end

	local x = X or 0;
	local y = Y or 0;
	local entity = Entity or 0;
	if type(Entity) == "table" then
		x = x + entity.x;
		y = y + entity.y;
	else
		x = Entity;
		y = X;
	end
	--[[if (hasParent) then
		love.graphics.draw(self.image,
		self.quads[self.anims[self.current].f[self.frame],
		self.x + parent.x + x + self.origin.x, self.y + parent.y + y + self.origin.y, math.rad(self.angle + parent.angle),
		self.scale.x*-self:getFlipX(), self.scale.y*-self:getFlipY(),
		self.origin.x, self.origin.y,
		self.shear.x, self.shear.y);
	else]]
		love.graphics.draw(self.image,
		self.quads[self.anims[self.current].f[self.frame]],
		self.x + x + self.origin.x, self.y + y + self.origin.y, math.rad(self.angle),
		self.scale.x*-self:getFlipX(), self.scale.y*-self:getFlipY(),
		self.origin.x, self.origin.y,
		self.shear.x, self.shear.y);
	--end
end
function JL.Graphics.Spritemap:renderFrame(parent, x, y, Frame)
	local x = x or 0;
	local y = y or 0;
	if (type(parent) == "number") then y = x; x = parent; parent = nil; end
	local hasParent = true;
	if (parent == nil) then hasParent = false end;
	if (hasParent) then
		love.graphics.draw(self.image,
		self.quads[Frame],
		self.x + parent.x + x + self.origin.x, self.y + parent.y + y + self.origin.y, math.rad(self.angle + parent.angle),
		self.scale.x*-self:getFlipX(), self.scale.y*-self:getFlipY(),
		self.origin.x, self.origin.y,
		self.shear.x, self.shear.y);
	else
		love.graphics.draw(self.image,
		self.quads[Frame],
		self.x + x + self.origin.x, self.y + y + self.origin.y, math.rad(self.angle),
		self.scale.x*-self:getFlipX(), self.scale.y*-self:getFlipY(),
		self.origin.x, self.origin.y,
		self.shear.x, self.shear.y);
	end
end
function JL.Graphics.Spritemap:centerOrigin(Width, Height)
	self:setOrigin(Width/2, Height/2);
end
function JL.Graphics.Spritemap:getFrame()
	return self.anims[self.current].f[self.frame];
end
function JL.Graphics.Spritemap:setFrame(Frame)
	self.frame = Frame;
	if (self.frame > table.getn(self.anims[self.current].f)) then
		if (self.loop == true) then
			self.frame = 1; self.ctime = self.ctime - table.getn(self.anims[self.current].f)*(60/self.anims[self.current].s);
		else
			self.frame = self.anims[self.current].f[table.getn(self.anims[self.current].f)]; self.ctime = self:getMaxSeconds(); self.playing = false;
		end
	end;
end

JL.Graphics.Spritemap.meta = {}
function JL.Graphics.Spritemap.meta.__call(t, ...)
	return t.new(...);
end
setmetatable(JL.Graphics.Spritemap, JL.Graphics.Spritemap.meta);
