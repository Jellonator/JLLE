--private variables
JL.World.__index = JL.World;

do--virtual functions
	function JL.World:OnInit() end;
	function JL.World:OnUpdate(dt) self:update(dt); end;
	function JL.World:OnRender() self:render() end;
	function JL.World:OnEnd() end;
end

do--physics callbacks
	function JL.World.beginContact(a, b, coll)
		local userData = a:getUserData();
		local otherData = b:getUserData();
		if type(userData) == "table" then
			if userData.OnPostSolve then userData:OnPostSolve(otherData, a, b, coll); end
		end
		if type(otherData) == "table" then
			if otherData.OnPostSolve then otherData:OnPostSolve(userData, b, a, coll); end
		end
		if type(userData) == "function" then 
			userData(a, b, true, coll);
		end
		if type(otherData) == "function" then 
			otherData(b, a, true, coll);
		end
	end

	function JL.World.endContact(a, b, coll)
		local userData = a:getUserData();
		local otherData = b:getUserData();
		if type(userData) == "table" then
			if userData.OnPostSolve then userData:OnPostSolve(otherData, a, b, coll); end
		end
		if type(otherData) == "table" then
			if otherData.OnPostSolve then otherData:OnPostSolve(userData, b, a, coll); end
		end
		if type(userData) == "function" then 
			userData(a, b, false, coll);
		end
		if type(otherData) == "function" then 
			otherData(b, a, false, coll);
		end
	end

	function JL.World.preSolve(a, b, coll)
		local userData = a:getUserData();
		local otherData = b:getUserData();
		if type(userData) == "table" then
			if userData.OnPostSolve then userData:OnPostSolve(otherData, a, b, coll); end
		end
		if type(otherData) == "table" then
			if otherData.OnPostSolve then otherData:OnPostSolve(userData, b, a, coll); end
		end
	end

	function JL.World.postSolve(a, b, coll, normalimpulse1, tangentimpulse1, normalimpulse2, tangentimpulse2)
		local userData = a:getUserData();
		local otherData = b:getUserData();
		if type(userData) == "table" then
			if userData.OnPostSolve then userData:OnPostSolve(otherData, a, b, coll, normalimpulse1, tangentimpulse1, normalimpulse2, tangentimpulse2); end
		end
		if type(otherData) == "table" then
			if otherData.OnPostSolve then otherData:OnPostSolve(userData, b, a, coll, normalimpulse1, tangentimpulse1, normalimpulse2, tangentimpulse2); end
		end
	end
end

do
	function JL.World._layer_compare(a, b)
		return a.layer < b.layer;
	end
	function JL.World:update(dt)
		if self.need_relayer then
			--JL.timeReset();
			table.sort(self.Entities, JL.World._layer_compare)
			self.need_relayer = false;
			--JL.timedPrint("SORTED ENTITIES");
		end
		for i,v in ipairs(JL.World.world.Entities) do
			if v.graphic ~= nil then v.graphic:update(dt) end;
			if v.OnUpdate ~= nil then v:OnUpdate(dt); end
		end;
		self.physics:update(dt);
		--self:OnUpdate(dt);
	end
	function JL.World:render()
	    for i,v in ipairs(JL.World.world.Entities) do
			love.graphics.setColor(255, 255, 255);
			if v.graphic ~= nil then v.graphic:render(v) end;
			if v.OnRender ~= nil then v:OnRender(); end
		end
		--self:OnRender();
	end
end

do--Management functions
	--[[Sets the world to a new World
	--w:World to change to
	--]]
	function JL.World.set(world)
		if JL.world then
			JL.world:OnEnd()
		end
		JL.World.world = world;
		JL.world = world;
		--world:init();
		world:OnInit();
		collectgarbage();--Best time to do it anyways.
	end;
	JL.World.setWorld = JL.World.set;
	--[[Resets the world, removing all entities and calling init()]]
	function JL.World:reset()
		--[[local t = {}
		for i = 1, #self.Entities do
			table.insert(t, self.Entities[i]);
		end
		for i = 1, #t do
			local entity = t[i];
			JL.Entity.destroy(entity);
		end
		for i = 1, #self.Groups do
			local group = self.Groups[i];
			group:reset();
		end]]
		self.Entities = {}
		self.Groups = {}
		--self.physics = love.physics.newWorld()
		--self.physics:setCallbacks(JL.World.beginContact, JL.World.endContact, JL.World.preSolve, JL.World.postSolve)
		self:OnInit();
		--collectgarbage();
	end
end

do--Misc. functions
	--[[returns the name of the world]]
	function JL.World:getName()
		return self.name;
	end
end

