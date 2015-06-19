JL.TMX = {}
JL.TMX.__index = function(t, k)
	if (JL.TMX.Properties[k]) then return JL.TMX.Properties[k]; end
	if (JL.TMX[k])            then return JL.TMX[k]; end
end

JL.TMX.Properties = {}
JL.TMX.Properties.__index = JL.TMX.Properties
function JL.TMX.Properties.new()
	return setmetatable({
		properties = {}
	}, JL.TMX.Base);
end
function JL.TMX.Properties:loadProperties(Node)
	if Node == nil then return end
	if Node.getChild == nil then return end
	if self.properties == nil then self.properties = {} end
	local Properties = Node:getChild("properties") or Node;
	local property_count = Properties:count("property");
	for i = 1, property_count do
		local Property = Properties:getChild("property", i);
		local name = Property:getArgument("name")
		local value = Property:getArgument("value")
		--print("Loaded property '" .. name .. "' with value of '" .. value .. "'")
		self.properties[name] = value;
	end
end
function JL.TMX.Properties:getProperty(name)
	return self.properties[name];
end

JL.TMX.Objectgroup = {}
JL.TMX.Objectgroup.__index = function(t, k)
	if (JL.TMX.Properties[k]) then 	return JL.TMX.Properties[k]; end
	if (JL.TMX.Objectgroup[k]) then return JL.TMX.Objectgroup[k]; end
end
function JL.TMX.Objectgroup.new(Parent, Node)
	local group = setmetatable({
		rectangles = {},
		circles = {},
		polygons = {},
		polylines = {},
		tiles = {},
		parent = Parent
	}, JL.TMX.Objectgroup);
	group:loadProperties(Node);
	return group
end
function JL.TMX.Objectgroup:countRectangles()
	return #self.rectangles;
end
function JL.TMX.Objectgroup:countCircles()
	return #self.circles;
end
function JL.TMX.Objectgroup:countPolygons()
	return #self.polygons;
end
function JL.TMX.Objectgroup:countPolylines()
	return #self.polylines;
end
function JL.TMX.Objectgroup:countTiles()
	return #self.tiles;
end
function JL.TMX.Objectgroup:getRectangle(ID)
	return self.rectangles[ID];
end
function JL.TMX.Objectgroup:getCircle(ID)
	return self.circles[ID];
end
function JL.TMX.Objectgroup:getPolygon(ID)
	return self.polygons[ID];
end
function JL.TMX.Objectgroup:getPolyline(ID)
	return self.polylines[ID];
end
function JL.TMX.Objectgroup:getTile(ID)
	return self.tiles[ID];
