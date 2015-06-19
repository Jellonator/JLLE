JL.Graphics.Tileset = {}
JL.Graphics.Tileset.__index = JL.Graphics.Tileset;

function JL.Graphics.Tileset.new(File, TileWidth, TileHeight, SpaceX, SpaceY, OffsetX, OffsetY)
	local SpaceX = SpaceX or 0;
	local SpaceY = SpaceY or SpaceX;
	local OffsetX = OffsetX or 0;
	local OffsetY = OffsetY or OffsetX;
	local t = setmetatable({}, JL.Graphics.Tileset);
	--t.canvas = love.graphics.newCanvas(Width*TileWidth, Height*TileHeight);
	--print(File)
	--print(File)
	if type(File) == "string" then File = love.graphics.newImage(love.filesystem.newFileData(File));end
	t.image = File;
	t.tiles = {}
	t.tile_width = TileWidth;
	t.tile_height = TileHeight;
	t.spacex = SpaceX;
	t.spacey = SpaceY;
	t.offx = OffsetX;
	t.offy = OffsetY;
	
	t.quad_temp = love.graphics.newQuad(0,0,TileWidth,TileHeight,t.image:getWidth(), t.image:getHeight());
	return t;
end

function JL.Graphics.Tileset:newTileExt(x, y, width, height, ID)
	local ID = ID or #self.tiles+1;
	self.tiles[ID] = love.graphics.newQuad(x,y,width,height,self.image:getWidth(),self.image:getHeight());
end

function JL.Graphics.Tileset:newTile(x, y, ID)
	self:newTileExt(
	self.offx+(x-1)*(self.tile_width+self.spacex),
	self.offy+(y-1)*(self.tile_height+self.spacey),
	self.tile_width,
	self.tile_height,
	ID);
end

function JL.Graphics.Tileset:drawTile(X, Y, TileX, TileY)
	X = X - 1
	Y = Y - 1
	self.quad_temp:setViewport(self.offx+(TileX)*(self.tile_width+self.spacex), self.offy+(TileY)*(self.tile_height+self.spacey),self.tile_width,self.tile_height);
	local qx, qy, qw, qh = self.quad_temp:getViewport();
	local sx, sy = self.tile_width/qw, self.tile_height/qh;
	love.graphics.draw(self.image, self.quad_temp, self.tile_width*X, self.tile_height*Y, 0, sx, sy);
end

function JL.Graphics.Tileset:drawTileExt(X, Y, Tile)
	local X = (X - 1) * self.tile_width;
	local Y = (Y - 1) * self.tile_height;
	local Tile = Tile + 1;
	local q = self.tiles[Tile];
	if q then
		local qx, qy, qw, qh = q:getViewport();
		local sx, sy = self.tile_width/qw, self.tile_height/qh;
		love.graphics.draw(self.image, q, X, Y, 0, sx, sy);
	end
end

JL.Graphics.Tileset.meta = {}
function JL.Graphics.Tileset.meta.__call(t, ...)
	return t.new(...);
end
setmetatable(JL.Graphics.Tileset, JL.Graphics.Tileset.meta);