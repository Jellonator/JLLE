JL.Collide.rect = {};--a little unconventional, but wynaut
JL.Collide.grid = {};
function JL.Collide.rect.rect(r1, r2, offX, offY)

end
function JL.Collide.rect.grid(e1, e2, offX, offY, _)
	local r = e1.mask;
    local g = e2.mask;
    local _ = _ or false;
	local dir = 0;
    local r = e1.mask;
    local g = e2.mask;
    for iX = math.floor((r:left() + e1.x + offX)/g.tileWidth)*g.tileWidth, math.floor((r:right() + e1.x + offX)/g.tileWidth)*g.tileWidth, g.tileWidth do
        for iY = math.floor((r:top() + e1.y + offY)/g.tileHeight)*g.tileHeight, math.floor((r:bottom() + e1.y + offY)/g.tileHeight)*g.tileHeight, g.tileHeight do
            if g.grid[(iX-(g.x+e2.x))/32+1] and g.grid[(iX-(g.x+e2.x))/32+1][(iY-(g.y+e2.y))/32+1]then
                return true;
            end
        end
    end
    return false;
end

function JL.Collide(e1,e2,offX,offY, sweep)
	local sweep = sweep or false;
	return false;
end
