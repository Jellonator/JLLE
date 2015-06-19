JL.Ease = {};
do
local PI = math.pi
local PI2 = math.pi/2
local B1 = 1/2.75;
local B2 = 2/2.75;
local B3 = 1.5/2.75;
local B4 = 2.5/2.75;
local B5 = 2.25/2.75;
local B6 = 2.625/2.75;

function JL.Ease.None(t)return t; end

do--Sqrt
	JL.Ease.Sqrt = {};
	function JL.Ease.Sqrt.Out(t)
		return math.sqrt(t);
	end
	function JL.Ease.Sqrt.In(t)
		return 1 - JL.Ease.Sqrt.Out(1-t);
	end
	function JL.Ease.Sqrt.InOut(t)
		return t <= .5 and JL.Ease.Sqrt.In(t * 2) / 2 or JL.Ease.Sqrt.Out(t * 2 - 1) / 2 + .5;
	end
end

do--Quad
	JL.Ease.Quad = {};
	function JL.Ease.Quad.In(t)
		return t * t;
	end

	function JL.Ease.Quad.Out(t)
		return 1 - JL.Ease.Quad.In(1 - t);
	end

	function JL.Ease.Quad.InOut(t)
		return t <= .5 and JL.Ease.Quad.In(t * 2) / 2 or JL.Ease.Quad.Out(t * 2 - 1) / 2 + .5;
	end
end

do--Cube
	JL.Ease.Cube = {};
	function JL.Ease.Cube.In(t)
		return t * t * t;
	end

	function JL.Ease.Cube.Out(t)
		return 1 - JL.Ease.Cube.In(1 - t);
	end

	function JL.Ease.Cube.InOut(t)
		return t <= .5 and JL.Ease.Cube.In(t * 2) / 2 or JL.Ease.Cube.Out(t * 2 - 1) / 2 + .5
	end
end

do--Circle
	JL.Ease.Circle = {};
	function JL.Ease.Circle.In(t)
		return -(math.sqrt(1 - t * t) - 1);
	end

	function JL.Ease.Circle.Out(t)
		return math.sqrt(1 - (t - 1) * (t - 1));
	end

	function JL.Ease.Circle.InOut(t)
		return t <= .5 and JL.Ease.Circle.In(t * 2) / 2 or JL.Ease.Circle.Out(t * 2 - 1) / 2 + .5
	end
end

do--Sine
	JL.Ease.Sine = {};
	function JL.Ease.Sine.In(t)
		return -math.cos(PI2 * t) + 1;
	end

	function JL.Ease.Sine.Out(t)
		return math.sin(PI2 * t);
	end

	function JL.Ease.Sine.InOut(t)
		return -math.cos(PI * t) / 2 + .5;
	end
end

do--Bounce
	JL.Ease.Bounce = {};
	function JL.Ease.Bounce.In(t)
		t = 1 - t;
		if (t < B1) then return 1 - 7.5625 * t * t;
		elseif (t < B2) then return 1 - (7.5625 * (t - B3) * (t - B3) + .75);
		elseif (t < B4) then return 1 - (7.5625 * (t - B5) * (t - B5) + .9375);
		else return 1 - (7.5625 * (t - B6) * (t - B6) + .984375);end
	end

	function JL.Ease.Bounce.Out(t)
		return 1 - JL.Ease.Bounce.In(1 - t);
	end

	function JL.Ease.Bounce.InOut(t)
		return t <= .5 and JL.Ease.Bounce.In(t * 2) / 2 or JL.Ease.Bounce.Out(t * 2 - 1) / 2 + .5
	end
end

end
