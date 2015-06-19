JL.Graphics.Tilemap = {}
JL.Graphics.Tilemap.__index = function(t, k)
	if (JL.Graphics.Tilemap[k]) then 	return JL.Graphics.Tilemap[k]; end
	if (JL.Graphics[k]) then 			return JL.Graphics[k]; end
end

function JL.Graphics.Tilemap.new(--[[File,]]Width, Height, TileWidth, TileHeight, X, Y--[[, SpaceX, SpaceY, OffsetX, OffsetY]])
	--[[local SpaceX = SpaceX or 0;
	local SpaceY = SpaceY or SpaceX;
	local OffsetX = OffsetX or 0;
	local OffsetY = OffsetY or OffsetX;]]
	local X = X or 0;
	local Y = Y or 0;
	local t = setmetatable(JL.Graphics.new(X, Y), JL.Graphics.Tilemap);
	t.canvas = love.graphics.newCanvas(Width*TileWidth, Height*TileHeight);
	t.canvas:setFilter("linear", "nearest")
	t.tilesets = {}
	--t.tileset = JL.Graphics.Tileset.new(File, TileWidth, TileHeight, SpaceX, SpaceY, OffsetX, OffsetY);
	--if type(File) == "string" then File = love.graphics.newImage(File);end
	--t.image = File;
	--t.tiles = {}
	t.width = Width;
	t.height = Height;
	t.tile_width = TileWidth;
	t.tile_height = TileHeight;
	t.x = X;
	t.y = Y;
	--t.spacex = SpaceX;
	--t.spacey = SpaceY;
	--t.offx = OffsetX;
	--t.offy = OffsetY;
	--t.quad_temp = love.graphics.newQuad(0,0,TileWidth,TileHeight,t.image:getWidth(), t.image:getHeight());
	return t;
end

function JL.Graphics.Tilemap:bind() love.graphics.setCanvas(self.canvas) end
function JL.Graphics.Tilemap:unbind() love.graphics.setCanvas() end

function JL.Graphics.Tilemap:newTileset(Tileset, ID, SpaceX, SpaceY, OffsetX, OffsetY)
	local ID = ID or #self.tilesets + 1;
	local SpaceX = SpaceX or 0;
	local SpaceY = SpaceY or SpaceX;
	local OffsetX = OffsetX or 0;
	local OffsetY = OffsetY or OffsetX;
	self.tilesets[ID] = JL.Graphics.Tileset.new(Tileset, self.tile_width, self.tile_height, SpaceX, SpaceY, OffsetX, OffsetY);
end

function JL.Graphics.Tilemap:addTileset(Tileset, ID)
	if Tileset == nil then Tileset = {} end
	local ID = ID or #self.tilesets + 1;
	self.tilesets[ID] = Tileset;
end

function JL.Graphics.Tilemap:newTileExt(Tileset, x, y, width, height, ID)
	--[[ID = ID or #self.tiles+1;
	self.tiles[ID] = love.graphics.newQuad(x,y,width,height,self.image:getWidth(),self.image:getHeight());]]
	self.tilesets[Tileset]:newTileExt(x, y, width, height, ID);
end

function JL.Graphics.Tilemap:newTile(Tileset, x, y, ID)
	--[[self:newTileExt(
	self.offx+(x-1)*(self.twidth+self.spacex),
	self.offy+(y-1)*(self.theight+self.spacey),
	self.twidth,
	self.theight,
	ID);]]
	self.tilesets[Tileset]:newTile(x, y, ID);
end

function JL.Graphics.Tilemap:drawTile(Tileset, X, Y, TileX, TileY)
	--local OffX = OffX or 0;
	--local OffY = OffY or 0;
	--local q = love.graphics.newQuad(self.offx+(X-1)*(self.twidth+self.spacex), self.offy+(Y-1)*(self.theight+self.spacey),self.twidth,self.theight,self.image:getWidth(),self.image:getHeight());
	--[[self.quad_temp:setViewport(self.offx+(TileX)*(self.twidth+self.spacex), self.offy+(TileY)*(self.theight+self.spacey),self.twidth,self.theight);
	local qx, qy, qw, qh = self.quad_temp:getViewport();
	local sx, sy = self.twidth/qw, self.theight/qh;]]
	if (TileY == nil) then
		self:drawTileExt(X, Y, TileX);
		return;
	else
		self:bind();
		if self.tilesets[Tileset] ~= nil then
		self.tilesets[Tileset]:drawTile(X, Y, TileX, TileY);
		end
		--love.graphics.draw(self.image, self.quad_temp, self.twidth*X, self.theight*Y, 0, sx, sy);
		self:unbind()
	end
end

function JL.Graphics.Tilemap:drawTileExt(Tileset, X, Y, Tile)
	--local OffX = OffX or 0;
	--local OffY = OffY or 0;
	--local TileX = TileX - 1 or 1;
	--local TileY = TileY - 1 or 1;
	--[[local q = self.tiles[Tile];
	local qx, qy, qw, qh = q:getViewport();
	local sx, sy = self.twidth/qw, self.theight/qh;]]
	self:bind();
	if self.tilesets[Tileset] ~= nil then
	self.tilesets[Tileset]:drawTileExt(X, Y, Tile);
	end
	--ove.graphics.draw(self.image, q, X, Y, 0, sx, sy);
	self:unbind()
end

function JL.Graphics.Tilemap:render(parent ,x ,y)
	--print(1);
	--print(X+self.x,Y+self.y);
	local x = x or 0;
	local y = y or 0;
	if (type(parent) == "number") then y = x; x = parent; parent = nil; end
	local hasParent = true;
	if (parent == nil) then hasParent = false end;
	if (hasParent) then
		love.graphics.draw(self.canvas,
		self.x + parent.x + x, self.y + parent.y + y, math.rad(self.angle + parent.angle),
		self.scale.x*-self:getFlipX(), self.scale.y*-self:getFlipY(),
		self.origin.x, self.origin.y,
		self.shear.x, self.shear.y);
	else
	--print(x)
		love.graphics.draw(self.canvas,
		self.x + x, self.y + y, math.rad(self.angle),
		self.scale.x*-self:getFlipX(), self.scale.y*-self:getFlipY(),
		self.origin.x, self.origin.y,
		self.shear.x, self.shear.y);
	end
	--love.graphics.draw(self.canvas, self.x+X, self.y+Y);
end

JL.Graphics.Tilemap.meta = {}
function JL.Graphics.Tilemap.meta.__call(t, ...)
	return t.new(...);
end
setmetatable(JL.Graphics.Tilemap, JL.Graphics.Tilemap.meta);
