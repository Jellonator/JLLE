--Math constants

JL.Math.PI = 3.1215926535;
JL.Math.BYTE = 1;
JL.Math.KILO = 2;
JL.Math.MEGA = 3;
JL.Math.GIGA = 4;
JL.Math.TERA = 5;
JL.Math.third = 1/60;

function JL.Math.hue2rgb(p, q, t)
	if t < 0   then t = t + 1 end
	if t > 1   then t = t - 1 end
	if t < 1/6 then return p + (q - p) * 6 * t end
	if t < 1/2 then return q end
	if t < 2/3 then return p + (q - p) * (2/3 - t) * 6 end
	return p
end

function JL.Math.hsl(h, s, l, a)
  local r, g, b = 1, 1, 1;
  local a = a or 1;
  if s == 0 then
    r, g, b = l, l, l -- achromatic
  else
    local q
    if l < 0.5 then q = l * (1 + s) else q = l + s - l * s end
    local p = 2 * l - q

    r = JL.Math.hue2rgb(p, q, h + 1/3)
    g = JL.Math.hue2rgb(p, q, h)
    b = JL.Math.hue2rgb(p, q, h - 1/3)
  end
  return r * 255, g * 255, b * 255, a * 255
end

function JL.Math.round(value)
	return value>=0 and math.floor(value+0.5) or math.ceil(value-0.5)
end

function JL.Math.mod(value, divisor)
	return value - math.floor(value/divisor) * divisor
end

--[[function JL.Math.angleTo(AngleFrom, AngleTo, value)
	value = JL.Math.clamp(value, 0, 1);
	local x1, y1 = JL.Math.angleXY(AngleFrom)
	local x2, y2 = JL.Math.angleXY(AngleTo)
	local fx, fy = value * x2 + (1-value) * x1, value * y2 + (1-value) * y1;
	return JL.Math.getAngle(0, 0, fx, fy);
end]]

function JL.Math.angleDifference(angle1, angle2)
	local a = angle2 - angle1
	a = JL.Math.mod(a + 180, 360) - 180
	return math.abs(a);
end

function JL.Math.angleTo(AngleFrom, AngleTo, Speed)
	while (AngleFrom < 0) do
		AngleFrom = 360 + AngleFrom
	end
	while (AngleFrom > 360) do
		AngleFrom = -360 + AngleFrom
	end
	while (AngleTo < 0) do
		AngleTo = 360 + AngleTo
	end
	while (AngleTo > 360) do
		AngleTo = -360 + AngleTo
	end
	local dis = AngleFrom - AngleTo;
	if math.abs(dis) <= Speed then
		return AngleTo;
	end
	local angle = AngleFrom;
	if (angle > AngleTo and angle < AngleTo + 180) or (angle > AngleTo - 360 and angle < AngleTo - 180) or (angle > AngleTo + 360 and angle < AngleTo + 540) then
		angle = angle - Speed--, AngleTo)
	else
		angle = angle + Speed--, AngleTo)
	end
	return angle;
end

function JL.Math.getDistance(x1, y1, x2, y2)
	local dy = y2-y1 
	local dx = x2-x1
	local len = math.sqrt(dx*dx + dy*dy)
	return len;
end

JL.Math.distance = JL.Math.getDistance;

function JL.Math.getAngle(x1, y1, x2, y2)
	local dy = y2-y1
	local dx = x2-x1
	local angle = math.deg(math.atan2(dy,dx));
	if (angle < 0) then
		angle = 360 + angle
	end
	return angle;
end

JL.Math.angle = JL.Math.getAngle

function JL.Math.angleXY(Angle, Speed, OffsetX, OffsetY)
	local OffsetX = OffsetX or 0;
	local OffsetY = OffsetY or 0;
	local Speed = Speed or 1;
	Angle = math.rad(Angle);
	local X = math.cos(Angle) * Speed + OffsetX;
	local Y = math.sin(Angle) * Speed + OffsetY;
	return X, Y;
end
--[[Returns a number limited between the minimum and the maximum. Providing nil will make n the min/max
--n:	the number to clamp
--min:	the smallest the number can be
--max: the largest the number can be
--]]
function JL.Math.clamp(n,min,max)
	min = min or n;
	max = max or n;
	return math.min(max,math.max(min,n));
end
--[[Returns a number between the minimum and the maximum
--min:	The lowest number that can be generated
--max:	The largest number that can be generated
--]]
function JL.Math.rand(min, max)
	return min+math.random()*(max-min);
end
JL.Math.random = JL.Math.rand;
--[[Returns the sign of the number.
--num:	The number to test.
--range:The range, if the number is within it it returns 0.
--]]
function JL.Math.getSign(num)
	return (num > 0) and 1 or ((num < 0) and -1 or 0)
end;
--[[Returns a data size
--num:	The number to convert
--from:	The type of the number
--to:	The type to convert to
--Note: 1 = bytes, 2 = kb, 3 = mb, 4 = gb, 5 = tb, etc.
--]]
function JL.Math.data(num, from, to)
	return num * math.pow(1024, from - to);
end
--[[Converts a boolean to a number
--bool:	bool to convert
--]]
function JL.Math.boolToNumber(bool)
	return bool and 1 or -1;
end
function JL.Math.HSV(h, s, v)
    if s <= 0 then return v,v,v end
    h, s, v = h/256*6, s/255, v/255
    local c = v*s
    local x = (1-math.abs((h%2)-1))*c
    local m,r,g,b = (v-c), 0,0,0
    if h < 1     then r,g,b = c,x,0
    elseif h < 2 then r,g,b = x,c,0
    elseif h < 3 then r,g,b = 0,c,x
    elseif h < 4 then r,g,b = 0,x,c
    elseif h < 5 then r,g,b = x,0,c
    else              r,g,b = c,0,x
    end return (r+m)*255,(g+m)*255,(b+m)*255
end
