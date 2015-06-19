JL.Mask.Grid = {};
JL.Mask.Grid.__index = JL.Mask.Grid;
JL.Mask.Grid.Types = {NONE=0, EMPTY=0, ALL=1, ANY = 1, TOP=2, UP = 2, LEFT=3, RIGHT=4, BOTTOM=5, DOWN = 5}
JL.Mask.Grid.Slope = {NONE=0, EMPTY=0, UPPERLEFT=1, UPPERRIGHT=2, LOWERLEFT=3, LOWERRIGHT=4}
do	--constructors
	function JL.Mask.Grid.new(X, Y, Width, Height, TileWidth, TileHeight)
		local g = {};
		g = setmetatable(g,JL.Mask.Grid);
		g.twidth = TileWidth;
		g.theight = TileHeight;
		g.width = Width;
		g.height = Height;
		g.x = X;
		g.y = Y;
		g.types = {}
		g:newType(0,0,1,1,JL.Mask.Grid.Types.EMPTY);
		g:newType(0,0,1,1,JL.Mask.Grid.Types.EMPTY, JL.Mask.Grid.Slope.NONE, "left");
		g:newType(0,0,1,1,JL.Mask.Grid.Types.EMPTY, JL.Mask.Grid.Slope.NONE, "right");
		g:newType(0,0,1,1,JL.Mask.Grid.Types.EMPTY, JL.Mask.Grid.Slope.NONE, "up");
		g:newType(0,0,1,1,JL.Mask.Grid.Types.EMPTY, JL.Mask.Grid.Slope.NONE, "down");
		g:newType(0,0,1,1,JL.Mask.Grid.Types.ALL);
		--g.newType(0,0,1,1,JL.Mask.Grid.Types.ALL);
		for ix = 1,Width,1 do
			g[ix] = {};
			for iy = 1,Height,1 do
				g[ix][iy] = 1;
			end
		end
		return g;
	end
	
	function JL.Mask.Grid:type()
		return "grid";
	end
end

do	--grid typing
	function JL.Mask.Grid:copyTypes(from)
		self.types = from.types;
	end
	function JL.Mask.Grid:newType(X1, Y1, X2, Y2, Direction, Slope, ID)
		local ID = ID or #self.types + 1;
		local Direction = Direction or JL.Mask.Grid.Types.ALL;
		local Slope = Slope or JL.Mask.Grid.Slope.NONE;
		if self.types[ID] ~= nil then
			self.types[ID].x1 = math.min(X1, X2);
			self.types[ID].y1 = math.min(Y1, Y2);
			self.types[ID].x2 = math.max(X1, X2);
			self.types[ID].y2 = math.max(Y1, Y2);
			self.types[ID].direction = Direction;
			self.types[ID].slope = Slope;
		else
			if type(ID) == "number" then
				for i = #self.types, ID - 1 do
					if self.types[i] == nil then
						self.types[i] = {x1 = 0, y1 = 0, x2 = 1, y2 = 1, direction = JL.Mask.Grid.Types.NONE, slope = JL.Mask.Grid.Slope.NONE};
					end
				end
			end
			self.types[ID] = {x1 = math.min(X1, X2), y1 = math.min(Y1, Y2), x2 = math.max(X1, X2), y2 = math.max(Y1, Y2), direction = Direction, slope = Slope};
		end
		--print("Adding new type: " .. ID);
	end
	function JL.Mask.Grid:getType(X, Y)
		if X <= 0 then return self.types.left end
		if X > self.width then return self.types.right end
		if Y <= 0 then return self.types.up end
		if Y > self.height then return self.types.down end
		if self[X] == nil then return nil end
		if self[X][Y] == nil then return nil end
		if self.types[self[X][Y]] == nil then return nil end
		return self.types[self[X][Y]];
	end
	function JL.Mask.Grid:get(X, Y)
		if self[X] == nil then return 1 end
		if self[X][Y] == nil then return 1 end
		return self[X][Y];
	end
end
function JL.Mask.Grid:getWidth()
	return self.width * self.twidth;
end
function JL.Mask.Grid:getHeight()
	return self.height * self.theight;
end
--[[function JL.Mask.Grid:getSize()
	
end]]

function JL.Mask.Grid:getCenter()
	return self.x + self.width*self.twidth/2, self.y + self.height*self.theight/2;
end

function JL.Mask.Grid:set(X,Y,V)
	--if self[X] == nil then return end
	--if self[X][Y] == nil then return end
	local V = V or 1;
	self[X][Y] = V;
end

function JL.Mask.Grid:setRect(X,Y,W,H,V)
	local V = V or 1;
	W=W-1;
	H=H-1;
	for ix = X,X+W,1 do
		for iy = Y,Y+H,1 do
			self[ix][iy] = V;
		end
	end
end

