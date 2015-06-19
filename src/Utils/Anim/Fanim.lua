JL.FAnim = {};
JL.FAnim.__index = function(t,k)
	if JL.FAnim[k] then return JL.FAnim[k] end;
	if JL.Anim[k] then return JL.Anim[k] end;
	return nil;
end

function JL.FAnim:addAngle(S, Start, Stop, Ease)
	if (type(S) == "table") then
		table.insert(self.frames.angle, S);
		self._angle.s = self._angle.s + S.seconds;
	else
		table.insert(self.frames.angle, JL.Frame.new(S, Start, Stop, Ease));
		self._angle.s = self._angle.s + S;
		--print(self._angle.s)
	end
end
function JL.FAnim:addLength(S, Start, Stop, Ease)
	if (type(S) == "table") then
		table.insert(self.frames.length, S);
		self._length.s = self._length.s + S.seconds;
	else
		table.insert(self.frames.length, JL.Frame.new(S, Start, Stop, Ease));
		self._length.s = self._length.s + S;
		--print(self._length.s)
	end
end
function JL.FAnim:addFrame(S, Start, Stop, Ease) self:addAngle(S, Start, Stop, Ease); self:addLength(S, Start, Stop, Ease); end;

function JL.FAnim:update(dt)
	if self._angle.s > 0 then
		self._angle.t = self._angle.t + dt;
		if self._angle.t > self._angle.s then self._angle.t = math.mod(self._angle.t,self._angle.s); self._angle.c = 0; self._angle.p = 0; end
		while true do
			if self._angle.t >= self._angle.p then
				self._angle.c = math.min(self._angle.c + 1, #self.frames.angle);
				self._angle.p = self._angle.p + self.frames.angle[self._angle.c].seconds;
			else
				self.angle = self.frames.angle[self._angle.c]:getValue(self.frames.angle[self._angle.c].seconds-(self._angle.p-self._angle.t));
				break;
			end
		end
	end
	if self._length.s > 0 then
		self._length.t = self._length.t + dt;
		if self._length.t > self._length.s then self._length.t = math.mod(self._length.t,self._length.s); self._length.c = 0; self._length.p = 0; end
		while true do
			if self._length.t >= self._length.p then
				self._length.c = math.min(self._length.c + 1, #self.frames.length);
				self._length.p = self._length.p + self.frames.length[self._length.c].seconds;
			else
				self.length = self.frames.length[self._length.c]:getValue(self.frames.length[self._length.c].seconds-(self._length.p-self._length.t));
				break;
			end
		end
	end
end

function JL.FAnim.new(Angle, Length)
	local a = {
		frames = {
			angle = {},
			length = {},
		},
		angle = Angle or 0,
		length = Length or 0,
		--Seconds, Current, Time, Passed
		_angle = { s = 0, c = 0, t = 0, p = 0 },
		_length = { s = 0, c = 0, t = 0, p = 0 },
	}
	setmetatable(a, JL.FAnim);
	return a;
end
JL.Anim.newF = JL.FAnim.new;
JL.FAnim.meta = {}
function JL.FAnim.meta.__call(t, ...)
	return JL.FAnim.new(...);
end
setmetatable(JL.FAnim,JL.FAnim.meta);
