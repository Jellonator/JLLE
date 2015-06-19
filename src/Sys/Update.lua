function JL.update(dt)
	--love.timer.sleep(0.1);
	--dt = dt;
	--local dt = dt or love.timer.getDelta()
	if dt > 1/10 then dt = 1/10; end
	if dt < 0 then dt = 0; end
	--love.graphics.scale(2,1);
    --JL.World.world.physics:update(dt);
	--  JL.dt = dt;
	

	JL.world:OnUpdate(dt)
end;