do--Constructor
	--[[Creates a new world
	--name:	The name of the world
	--]]
	function JL.World.new(name)
		local w = setmetatable({
			name = name,
			physics = love.physics.newWorld(),
			Entities = {},
			Groups = {},
			need_relayer = false,
		},JL.World);
		--w.physics:setCallbacks(JL.World.beginContact, JL.World.endContact, JL.World.preSolve, JL.World.postSolve)
		return w;
	end;
end

do--Entity management
	--[[Adds a new entity to the world
	--e:	The entity to add
	--]]
	function JL.World:add(e)
		table.insert(self.Entities, e);
		table.insert(e._groups, self);
		self.need_relayer = true;
	end;
	--[[Removes an entity
	--e:	The entity to remove
	--]]
	function JL.World:remove(e)
		for i = 1, #self.Entities do
			if e == self.Entities[i] then 
				table.remove(self.Entities,i); 
			end
		end
		--[[for j = 1, #e._groups do
			local group = e._groups[i];
			
		end]]
	end
	function JL.World:destroy()
			local i = 1;
			while i <= #self.Entities do
				self.Entities[i]:destroy();
			end
		end
	--[[Returns an array of all Entity indexes in the specified group
	--Group: The group
	--]]
	function JL.World:getByGroup(Group)
		if not self.Groups[Group] then return nil,false end;
		return self.Groups[Group].Entities, true;
	end
	
	function JL.World:addToGroup(Entity, Group)
		if not self.Groups[Group] then 
			self.Groups[Group] = JL.World.new(Group)
		end
		self.Groups[Group]:add(Entity);
	end
	
	function JL.World:removeFromGroup(Entity, Group)
		if not self.Groups[Group] then return end
		self.Groups[Group]:remove(Entity);
	end
	
	function JL.World:collide(Entity, Group, MoveX, MoveY, Sweep)
		local MoveX = MoveX or 0;
		local MoveY = MoveY or 0;
		local Sweep = Sweep or false;
		local X = Entity.x + MoveX;
		local Y = Entity.y + MoveY;
		local C = false;
		--print(type(Group))
		if type(Group) == "table" then
			if Sweep then
				for i = 1, #Group do
					local group = Group[i]
					local c, x, y = self:collide(Entity, group, MoveX, 0, true);
					if c then
						if MoveX > 0 then
							X = math.min(X, x);
						else
							X = math.max(X, x);
						end
						C = c;
					end
				end
				local previous_x = Entity.x;
				Entity.x = X;
				for i = 1, #Group do
					local group = Group[i]
					local c, x, y = self:collide(Entity, group, 0, MoveY, true);
					if c then
						if MoveY > 0 then
							Y = math.min(Y, y);
						else
							Y = math.max(Y, y);
						end
						C = c;
					end
				end
				Entity.x = previous_x;
				return C, X, Y
			else
				for i = 1, #Group do
					local group = Group[i]
					local c = self:collide(Entity, group, MoveX, MoveY, false);
					--print(x, y);
					if c then
						return true
					end
				end
				return false;
			end
			return false;
		end
		local group = self.Groups[Group];
		if group == nil then return false end
		if Sweep then
			for i = 1, #group.Entities do
				local other = group.Entities[i]
				if other ~= Entity then
					local c, x, y = JL.Mask.collide(Entity, other, MoveX, 0, true);
					if c then
						if MoveX > 0 then
							X = math.min(X, x);
						else
							X = math.max(X, x);
						end
						C = c;
					end
				end
			end
			local previous_x = Entity.x;
			Entity.x = X;
			for i = 1, #group.Entities do
				local other = group.Entities[i]
				local c, x, y = JL.Mask.collide(Entity, other, 0, MoveY, true);
				if other ~= Entity then
					if c then
						if MoveY > 0 then
							Y = math.min(Y, y);
						else
							Y = math.max(Y, y);
						end
						C = c;
					end
				end
			end
			Entity.x = previous_x;
			return C, X, Y
		else
			for i = 1, #group.Entities do
				local other = group.Entities[i]
				local c = JL.Mask.collide(Entity, other, MoveX, MoveY, false);
				--print(x, y);
				if c then
					return true
				end
			end
			return false;
		end
	end
end

do--Physics functions
	--[[Sets the physics options for the current world
	--GravityX:	 	The horizontal gravity
	--GravityY:		The vertical gravity
	--MeterLength:	The number of pixels that represent a meter.
	--]]
	function JL.World:setGravity(GravityX, GravityY)
		--local MeterLength = MeterLength or self.physics:getMeter();
		local p_gravX, p_gravY = self.physics:getGravity();
		local GravityX = GravityX or p_gravX;
		local GravityY = GravityY or p_gravY;
		--self.physics:setMeter(MeterLength);
		self.physics:setGravity(GravityX, GravityY);
	end;
end

function JL.World:type()
	return "World";
end

--metatables
JL.World.meta = {}
function JL.World.meta.__call(t,...)
	return JL.World.new(arg);
end
setmetatable(JL.World, JL.World.meta);