function JL.Mask.Grid:renderType(Type, X1, Y1, X2, Y2)
	local x1 = (Type.x1)*self.twidth+X1;
	local y1 = (Type.y1)*self.theight+Y1;
	local x2 = (Type.x2)*self.twidth+X2;
	local y2 = (Type.y2)*self.theight+Y2;
	--if type(Type) == "number" then Type = self:getType(
	if type(Type.direction) == "table" then
		for i = 1, #Type.direction do
			local t = Type.direction[i];
			if type(t) == "number" then
				t = self.types[t];
			end
			self:renderType(t, X1, Y1, X2, Y2);
		end
	elseif Type.direction == JL.Mask.Grid.Types.ALL then
		if Type.slope == JL.Mask.Grid.Slope.NONE then
			love.graphics.rectangle("fill",x1,y1,x2-x1,y2-y1);
			--love.graphics.polygon("fill", x1,y1, x2,y1, x2,y2, x1,y2);
		elseif Type.slope == JL.Mask.Grid.Slope.UPPERLEFT then
			love.graphics.polygon("fill", x1,y2, x2,y1, x2,y2);
		elseif Type.slope == JL.Mask.Grid.Slope.UPPERRIGHT then
			love.graphics.polygon("fill", x1,y2, x1,y1, x2,y2);
		elseif Type.slope == JL.Mask.Grid.Slope.LOWERLEFT then
			love.graphics.polygon("fill", x1,y1, x2,y2, x2,y1);
		elseif Type.slope == JL.Mask.Grid.Slope.LOWERRIGHT then
			love.graphics.polygon("fill", x1,y1, x1,y2, x2,y1);
		end
	end
end

function JL.Mask.Grid:render(X, Y)
	local X = X or 0;
	local Y = Y or 0;
	for ix = 1,self.width do
		for iy = 1,self.height do
			local tile = self:getType(ix, iy);
			if type ~= nil then
				--if tile.direction == JL.Mask.Grid.Types.ALL then
				local x1 = self.x+(ix-1)*self.twidth+X;
				local y1 = self.y+(iy-1)*self.theight+Y;
				local x2 = self.x+(ix-1)*self.twidth+X;
				local y2 = self.y+(iy-1)*self.theight+Y;
				self:renderType(tile, x1, y1, x2, y2);
				--[[elseif tile.direction == JL.Mask.Grid.Types.TOP then
					love.graphics.rectangle("fill",self.x+(ix-1)*self.twidth-X,self.y+(iy-1)*self.theight-Y                 ,self.twidth,1);
				elseif tile.direction == JL.Mask.Grid.Types.BOTTOM then
					love.graphics.rectangle("fill",self.x+(ix-1)*self.twidth-X,self.y+(iy-1)*self.theight-Y  +self.theight-1,self.twidth,1);
				elseif tile.direction == JL.Mask.Grid.Types.LEFT then
					love.graphics.rectangle("fill",self.x+(ix-1)*self.twidth-X,self.y+(iy-1)*self.theight-Y                 ,1,self.theight);
				elseif tile.direction == JL.Mask.Grid.Types.RIGHT then
					love.graphics.rectangle("fill",self.x+(ix-1)*self.twidth-X  +self.twidth-1,self.y+(iy-1)*self.theight-Y ,1,self.theight);
				end]]
			
			end
			-- love.graphics.rectangle("line",self.x+(ix-1)*self.twidth,self.y+(iy-1)*self.theight,self.twidth,self.theight); end
			
		end
	end
end

function JL.Mask.Grid:open(f)
	local file,err = io.open(f);
	--if file == nil then print("NO FILE"); end
	if err ~= nil then print(err); return; end;
	local done = false;
	local ix,iy = 0,1;
	while true do
		local x = file:read(1);
		if tonumber(x) ~= nil then
			ix = ix + 1;
			if ix > self.width then
				ix = 1; iy = iy + 1;
			end
			self[ix][iy] = tonumber(x);--)-- > 0 and true or false;
		end
		if iy > self.height or x == nil then break end
		--if x == '0' then self[ix][iy] = 0; end
		--if x == '1' then self[ix][iy] = 1; end
		--if x == '2' then self[ix][iy] = 2; end
	end
	file:close();
	collectgarbage();
end

