JL.Mask.Box = {};
JL.Mask.Box.__index = JL.Mask.Box;

function JL.Mask.Box.new(X,Y,W,H)
	local b = setmetatable({x=X,y=Y,w=W,h=H},JL.Mask.Box);
	if b.w == nil then
		b.w = X;
		b.h = Y;
		b.x = 0;
		b.y = 0;
	end
	return b;
end

function JL.Mask.Box:getWidth()
	return self.w;
end
function JL.Mask.Box:getHeight()
	return self.h;
end

function JL.Mask.Box:getCenter()
	return self.x + self.w/2, self.y + self.h/2;
end

function JL.Mask.Box:type()
	return "box";
end

function JL.Mask.Box.collideAABB(box1_x1, box1_y1, box1_x2, box1_y2, box2_x1, box2_y1, box2_x2, box2_y2)
	if(box1_y2 <= box2_y1
	or box1_y1 >= box2_y2
	or box1_x2 <= box2_x1
	or box1_x1 >= box2_x2) then return false end
	return true;
end

function JL.Mask.Box.collideBoxless(box1_x, box1_y, box1_w, box1_h, box2_x, box2_y, box2_w, box2_h, MoveX, MoveY, Sweep)
	local ax = box1_x;
	local ay = box1_y;
	local ah = box1_h;
	local aw = box1_w;
	local bx = box2_x;
	local by = box2_y;
	local bh = box2_h;
	local bw = box2_w;
	if Sweep then
		
		local X = ax + MoveX;
		local Y = ay + MoveY;
		
		ax = ax + math.min(MoveX, 0);
		aw = aw + math.abs(MoveX);
		local collided_x = true;
		if(ay + ah <= by
		or ay >= by + bh
		or ax + aw <= bx
		or ax >= bx + bw) then 
			collided_x = false;
		else
			X = bx + ((box1_x + box1_w/2 < box2_x + box2_w/2) and -box1_w or box2_w); 
		end
		ax = X;
		aw = box1_w;
		
		ay = ay + math.min(MoveY, 0);
		ah = ah + math.abs(MoveY);
		local collided_y = true;
		if(ay + ah <= by
		or ay >= by + bh
		or ax + aw <= bx
		or ax >= bx + bw) then 
			collided_y = false;
		else
			Y = by + ((box1_y + box1_h/2 < box2_y + box2_h/2) and -box1_h or box2_h); 
		end
		
		local collided = collided_x or collided_y
		
		return collided, X, Y;
	else
		local ax = ax + MoveX;
		local ay = ay + MoveY;

		if(ay + ah <= by
		or ay >= by + bh
		or ax + aw <= bx
		or ax >= bx + bw) then 
			return false;
		end
		return true;
	end
end

function JL.Mask.Box.collideBox(a, b, MoveX, MoveY, Sweep)
	return JL.Mask.Box.collideBoxless(a.x, a.y, a.w, a.h, b.x, b.y, b.w, b.h, MoveX, MoveY, Sweep);
end

function JL.Mask.Box.collideGrid(box, grid, X, Y, Sweep)
	--if Sweep then return 
	local c, x, y = JL.Mask.Box.collideGridSweep(box, grid, X, Y);
	if Sweep then return c, x, y else return c end
	--else return JL.Mask.Box.collideGridXY(box, grid, X, Y) end
end

