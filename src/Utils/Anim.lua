JL.Anim = {};
JL.Anim.__index = JL.Anim;

function JL.Anim:update(dt)
	self._t = math.mod(self._t + dt, self.seconds);
	local t = self._t;
	if self.boomerang then t = math.abs(self._t-(self.seconds/2))*2 end
	self.angle = self.start.angle + self.ease.angle(t/self.seconds)*(self.stop.angle - self.start.angle);
	self.length = self.start.length + self.ease.length(t/self.seconds)*(self.stop.length - self.start.length);
end

function JL.Anim.new(Seconds, Start, Stop, EaseA, EaseL, Boomerang)
	local a = {
		seconds = Seconds,
		angle = 0,
		length = 0,
		_t = 0,
		boomerang = Boomerang,
		ease = {angle = EaseA or JL.Ease.None, length = EaseL or JL.Ease.None},
		start = {angle=0,length=0},
		stop = {angle=0,length=0},
	}
	if type(Start) == "table" then
		a.start.angle = Start.angle or Start[1]or 0;
		a.angle = a.start.angle;
		a.start.length = Start.length or Start[2] or 0;
		a.length = a.start.length;
	else a.start.angle = Start; end
	if type(Stop) == "table" then
		a.stop.angle = Stop.angle or Stop[1] or 0;
		a.stop.length = Stop.length or Stop[2] or 0;
	else a.stop.angle = Stop; end;
	setmetatable(a, JL.Anim);
	return a;
end
JL.Anim.meta = {}
function JL.Anim.meta.__call(t, ...)
	return JL.Anim.new(...);
end
setmetatable(JL.Anim,JL.Anim.meta);
