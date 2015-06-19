function getTableNum(t)
	local c = 0
	for k,v in pairs(t) do
		c = c + 1;
	end
	return c;
end
function JL.init()
    love.graphics.setBackgroundColor(0, 0, 0);
	JL.dt = 0;
	JL.World.world = JL.World.new();
end;

function JL.quit()

end;