function JL.Mask.Box.collideGridXY(box, grid, MoveX, MoveY)
	
	local BOX_X = box.x
	local BOX_Y = box.y
	local BOX_W = box.w
	local BOX_H = box.h
	
	BOX_X = (BOX_X-grid.x);
	BOX_Y = (BOX_Y-grid.y);
	BOX_W = (BOX_W);
	BOX_H = (BOX_H);
	
	local BOX_MOVE_X = BOX_X + math.min(0, MoveX);
	local BOX_MOVE_Y = BOX_Y + math.min(0, MoveY);
	local BOX_MOVE_W = BOX_W + math.abs(MoveX);
	local BOX_MOVE_H = BOX_H + math.abs(MoveY);
	
	local has_collided = false;
	--fairly self-explanatory, cycles through all squares in range until a filled square is found.
	local minimum_x = JL.Math.clamp(math.floor((BOX_MOVE_X             )/grid.twidth ),-1,grid.width )
	local maximum_x = JL.Math.clamp(math.ceil((BOX_MOVE_X + BOX_MOVE_W)/grid.twidth ),-1,grid.width )
	local minimum_y = JL.Math.clamp(math.floor((BOX_MOVE_Y             )/grid.theight),-1,grid.height)
	local maximum_y = JL.Math.clamp(math.ceil((BOX_MOVE_Y + BOX_MOVE_H)/grid.theight),-1,grid.height)
	for ix = minimum_x, maximum_x do
		--if (ix > -1 and ix < grid.width) then
			for iy = minimum_y, maximum_y, 1 do
				--if (iy > -1 and iy < grid.height) then
					local tile = grid:getType(ix+1, iy+1)
					if tile ~= nil then
						if type(tile.direction) == "table" then
							
						else
							
						end
						if tile.direction == JL.Mask.Grid.Types.ALL then 
							local x1, y1, x2, y2 = tile.x1 * grid.twidth, tile.y1 * grid.theight, tile.x2 * grid.twidth, tile.y2 * grid.theight;
							--x1, x2 = math.min(x1, x2), math.max(x1, x2);
							--y1, y2 = math.min(y1, y2), math.max(y1, y2);
							local GRID_X1 = ix * grid.twidth + x1;
							local GRID_Y1 = iy * grid.theight + y1;
							local GRID_X2 = ix * grid.twidth + x2;
							local GRID_Y2 = iy * grid.theight + y2;
							local foo = 0;
							if type.slope == JL.Mask.Grid.Slope.UPPERLEFT then
								foo = BOX_X + BOX_W
								foo = foo - (ix * grid.twidth + x1)
								foo = 1-JL.Math.clamp(foo/(x2-x1), 0.0, 1.0);
								GRID_Y1 = GRID_Y1 + foo * (y2 - y1);
								foo = BOX_Y + BOX_H
								foo = foo - (iy * grid.theight + y1)
								foo = 1-JL.Math.clamp(foo/(y2-y1), 0.0, 1.0);
								GRID_X1 = GRID_X1 + foo * (x2 - x1);
							end
							if type.slope == JL.Mask.Grid.Slope.UPPERRIGHT then
								foo = BOX_X;
								foo = foo - (ix * grid.twidth + x1)
								foo = JL.Math.clamp(foo/(x2-x1), 0.0, 1.0);
								GRID_Y1 = GRID_Y1 + foo * (y2 - y1);
								foo = BOX_Y + BOX_H
								foo = foo - (iy * grid.theight + y1)
								foo = 1-JL.Math.clamp(foo/(y2-y1), 0.0, 1.0);
								GRID_X2 = GRID_X2 - foo * (x2 - x1);
							end
							if type.slope == JL.Mask.Grid.Slope.LOWERLEFT then
								foo = BOX_X + BOX_W
								foo = foo - (ix * grid.twidth + x1)
								foo = 1-JL.Math.clamp(foo/(x2-x1), 0.0, 1.0);
								GRID_Y2 = GRID_Y2 - foo * (y2 - y1);
								foo = BOX_Y
								foo = foo - (iy * grid.theight + y1)
								foo = JL.Math.clamp(foo/(y2-y1), 0.0, 1.0);
								GRID_X1 = GRID_X1 + foo * (x2 - x1);
							end
							if type.slope == JL.Mask.Grid.Slope.LOWERRIGHT then
								foo = BOX_X;
								foo = foo - (ix * grid.twidth + x1)
								foo = JL.Math.clamp(foo/(x2-x1), 0.0, 1.0);
								GRID_Y2 = GRID_Y2 - foo * (y2 - y1);
								foo = BOX_Y
								foo = foo - (iy * grid.theight + y1)
								foo = JL.Math.clamp(foo/(y2-y1), 0.0, 1.0);
								GRID_X2 = GRID_X2 - foo * (x2 - x1);
							end
							local GRID_X = GRID_X1;
							local GRID_Y = GRID_Y1;
							local GRID_W = GRID_X2 - GRID_X1;
							local GRID_H = GRID_Y2 - GRID_Y1;
							local c, x, y = JL.Mask.Box.collideBoxless(BOX_X, BOX_Y, BOX_W, BOX_H, GRID_X, GRID_Y, GRID_W, GRID_H, MoveX, MoveY, true);
							if c then
								has_collided = true; 
							end
						end
						if type.direction == JL.Mask.Grid.Types.TOP and (BOX_Y+BOX_H <= iy) then has_collided = true; end
						if type.direction == JL.Mask.Grid.Types.BOTTOM and (BOX_Y >= iy + 1) then has_collided = true; end
						if type.direction == JL.Mask.Grid.Types.LEFT and (BOX_X+BOX_W <= ix) then has_collided = true; end
						if type.direction == JL.Mask.Grid.Types.RIGHT and (BOX_X >= ix + 1) then has_collided = true; end
					end
					if (has_collided) then break; end
				--end
			end
			if (has_collided) then break; end
		--end
	end
	return has_collided;
