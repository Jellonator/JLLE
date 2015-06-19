function JL.Mask.collide(Entity, Other, MoveX, MoveY, Sweep)
	local MoveX = MoveX or 0;
	local MoveY = MoveY or 0;
	local Sweep = Sweep or false;
	if Entity == nil or Other == nil then
		--print("Entity is nil!")
		local x, y = 0,0;
		if Entity ~= nil then
			x = Entity.x;
			y = Entity.y;
		end
		return false, x, y;
	end
	if Entity == Other then
		return false, Entity.x, Entity.y;
	end
	if Entity.mask == nil or Other.mask == nil then
		--print("Mask is nil!")
		return false, Entity.x, Entity.y;
	end
	local mask_a_x = Entity.mask.x;
	local mask_a_y = Entity.mask.y;
	local mask_b_x = Other.mask.x;
	local mask_b_y = Other.mask.y;
	Entity.mask.x = Entity.mask.x + Entity.x;
	Entity.mask.y = Entity.mask.y + Entity.y;
	Other.mask.x = Other.mask.x + Other.x;
	Other.mask.y = Other.mask.y + Other.y;
	local collided = false;
	local valid = false;
	local X = Entity.x + MoveX;
	local Y = Entity.y + MoveY;
	--print(Other.mask:type())
	if Entity.mask:type() == "box" and Other.mask:type() == "box" then
		valid = true;
		local c, x, y = JL.Mask.Box.collideBox(Entity.mask, Other.mask, MoveX, MoveY, Sweep)
		X = x;
		Y = y;
		if c then collided = c end
	elseif Entity.mask:type() == "box" and Other.mask:type() == "grid" then
		valid = true;
		local c, x, y = JL.Mask.Box.collideGrid(Entity.mask, Other.mask, MoveX, MoveY, Sweep)
		X = x;
		Y = y;
		if c then collided = c end
	end
	if not valid then
		--print("Not valid!")
		--return false 
	end
	if X == nil or Y == nil then
		X = Entity.x;
		Y = Entity.y;
	end
	Entity.mask.x = mask_a_x;
	Entity.mask.y = mask_a_y;
	Other.mask.x = mask_b_x;
	Other.mask.y = mask_b_y;
	X = X - Entity.mask.x
	Y = Y - Entity.mask.y
	return collided, X, Y;
end