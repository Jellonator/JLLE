--private variables
JL.Entity.__index = JL.Entity;

--custom shape definition
function love.physics.newDiamondShape(X, Y, Width, Height)
	if Width == nil or Height == nil then
		local X = X or 1;
		local Y = Y or 1;
		return love.physics.newDiamondShape(0,0,X,Y);
	else
		local X = X or 0;
		local Y = Y or 0;
		local x1, y1, x2, y2 = X-Width/2, Y-Height/2, X+Width/2, Y+Height/2;
		return love.physics.newPolygonShape(
			(x1+x2)/2,      y1, 
			x2,             (y1+y2)/2, 
			(x1+x2/2),     y2, 
			x1,             (y1+y2)/2);
	end
end

do--Drawing functions
	--[[Called when the screen is updated, usually after update().]]
	function JL.Entity:OnRender()
		self:render();
	end;
	--[[Virtual function]]
	function JL.Entity.render()end;
end

do--Update functions
	--[[Called when the game is updated
	--dt:	Deltatime, time it took for the last frame to update.
	--]]
	function JL.Entity:OnUpdate(dt)
		--[[if (self.form) then
			self.x = self.form.b:getX();
			self.y = self.form.b:getY();
			self.angle = self.form.b:getAngle();
		end;
		self:update(dt);
		if (self.form) then
			self.form.b:setX(self.x);
			self.form.b:setY(self.y);
			self.form.b:setAngle(self.angle);
		end;]]
	end;
	function JL.Entity:update(dt)end;--Virtual function
end

do--Grouping functions
	--[[Adds the entity to a collision group
	--Group:	the group to add the entity to.
	--]]
	function JL.Entity:addToGroup(Group)
		if self._index == 0 or Group == nil then return false end;
		if type(Group) == "table" then
			for k,v in ipairs(Group) do
				self:addToGroup(v);
			end
		else
			if not JL.World.world.Groups[Group] then JL.World.world.Groups[Group] = {} end;
			table.insert(JL.World.world.Groups[Group], self._index);
			table.insert(self._groups, Group);
		end
		return true;
	end
end

function JL.Entity:type()
	return "Entity";
end

do--constructor functions
	--[[Creates a new entity
	--X: 		The x position
	--Y: 		The y position
	--Graphic: 	The Graphic
	--Mask:		The Mask.
	--]]
	function JL.Entity.new(X, Y, Graphic)
		local X = X or 0;
		local Y = Y or 0;
		local e = setmetatable({
			_groups = {},
			x = X,
			y = Y,
			angle = 0,
			graphic = Graphic,
			layer = 0;
		}, JL.Entity);
		--JL.World.add(e);  Was here, but was removed.
		return e;
	end;
	--[[creates a new physics-based entity
	--Shape:    The shape of the entity
	--X:        The x position
	--Y:        The y position
	--bodyType: The type of body
	--Density:  The density of the body
	--]]
	function JL.Entity.newPhysics(Shape, X, Y, Graphic, BodyType, Density, World)
		local X = X or 0;
		local Y = Y or 0;
		local Density = Density or 1;
		local BodyType = BodyType or 'dynamic';
		local World = World or JL.world;
		local e = JL.Entity.new(X, Y, Graphic);
		e.form = {
			b = love.physics.newBody(World.physics, X, Y, BodyType),
			s = Shape
		}
		--e.body = e.form.body;
		--e.body = e.form.body;
		e.form.f = love.physics.newFixture(e.form.b, e.form.s, Density);
		e.form.f:setUserData(e);
		return e;
	end;
	
	function JL.Entity:OnCollide(Other, Contact)
		
	end
	
	function JL.Entity:OnUnCollide(Other, Contact)
		
	end
	
	function JL.Entity:OnPreSolve(Other, Contact)
		
	end
	
	function JL.Entity:OnPostSolve(Other, Contact, normalimpulse1, tangentimpulse1, normalimpulse2, tangentimpulse2)
		
	end
	
	function JL.Entity:destroy()
		self:OnEnd();
		for i = 1, #self._groups do
			local group = self._groups[i];
			group:remove(self);
		end
		if self.form then
			self.form.b:destroy();
			--self.form.s:destroy();
			--self.form.f:destroy();
		end
	end
	
	function JL.Entity:setLayer(layer)
		self.layer = layer;
		for i = 1, #self._groups do
			local group = self._groups[i];
			group.need_relayer = true;
		end
	end
end

function JL.Entity:getCenter()
	local x, y = 0, 0;
	if self.mask then
		if self.mask.getCenter then
			x, y = self.mask:getCenter()
		end
	end
	return x + self.x, y + self.y;
end

function JL.Entity:getAABB()
	local x1, y1, x2, y2 = self.x, self.y, self.x, self.y;
	if self.mask then
		if self.mask.w and self.mask.h then
			x1 = x1 + self.mask.x;
			y1 = y1 + self.mask.y;
			x2 = x1 + self.mask.w;
			y2 = y1 + self.mask.h;
		end
	end
	return x1, y1, x2, y2;
end

function JL.Entity:OnEnd() end

--metatables
JL.Entity.meta = {}
function JL.Entity.meta.__call(t,...)
	return JL.Entity.new(...);
end
setmetatable(JL.Entity, JL.Entity.meta);
