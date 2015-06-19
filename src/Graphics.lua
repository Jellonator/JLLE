JL.Graphics.__index = JL.Graphics;

do--virtual functions
	function JL.Graphics:update(dt)end;
end

do--Set properties, all have X and Y arguments.
	--[[Sets the shearing property]]
	function JL.Graphics:setShear(X, Y)
		self.shear.x = X;
		self.shear.y = Y;
	end;
	--[[Sets the scale of the graphic, Y not required]]
	function JL.Graphics:setScale(X, Y)
		local Y = Y or X;
		self.scale.x = X;
		self.scale.y = Y;
	end;
	--[[Sets the origin of the graphic]]
	function JL.Graphics:setOrigin(X, Y)
		self.origin.x = X;
		self.origin.y = Y;
	end
	--[[Flips of the graphic]]
	function JL.Graphics:setFlip(X, Y)
		local x = false;
		local y = false;
		if X == nil then x = self.flip.x else x = X end
		if Y == nil then y = self.flip.y else y = Y end
		self.flip.x = X;
		self.flip.y = Y;
	end;
	function JL.Graphics:setAngle(A)
		self.angle = A;
	end
end

do--Get variables
	function JL.Graphics:getFlipX() return JL.Math.boolToNumber(self.flip.x) end;
	function JL.Graphics:getFlipY() return JL.Math.boolToNumber(self.flip.y) end;
end

function JL.Graphics:type()
	return "Graphic";
end

do--Render functions
	function JL.Graphics:render(parent)
		local hasParent = true;
		if (parent == nil) then hasParent = false end;
		if (self.relative and hasParent) then
			love.graphics.point(self.x + parent.x, self.y + parent.y);
		else
			love.graphics.point(self.x, self.y);
		end;
	end;
end

do--Constructor
	function JL.Graphics.new(X, Y, A)
		local A = A or 0;
		local X = X or 0;
		local Y = Y or 0;
		local g = setmetatable({
			x = X,
			y = Y,
			angle = A,
			scale = {x = 1, y = 1},
			origin = {x = 0, y = 0},
			shear = {x = 0, y = 0},
			flip = {x = false, y = false},
			relative = true,
		}, JL.Graphics);
		return g;
	end
end