function JL.Mask.Grid:addPhysicsTile(World, Friction, Type, ix, iy)
	--local type = self:getType(ix, iy);
	local ttop = self:getType(ix, iy-1);
	local tleft = self:getType(ix-1, iy);
	local tbottom = self:getType(ix, iy+1);
	local tright = self:getType(ix+1, iy);
	local top = false;
	local left = false;
	local right = false;
	local bottom = false;
	if Type ~= nil then
		if type(Type.direction) == "table" then
			for i = 1, #Type.direction do
				local t = Type.direction[i];
				if type(t) == "number" then
					t = self.types[t];
				end
				self:addPhysicsTile(World, Friction, t, ix, iy);
			end
		else
			if Type.direction ~= JL.Mask.Grid.Types.NONE then
				if ttop ~= nil then top = ttop.direction ~= JL.Mask.Grid.Types.NONE; end
				if tleft ~= nil then left = tleft.direction ~= JL.Mask.Grid.Types.NONE; end
				if tbottom ~= nil then bottom = tbottom.direction ~= JL.Mask.Grid.Types.NONE; end
				if tright ~= nil then right = tright.direction ~= JL.Mask.Grid.Types.NONE; end
				local w = self.twidth/2;
				local h = self.twidth/2;
				
				local x1 = (Type.x1 - 0.5) * self.twidth;
				local x2 = (Type.x2 - 0.5) * self.twidth;
				local y1 = (Type.y1 - 0.5) * self.theight;
				local y2 = (Type.y2 - 0.5) * self.theight;
				--if not top then
				if Type.slope ~= JL.Mask.Grid.Slope.UPPERLEFT and Type.slope ~= JL.Mask.Grid.Slope.UPPERRIGHT then
					local X = (ix-1)*self.twidth;
					local Y = (iy-1)*self.theight;
					local body = love.physics.newBody(World.physics, X, Y, "static");
					local shape = love.physics.newEdgeShape(x1, y1, x2, y1);
					local fixture = love.physics.newFixture(body, shape, 100);
					fixture:setFriction(Friction);
				end
				--if not left then
				if Type.slope ~= JL.Mask.Grid.Slope.UPPERLEFT and Type.slope ~= JL.Mask.Grid.Slope.LOWERLEFT then
					local X = (ix-1)*self.twidth;
					local Y = (iy-1)*self.theight;
					local body = love.physics.newBody(World.physics, X, Y, "static");
					local shape = love.physics.newEdgeShape(x1, y1, x1, y2);
					local fixture = love.physics.newFixture(body, shape, 100);
					fixture:setFriction(Friction);
				end
				--if not right then
				if Type.slope ~= JL.Mask.Grid.Slope.LOWERRIGHT and Type.slope ~= JL.Mask.Grid.Slope.UPPERRIGHT then
					local X = (ix-1)*self.twidth;
					local Y = (iy-1)*self.theight;
					local body = love.physics.newBody(World.physics, X, Y, "static");
					local shape = love.physics.newEdgeShape(x2, y1, x2, y2);
					local fixture = love.physics.newFixture(body, shape, 100);
					fixture:setFriction(Friction);
				end
				--if not bottom then
				if Type.slope ~= JL.Mask.Grid.Slope.LOWERLEFT and Type.slope ~= JL.Mask.Grid.Slope.LOWERRIGHT then
					local X = (ix-1)*self.twidth;
					local Y = (iy-1)*self.theight;
					local body = love.physics.newBody(World.physics, X, Y, "static");
					local shape = love.physics.newEdgeShape(x1, y2, x2, y2);
					local fixture = love.physics.newFixture(body, shape, 100);
					fixture:setFriction(Friction);
				end
				if Type.slope == JL.Mask.Grid.Slope.UPPERLEFT or Type.slope == JL.Mask.Grid.Slope.LOWERRIGHT then
					local X = (ix-1)*self.twidth;
					local Y = (iy-1)*self.theight;
					local body = love.physics.newBody(World.physics, X, Y, "static");
					local shape = love.physics.newEdgeShape(x1, y2, x2, y1);
					local fixture = love.physics.newFixture(body, shape, 100);
					fixture:setFriction(Friction);
				end
				if Type.slope == JL.Mask.Grid.Slope.UPPERRIGHT or Type.slope == JL.Mask.Grid.Slope.LOWERLEFT then
					local X = (ix-1)*self.twidth;
					local Y = (iy-1)*self.theight;
					local body = love.physics.newBody(World.physics, X, Y, "static");
					local shape = love.physics.newEdgeShape(x1, y1, x2, y2);
					local fixture = love.physics.newFixture(body, shape, 100);
					fixture:setFriction(Friction);
				end
				--[[local X = (ix-1)*self.twidth;
				local Y = (iy-1)*self.theight;
				local body = love.physics.newBody(World.physics, 0, 0, "static");
				local shape = love.physics.newRectangleShape(X, Y, self.twidth, self.theight);
				local joint = love.physics.newWeldJoint(body_main, body, 0, 0);
				local fixture = love.physics.newFixture(body, shape, 100);
				fixture:setFriction(Friction);]]
			end
		end
	end
end

function JL.Mask.Grid:populatePhysicsWorld(World, Friction)
	local World = World or JL.world;
	local Friction = Friction or 0;
	--local body_main = love.physics.newBody(World.physics, 0, 0, "static");
	for ix = 1, self.width do
		for iy = 1, self.height do
			self:addPhysicsTile(World, Friction, self:getType(ix, iy), ix, iy); 
		end
	end
end

function JL.Mask.Grid:collideBox()
	
end

JL.Mask.Grid.meta = {};
function JL.Mask.Grid.meta.__call(t,...)
	return t.new(...);
end
setmetatable(JL.Mask.Grid, JL.Mask.Grid.meta);
