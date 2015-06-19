JL.Arm = {};
JL.Arm.__index = JL.Arm;

function JL.Arm:update(dt)
	if self.anim then
		self.anim:update(dt);
		self.angle = self.anim.angle + self.angle_;
		self.length = self.anim.length + self.length_;
	end
	for i in ipairs(self.arms) do if(self.updates[i]) then self.arms[i]:update(dt);end end
end;

function JL.Arm:attach(A, U)
	if U == nil then U = true end
	table.insert(self.arms, A);
	table.insert(self.updates, U);
end

function JL.Arm:render(parent)
	local X, Y = self.x,self.y;
	if parent then self.x = self.x + parent.x; self.y = self.y + parent.y; end;
	if self.graphic.inner then self.graphic.inner:render(self) end;
	self.x = self.x+math.cos(math.rad(self.angle))*self.length;
	self.y = self.y+math.sin(math.rad(self.angle))*self.length;
	if self.graphic.outer then
		if self.stretch then local SX, SY = self.graphic.outer.scale.x, self.graphic.outer.scale.y;
			self.graphic.outer:setScale((self.length/(self.graphic.outer.image:getWidth() - (self.graphic.outer.image:getWidth()-self.graphic.outer.origin.x))), 1);
			self.graphic.outer:render(self);
			self.graphic.outer:setScale(SX,SY);
		else self.graphic.outer:render(self) end
	end;
	for i in ipairs(self.arms) do self.arms[i]:render(self) end
	self.x, self.y = X, Y;
end

function JL.Arm:setInnerGraphic(G) self.graphic.inner = G; end
function JL.Arm:setOuterGraphic(G) self.graphic.outer = G; end
function JL.Arm:setAnim(A) self.anim = A; end;
function JL.Arm:setGraphic(Inner, Outer)
	self:setInnerGraphic(Inner);
	self:setOuterGraphic(Outer);
end

function JL.Arm.new(X, Y, Angle, Length, Anim, Graphic, Stretch)
	local a = {
		x = X,
		y = Y,
		angle_ = Angle,
		length_ = Length,
		angle = 0,
		length = 0,
		anim = Anim,
		arms = {},
		graphic = {},
		updates = {},
		stretch = Stretch or false,
	}
	if type(Graphic) == "table" then
		a.graphic.inner = Graphic[1] or Graphic.inner or nil;
		a.graphic.outer = Graphic[2] or Graphic.outer or nil;
	else a.graphic.inner = Graphic end;
	setmetatable(a,JL.Arm);
	return a;
end

setmetatable(JL.Arm,{
__call = function(t,...)return JL.Arm.new(arg[1],arg[2],arg[3],arg[4],arg[5],arg[6],arg[7]);end
});