end
function JL.TMX.Objectgroup:addObject(Node)
	local X = tonumber(Node:getArgument("x"));
	local Y = tonumber(Node:getArgument("y"));
	local Width = tonumber(Node:getArgument("width"));
	local Height = tonumber(Node:getArgument("height"));
	local ID = tonumber(Node:getArgument("id"));
	local GID = tonumber(Node:getArgument("gid"));
	local Polygon = Node:getChild("polygon");
	local Polyline = Node:getChild("polyline");
	local Ellipse = Node:getChild("ellipse");
	local isGID = Node:getArgument("gid");
	local object = nil;
	if isGID ~= nil then
		--Tile
		--GID = GID + 70
		local tile = JL.TMX.Tile.new(Node);
		local id = GID - 1;
		local tileset_id = 1;
		--print("tileset count", #self.parent.tilesets_by_gid)
		for i = 1, #self.parent.tilesets_by_gid do
			local tileset = self.parent.tilesets_by_gid[i]
			if GID >= tileset.gid and i > tileset_id then
				id = GID - tileset.gid;
				tileset_id = i
			end
		end
		tile.tile = id;
		tile.gid = GID;
		tile.tileset = tileset_id;
		tile.tileX = math.fmod(id, self.parent:getTileset(tile.tileset).width);
		tile.tileY = (id - tile.tileX)/self.parent:getTileset(tile.tileset).width;
		tile.x = X;
		tile.y = Y - self.parent:getTileHeight();
		table.insert(self.tiles, tile);
		--print("ADDED TILE")
	elseif Ellipse ~= nil then
		--Ellipse
		object = setmetatable({
			x = X,
			y = Y,
			width = Width,
			height = Height
		}, JL.TMX.Properties)
		table.insert(self.circles, object);
		--print("ADDED CIRCLE")
	elseif Polygon ~= nil or Polyline ~= nil then
		--Polygon/Polyline
		--[[TODO: POLYGONS]]
		--print("ADDED POLYGON")
	else
		--Rectangle
		object = setmetatable({
			x = X,
			y = Y,
			width = Width,
			height = Height
		}, JL.TMX.Properties)
		
		table.insert(self.rectangles, object);
		--print("ADDED RECTANGLE")
	end
	if object ~= nil then
		object:loadProperties(Node);
	end
end

JL.TMX.Tileset = {}
JL.TMX.Tileset.__index = function(t, k)
	if (JL.TMX.Properties[k]) then return JL.TMX.Properties[k]; end
	if (JL.TMX.Tileset[k])    then return JL.TMX.Tileset[k]; end
end
function JL.TMX.Tileset.new(Node)
	local tileset = setmetatable({}, JL.TMX.Tileset);
	tileset.gid = 0;
	tileset.tile_width = 1;
	tileset.tile_height = 1;
	tileset.spacing = 0
	tileset.margin = 0;
	tileset.width = 1;
	tileset.height = 1;
	tileset.file = nil;
	--[[tileset.image = {
		source = "",
	}]]
	tileset:loadProperties(Node);
	return tileset
end
function JL.TMX.Tileset:createTileset()
	if self.source == nil then return nil end
	local tileset = JL.Graphics.Tileset.new(self.source, self.tile_width, self.tile_height, self.spacing, self.spacing, self.margin, self.margin);
	local ID = 1;
	for iy = 1, self.height do
		for ix = 1, self.width do
			tileset:newTile(ix, iy, ID);
			ID = ID + 1;
		end
	end
	return tileset;
end

JL.TMX.Tile = {}
JL.TMX.Tile.__index = function(t, k)
	if (JL.TMX.Properties[k]) then return JL.TMX.Properties[k]; end
	if (JL.TMX.Tile[k])       then return JL.TMX.Tile[k]; end
end
function JL.TMX.Tile.new(Node)
	local tile = setmetatable({
		tileX = 0;
		tileY = 0;
		tile = 0;
		tileset = 0;
		gid = 0,
	}, JL.TMX.Tile);
	tile:loadProperties(Node);
	return tile
end

JL.TMX.Layer = {}
JL.TMX.Layer.__index = function(t, k)
	if (JL.TMX.Properties[k]) then return JL.TMX.Properties[k]; end
	if (JL.TMX.Layer[k])      then return JL.TMX.Layer[k]; end
end
function JL.TMX.Layer.new(Width, Height, Parent, Node)
	local layer = setmetatable({
		--data = {},
		width = Width,
		height = Height,
		parent = Parent
	}, JL.TMX.Layer);
	for ix = 1, Width do 
		layer[ix] = {}
		for iy = 1, Height do
			layer[ix][iy] = JL.TMX.Tile.new();
		end
	end
	layer:loadProperties(Node);
	return layer;
end
function JL.TMX.Layer:getTileGID(X, Y)
	return self[X][Y].gid
end
function JL.TMX.Layer:getTileset(X, Y)
	return self[X][Y].tileset
end
function JL.TMX.Layer:getTile(X, Y)
	return self[X][Y].tile
end
function JL.TMX.Layer:getTileXY(X, Y)
	return self[X][Y].tileX, self[X][Y].tileY;
end
function JL.TMX.Layer:drawToTilemap(tilemap, min_x, min_y, max_x, max_y)
	local x1 = min_x or 1;
	local y1 = min_y or 1;
	local x2 = math.min(self.width , tilemap.width );
	local y2 = math.min(self.height, tilemap.height);
	if max_x then x2 = math.min(x2, max_x) end
	if max_y then y2 = math.min(y2, max_y) end
	--[[	if self.tilesets[Tileset] ~= nil then
		self.tilesets[Tileset]:drawTile(X, Y, TileX, TileY);
		end]]
		--love.graphics.draw(self.image, self.quad_temp, self.twidth*X, self.theight*Y, 0, sx, sy);
	tilemap:bind();
	for ix = x1, x2 do 
		for iy = y1, y2 do
			local gid = self[ix][iy];
			--tile.tile = id;
			--tile.gid = gid;
			--tile.tileset = tileset_id;
			--if (tile ~= nil) then
				if (gid >= 0) then
					local id = gid - 1;
					local tileset_id = 1;
					for i = 1, #self.parent.tilesets_by_gid do
						local tileset = self.parent.tilesets_by_gid[i]
						if gid >= tileset.gid and i > tileset_id then
							id = gid - tileset.gid;
							tileset_id = i
						end
					end
					tilemap.tilesets[tileset_id]:drawTileExt(ix, iy, id);
					--tilemap.tilesets[tile.tileset]:drawTile(ix, iy, tile.tileX, tile.tileY);
					--tilemap:drawTile(tile.tileset, ix, iy, tile.tileX, tile.tileY);
				end
			--end
		end
	end
	tilemap:unbind();
end
function JL.TMX.Layer:drawToGrid(grid)
	local max_x = math.min(self.width, grid.width);
	local max_y = math.min(self.height, grid.height);
	for ix = 1, max_x do 
		for iy = 1, max_y do
			local gid = self[ix][iy];
			--tile.tile = id;
			--tile.gid = gid;
			--tile.tileset = tileset_id;
			--if (tile ~= nil) then
				if (gid >= 0) then
					local id = gid - 1;
					local tileset_id = 1;
					for i = 1, #self.parent.tilesets_by_gid do
						local tileset = self.parent.tilesets_by_gid[i]
						if gid >= tileset.gid and i > tileset_id then
							id = gid - tileset.gid;
							tileset_id = i
						end
					end
					grid:set(ix, iy, math.min(#grid.types, id + 2));
				end
			--end
		end
	end
end

function JL.TMX:getTileset(name)
	if type(name) == "string" then
		return self.tilesets[name];
	else
		return self.tilesets_by_gid[name]
	end
end
function JL.TMX:getTilesetCount()
	return #self.tilesets_by_gid;
end
function JL.TMX:getLayer(name)
	if type(name) == "string" then
		return self.layers[name];
	else 
		return self.layers_id[name];
	end
end
function JL.TMX:getLayerCount()
	return #self.layers_id;
end
function JL.TMX:getObjectgroupCount()
	return #self.objectgroups_id;
end
function JL.TMX:getObjectgroup(name)
	if type(name) == "string" then
		return self.objectgroups[name];
	else 
		return self.objectgroups_id[name];
	end
end
function JL.TMX:getWidth()
	return self.width * self.tile_width;
end
function JL.TMX:getHeight()
	return self.height * self.tile_height;
end
function JL.TMX:getTileWidth()
	return self.tile_width;
end
function JL.TMX:getTileHeight()
	return self.tile_height;
end
function JL.TMX:getWidthInTiles()
	return self.width;
end
function JL.TMX:getHeightInTiles()
	return self.height;
end
function JL.TMX.new(fileName)
	JL.timeReset();
	--JL.timedPrint("LOADING TMX WORLD");
	local xml = JL.XML.new(fileName);
	--JL.timedPrint("Loaded XML");
	local tmx = setmetatable({
		tilesets = {},
		tilesets_by_gid = {},
		layers = {},
		layers_id = {},
		objectgroups = {},
		objectgroups_id = {},
		tile_width = 1,
		width = 1,
		tile_height = 1,
		height = 1
	}, JL.TMX);
	--xml:print();
	local map = xml:getChildByName("map");
	tmx:loadProperties(map);
	local map_width = tonumber(map:getArgument("width"));
	local map_height = tonumber(map:getArgument("height"));
	local map_tilewidth = tonumber(map:getArgument("tilewidth"));
	local map_tileheight = tonumber(map:getArgument("tileheight"));
	tmx.tile_width = map_tilewidth;
	tmx.tile_height = map_tileheight;
	tmx.width = map_width;
	tmx.height = map_height;
	--JL.timedPrint("Loaded tmx properties");
	local tileset_count = map:count("tileset");
	for i = 1, tileset_count do
		local node_tileset = map:getChildByName("tileset", i);
		local tileset = JL.TMX.Tileset.new(node_tileset);
		tileset.gid = node_tileset:getArgument("firstgid") or tileset.gid;
		tileset.tile_width = node_tileset:getArgument("tilewidth") or tileset.tile_width;
		tileset.tile_height = node_tileset:getArgument("tileheight") or tileset.tile_height;
		tileset.spacing = node_tileset:getArgument("spacing") or tileset.spacing;
		tileset.margin = node_tileset:getArgument("margin") or tileset.margin;
		local image = node_tileset:getChildByName("image");
		if (image ~= nil) then
			--tileset.image = {};
			local source = image:getArgument("source"):sub(4, image:getArgument("source"):len())
			local image_width = tonumber(image:getArgument("width"));
			local image_height = tonumber(image:getArgument("height"));
			image_width = (image_width - 2*tileset.margin + tileset.spacing)/(tileset.tile_width + tileset.spacing)
			image_height = (image_height - 2*tileset.margin + tileset.spacing)/(tileset.tile_height + tileset.spacing)
			--[[for word in string.gmatch(source, "/*/") do 
				print(word)
			end]]
			--print(source)
			tileset.width = image_width;
			tileset.height = image_height;
			tileset.source = source;
		end
		local name = node_tileset:getArgument("name");
		tmx.tilesets[name] = tileset;
		table.insert(tmx.tilesets_by_gid, tileset);
	end
	--JL.timedPrint("Loaded tilesets");
	table.sort(tmx.tilesets_by_gid, function(a, b) return a.gid < b.gid end);
	--[[for i = 1, #tmx.tilesets_by_gid do
		print(tmx.tilesets_by_gid[i].gid)
	end]]
	--JL.timeReset();
	--JL.timedPrint("sorted tilesets");
	local time_copy = JL.timedPrint_time;
	local layer_count = map:count("layer");
	for i = 1, layer_count do
		local node_layer = map:getChildByName("layer", i);
		local node_data = node_layer:getChildByName("data");
		local layer_width = node_layer:getArgument("width")
		local layer_height = node_layer:getArgument("height")
		local layer = JL.TMX.Layer.new(layer_width, layer_height, tmx, node_layer);
		local name = node_layer:getArgument("name");
		--local data = node_data:content();
		local X = 1;
		local Y = 1;
		--JL.timedPrint("layer - start");
		--print(node_data:content());io.flush();
		local words = loadstring("return {" .. node_data:content() .. "}")();
		--for word in string.gmatch(node_data:content(), "%d+") do 
		for key, word in ipairs(words) do
			--local tile = JL.TMX.Tile.new();
			local gid = word;
			--local gid = tonumber(word);
			--[[local id = gid - 1;
			local tileset_id = 1;
			for i = 1, #tmx.tilesets_by_gid do
				local tileset = tmx.tilesets_by_gid[i]
				if gid >= tileset.gid and i > tileset_id then
					id = gid - tileset.gid;
					tileset_id = i
				end
			end
			tile.tile = id;
			tile.gid = gid;
			tile.tileset = tileset_id;
			--tile.tileX = math.fmod(id, 
			--print(X, Y);
			tile.tileX = math.fmod(id, tmx:getTileset(tile.tileset).width);
			tile.tileY = (id - tile.tileX)/tmx:getTileset(tile.tileset).width;]]
			layer[X][Y] = gid;
			X = X + 1;
			if (X > layer_width) then 
				X = 1;
				Y = Y + 1;
			end
		end
		--JL.timedPrint("layer - tiles");
		tmx.layers[name] = layer;
		layer.name = name;
		table.insert(tmx.layers_id, layer);
	end
	--JL.timeReset(time_copy);
	--JL.timedPrint("Loaded layers");
	local objectgroup_count = map:count("objectgroup");
	for i = 1, objectgroup_count do
		local objectgroup_node = map:getChild("objectgroup", i);
		local objectgroup = JL.TMX.Objectgroup.new(tmx, objectgroup_node);
		local object_count = objectgroup_node:count("object");
		local name = objectgroup_node:getArgument("name");
		for j = 1, object_count do
			local object_node = objectgroup_node:getChild("object", j);
			objectgroup:addObject(object_node);
		end
		tmx.objectgroups[name] = objectgroup;
		objectgroup.name = name;
		table.insert(tmx.objectgroups_id, objectgroup);
	end
	--JL.timedPrint("Loaded objects");
	return tmx;
end