end

function JL.Mask.Box.testGridTile(BOX_X, BOX_Y, BOX_W, BOX_H, GRID_X, GRID_Y, TileWidth, TileHeight, Tile, TileX, TileY, MoveX, MoveY, horizontal)
	--local MoveX = MoveX or 0;
	--local MoveY = MoveY or 0;
	if Tile.direction == JL.Mask.Grid.Types.ALL then 
		local x1 = Tile.x1 * TileWidth;
		local y1 = Tile.y1 * TileHeight; 
		local x2 = Tile.x2 * TileWidth; 
		local y2 = Tile.y2 * TileHeight;
		--x1, x2 = math.min(x1, x2), math.max(x1, x2);
		--y1, y2 = math.min(y1, y2), math.max(y1, y2);
		local GRID_X1 = TileX * TileWidth + x1 + GRID_X;
		local GRID_Y1 = TileY * TileHeight + y1 + GRID_Y;
		local GRID_X2 = TileX * TileWidth + x2 + GRID_X;
		local GRID_Y2 = TileY * TileHeight + y2 + GRID_Y;
		if horizontal then
			local foo = 0;
			if Tile.slope == JL.Mask.Grid.Slope.UPPERLEFT then
				foo = BOX_Y + BOX_H;
				foo = foo - GRID_Y1
				foo = 1-JL.Math.clamp(foo/(y2-y1), 0.0, 1.0);
				GRID_X1 = GRID_X1 + foo * (x2 - x1);
			end
			if Tile.slope == JL.Mask.Grid.Slope.UPPERRIGHT then
				foo = BOX_Y + BOX_H;
				foo = foo - GRID_Y1
				foo = 1-JL.Math.clamp(foo/(y2-y1), 0.0, 1.0);
				GRID_X2 = GRID_X2 - foo * (x2 - x1);
			end
			if Tile.slope == JL.Mask.Grid.Slope.LOWERLEFT then
				foo = BOX_Y;
				foo = foo - GRID_Y1
				foo = JL.Math.clamp(foo/(y2-y1), 0.0, 1.0);
				GRID_X1 = GRID_X1 + foo * (x2 - x1);
			end
			if Tile.slope == JL.Mask.Grid.Slope.LOWERRIGHT then
				foo = BOX_Y;
				foo = foo - GRID_Y1
				foo = JL.Math.clamp(foo/(y2-y1), 0.0, 1.0);
				GRID_X2 = GRID_X2 - foo * (x2 - x1);
			end
		else
			local foo = 0;
			if Tile.slope == JL.Mask.Grid.Slope.UPPERLEFT then
				foo = BOX_X + BOX_W;
				foo = foo - GRID_X1
				foo = 1-JL.Math.clamp(foo/(x2-x1), 0.0, 1.0);
				GRID_Y1 = GRID_Y1 + foo * (y2 - y1);
			end
			if Tile.slope == JL.Mask.Grid.Slope.UPPERRIGHT then
				foo = BOX_X;
				foo = foo - GRID_X1
				foo = JL.Math.clamp(foo/(x2-x1), 0.0, 1.0);
				GRID_Y1 = GRID_Y1 + foo * (y2 - y1);
			end
			if Tile.slope == JL.Mask.Grid.Slope.LOWERLEFT then
				foo = BOX_X + BOX_W;
				foo = foo - GRID_X1
				foo = 1-JL.Math.clamp(foo/(x2-x1), 0.0, 1.0);
				GRID_Y2 = GRID_Y2 - foo * (y2 - y1);
			end
			if Tile.slope == JL.Mask.Grid.Slope.LOWERRIGHT then
				foo = BOX_X;
				foo = foo - GRID_X1
				foo = JL.Math.clamp(foo/(x2-x1), 0.0, 1.0);
				GRID_Y2 = GRID_Y2 - foo * (y2 - y1);
			end
		end
		local GRID_X = GRID_X1;
		local GRID_Y = GRID_Y1;
		local GRID_W = GRID_X2 - GRID_X1;
		local GRID_H = GRID_Y2 - GRID_Y1;
		local c, x, y = JL.Mask.Box.collideBoxless(BOX_X, BOX_Y, BOX_W, BOX_H, GRID_X, GRID_Y, GRID_W, GRID_H, MoveX, MoveY, true);
		return c, x, y;
	end
	return false, 0, 0;
