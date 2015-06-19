JL.Util.Line = {};

JL.Util.Line.__index = JL.Util.Line;

function JL.Util.point(X, Y)
	return {x=X, y=Y};
end

function JL.Util.Line.new(x1,y1,x2,y2)
	local l = {};
	if (x2 == nil) then
		l = {x1,y1};
	else
		l = {JL.Util.point(x1,y1),JL.Util.point(x2,y2)};
	end
	setmetatable(l, JL.Util.Line);
	return l;
end

function JL.Util.Line.collide(A, B)
	--Creating variables for simplicity
	local x1 = A[1].x; local x2 = A[2].x; local x3 = B[1].x; local x4 = B[2].x;
	local y1 = A[1].y; local y2 = A[2].y; local y3 = B[1].y; local y4 = B[2].y;
	return JL.Util.Line.collidePoints(x1, y1, x2, y2, x3, y3, x4, y4);
end

function JL.Util.Line.collidePoints(x1, y1, x2, y2, x3, y3, x4, y4)
	local d = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4);
	--Parallel
	if (d == 0) then return false end;
	-- Get the x and y
	local pre = (x1*y2 - y1*x2); local post = (x3*y4 - y3*x4);
	local x = (pre * (x3 - x4) - (x1 - x2) * post) / d;
	local y = (pre * (y3 - y4) - (y1 - y2) * post) / d;
	local col = {x=x,y=y};
	--Doesn't collide, but they will intersect eventually
	if (x < math.min(x1, x2) or x > math.max(x1, x2) or x < math.min(x3, x4) or x > math.max(x3, x4)) then return false, col end;
	if (y < math.min(y1, y2) or y > math.max(y1, y2) or y < math.min(y3, y4) or y > math.max(y3, y4)) then return false, col end;
	--It does intersect
	return true, col;
end

function JL.Util.Line.collideRectPoints(x1, y1, x2, y2, x, y, w, h)
end

function JL.Util.Line.collideRect(Line, Rect)

end

function JL.Util.Line._collideGrid(Line, Grid, ix, iy)
ix = ix + 1;
iy = iy + 1;
	if (Grid[ix][iy] > 0) then
		local r = false;
		local c, p;
		local x1 = Grid.x+(ix-1)*grid.twidth;
		local x2 = Grid.x+(ix)*grid.twidth;
		local y1 = Grid.y+(iy-1)*grid.twidth;
		local y2 = Grid.y+(iy)*grid.twidth;
		--if (Line[1].x >= x1 and Line[1].x <= x2 and Line[1].y >= y1 and Line[1].y <= y2) then return true, {x=Line[1].x, y=Line[1].y}; end
		--love.graphics.setColor(100,0,0);
		--love.graphics.rectangle("line",x1,y1,x2-x1,y2-y1);
		local p = false;
		local d = -1;
		local td = false;
		local tp = false;
		c, tp = Line.collidePoints(Line[1].x,Line[1].y,Line[2].x,Line[2].y,x1, y1, x2, y1); if c then --TOP
			r = c;
			td = (tp.x-Line[1].x)^2 + (tp.y-Line[1].y)^2;
			if td < d or d == -1 then p = tp; d = td; end
		end
		c, tp = Line.collidePoints(Line[1].x,Line[1].y,Line[2].x,Line[2].y,x1, y2, x2, y2); if c then --BOTTOM
			r = c;
			td = (tp.x-Line[1].x)^2 + (tp.y-Line[1].y)^2;
			if td < d or d == -1 then p = tp; d = td; end
		end
		c, tp = Line.collidePoints(Line[1].x,Line[1].y,Line[2].x,Line[2].y,x1, y1, x1, y2); if c then --LEFT
			r = c;
			td = (tp.x-Line[1].x)^2 + (tp.y-Line[1].y)^2;
			if td < d or d == -1 then p = tp; d = td; end
		end
		c, tp = Line.collidePoints(Line[1].x,Line[1].y,Line[2].x,Line[2].y,x2, y1, x2, y2); if c then --RIGHT
			r = c;
			td = (tp.x-Line[1].x)^2 + (tp.y-Line[1].y)^2;
			if td < d or d == -1 then p = tp; d = td; end
		end
		return r, p, d;
	end
end

function JL.Util.Line.collideGrid(Line, Grid)
	local x1, y1, x2, y2 = Line[1].x-Grid.x, Line[1].y-Grid.x, Line[2].x-Grid.x, Line[2].y-Grid.x;
	--love.graphics.Line(x1,y1,x2,y2);
	local c = 0;
	local xm = (x2 - x1);
	local ym = (y2 - y1);
	local m, b = 0,0;
	if (math.abs(xm) > math.abs(ym)) then
		m = ym/xm;
		b = (y1 - m*x1)/Grid.theight;
	else
		m = xm/ym;
		b = (x1 - m*y1)/Grid.twidth;
	end
	x1 = math.max(0,math.min(Grid.width-1,math.floor(x1/Grid.twidth)));
	x2 = math.max(0,math.min(Grid.width-1,math.floor(x2/Grid.twidth)));
	y1 = math.max(0,math.min(Grid.height-1,math.floor(y1/Grid.theight)));
	y2 = math.max(0,math.min(Grid.height-1,math.floor(y2/Grid.theight)));
	if (Grid[math.max(1,math.min(Grid.width,x1+1))][math.max(1,math.min(Grid.width,y1+1))] > 0) then return true, {x=Line[1].x, y=Line[1].y}; end
	local rp = false;
	local rd = -1;
	local r = false;
	if (math.abs(xm) > math.abs(ym)) then
		xm = (x1 <= x2) and 1 or -1;
		for ix = x1, x2, xm do
			local ay = m*ix+b;
			local by = m*ix+b+m;
			ym = (ay <= by) and 1 or -1;
			for iy = math.max(0,math.min(Grid.height-1,math.floor(ay))),math.max(0,math.min(Grid.height-1,math.floor(by))),ym do
				local c, p, d = JL.Util.Line._collideGrid(Line, Grid, ix, iy);
				if c then 
					r = true;
					if (d < rd or rd == -1) then rd = d; rp = p; end
				end
			end
			if r then return r, rp; end 
		end
	else
		ym = (y1 <= y2) and 1 or -1;
		for iy = y1, y2, ym do
			local ax = m*iy+b;
			local bx = m*iy+b+m;
			xm = (ax <= bx) and 1 or -1;
			for ix = math.max(0,math.min(Grid.width-1,math.floor(ax))),math.max(0,math.min(Grid.width-1,math.floor(bx))),xm do
				local c, p, d = JL.Util.Line._collideGrid(Line, Grid, ix, iy);
				if c then 
					r = true;
					if (d < rd or rd == -1) then rd = d; rp = p; end
				end
			end
			if r then return r, rp; end
		end
	end
	return r, rp;
end

function JL.Util.Line:render()
	love.graphics.line(self[1].x,self[1].y,self[2].x,self[2].y);
end

JL.Util.Line.meta = {};
function JL.Util.Line.meta.__call(t,...)
	return t.new(...);
end
setmetatable(JL.Util.Line, JL.Util.Line.meta);
