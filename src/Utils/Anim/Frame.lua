JL.Frame = {};
JL.Frame.__index = JL.Frame

function JL.Frame:getValue(t)
	return self.start + self.ease(t/self.seconds)*(self.stop - self.start);
end

function JL.Frame.new(Seconds, Start, Stop, Ease)
	local f = {
		seconds = Seconds,
		start = Start,
		stop = Stop,
		ease = Ease or JL.Ease.None,
	}
	setmetatable(f, JL.Frame);
	return f;
end

JL.Frame.meta = {}
function JL.Frame.meta.__call(t, ...)
	return JL.Frame.new(...);
end
setmetatable(JL.Frame,JL.Frame.meta);