end

function JL.Mask.Box.collideGridSweep(box,grid,MoveX,MoveY)
	local BOX_X = (box.x);
	local BOX_Y = (box.y);
	local BOX_W = (box.w);
	local BOX_H = (box.h);
	
	--local XD, YD = ((MoveX > 0) and 1 or -1), ((MoveY > 0) and 1 or -1);
	--local W, H = ((MoveX > 0) and BOX_W or 0), ((MoveY > 0) and BOX_H or 0);
	local has_collided_x, has_collided_y = false, false;
	local X, Y = box.x+MoveX, box.y+MoveY
	--not-so self explanatory. Loops through all possible tiles and returns the value of the coordinates where collision can be resolved
	
	--MoveX = MoveX /grid.twidth;
	--MoveY = MoveY /grid.theight;
	local minimum_x = JL.Math.clamp(math.floor((BOX_X +         math.min(0, MoveX)-grid.x)/grid.twidth ),-1,grid.width)
	local maximum_x = JL.Math.clamp(math.floor((BOX_X + BOX_W + math.max(0, MoveX)-grid.x)/grid.twidth ),-1,grid.width)
	local minimum_y = JL.Math.clamp(math.floor((BOX_Y                             -grid.y)/grid.theight),-1,grid.height)
	local maximum_y = JL.Math.clamp(math.floor((BOX_Y + BOX_H                     -grid.y)/grid.theight),-1,grid.height)
	
	for ix = minimum_x, maximum_x do
		--if (ix > -1 and ix < grid.width) then
			for iy = minimum_y, maximum_y, 1 do
				--if (iy > -1 and iy < grid.height) then
					local tile = grid:getType(ix+1, iy+1)
					if tile ~= nil then
						if type(tile.direction) == "table" then
							for i = 1, #tile.direction do
								local new_collision = ix;
								local collided = false;
								local Tile = grid.types[tile.direction[i] ];
								local c, x, y = JL.Mask.Box.testGridTile(BOX_X, BOX_Y, BOX_W, BOX_H, grid.x, grid.y, grid.twidth, grid.theight, Tile, ix, iy, MoveX, 0, true) 
								if c then
									collided = true 
									new_collision = x;
								end
								if collided then
									if not has_collided_x or (MoveX > 0 and new_collision < X) or (MoveX < 0 and new_collision > X) then
										X = new_collision
									end
									has_collided_x = true;
								end
							end
						else
							local new_collision = ix;
							local collided = false;
							local c, x, y = JL.Mask.Box.testGridTile(BOX_X, BOX_Y, BOX_W, BOX_H, grid.x, grid.y, grid.twidth, grid.theight, tile, ix, iy, MoveX, 0, true) 
							if c then
								collided = true 
								new_collision = x;
							end
							if collided then
								if not has_collided_x or (MoveX > 0 and new_collision < X) or (MoveX < 0 and new_collision > X) then
									X = new_collision
								end
								has_collided_x = true;
							end
						end
					end
				--end
			end
		--end
	end
	if(has_collided_x) then
		--X = collision_x*grid.twidth + grid.x + ((MoveX > 0) and -box.w or grid.twidth);
		BOX_X = X;
		BOX_W = box.w;
	end

	minimum_x = JL.Math.clamp(math.floor((BOX_X                             -grid.x)/grid.twidth ),-1,grid.width)
	maximum_x = JL.Math.clamp(math.floor((BOX_X + BOX_W                     -grid.x)/grid.twidth ),-1,grid.width)
	minimum_y = JL.Math.clamp(math.floor((BOX_Y +         math.min(0, MoveY)-grid.y)/grid.theight),-1,grid.height)
	maximum_y = JL.Math.clamp(math.floor((BOX_Y + BOX_H + math.max(0, MoveY)-grid.y)/grid.theight),-1,grid.height)
	for iy = minimum_y, maximum_y do
		--if (iy > -1 and iy < grid.height) then
			for ix = minimum_x, maximum_x, 1 do
				--if (ix > -1 and ix < grid.width) then
					local tile = grid:getType(ix+1, iy+1)
					if tile ~= nil then
						if type(tile.direction) == "table" then
							for i = 1, #tile.direction do
								local new_collision = iy;
								local collided = false;
								local Tile = grid.types[tile.direction[i] ];
								local c, x, y = JL.Mask.Box.testGridTile(BOX_X, BOX_Y, BOX_W, BOX_H, grid.x, grid.y, grid.twidth, grid.theight, Tile, ix, iy, 0, MoveY, false) 
								if c then
									collided = true 
									new_collision = y;
								end
								if collided then
									if not has_collided_y or (MoveY > 0 and new_collision < Y) or (MoveY < 0 and new_collision > Y) then
										Y = new_collision
									end
									has_collided_y = true;
								end
							end
						else
							local new_collision = iy;
							local collided = false;
							local c, x, y = JL.Mask.Box.testGridTile(BOX_X, BOX_Y, BOX_W, BOX_H, grid.x, grid.y, grid.twidth, grid.theight, tile, ix, iy, 0, MoveY, false) 
							if c then
								collided = true 
								new_collision = y;
							end
							if collided then
								if not has_collided_y or (MoveY > 0 and new_collision < Y) or (MoveY < 0 and new_collision > Y) then
									Y = new_collision
								end
								has_collided_y = true;
							end
						end
						--if type.direction == JL.Mask.Grid.Types.TOP and (BOX_Y+BOX_H <= iy) then collided = true end
						--if type.direction == JL.Mask.Grid.Types.BOTTOM and (BOX_Y >= iy + 1) then collided = true end
					end
				--end
			end
		--end
	end
	if(has_collided_y) then
		
		--Y = collision_y*grid.theight + grid.y + ((MoveY > 0) and -box.h or grid.theight);
	end
	
	local collided = has_collided_x or has_collided_y
	
	return collided, X, Y;
end

function JL.Mask.Box:render(Entity, X, Y)
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
	love.graphics.rectangle("fill",
	self.x+x,
	self.y+y,
	self.w,
	self.h);
end

JL.Mask.Box.meta = {}
function JL.Mask.Box.meta.__call(t, ...)
	--print("FOO")
	return t.new(...);
end
setmetatable(JL.Mask.Box,JL.Mask.Box.meta);
