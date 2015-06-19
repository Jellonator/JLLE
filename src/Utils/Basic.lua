function JL.__inheritfunc(t, k)
	local value = rawget(t, k);
	if value ~= nil then
		return value;
	end
	local inherit = rawget(t, "__inherit");
	if inherit then
		for i = 1, #inherit do
			local v = inherit[i][k];
			if v then return v end;
		end
	end
end

function JL.inherit(t, ...)
	local arg = {...};
	
	local meta = getmetatable(t);
	local new_meta = meta;
	local insert_meta = false;
	setmetatable(t, nil);
	
	if t.__inherit == nil then
		t.__inherit = {}
		if meta ~= nil then
			insert_meta = true;
		end
		new_meta = {
			__index = JL.__inheritfunc
		};
	end

	for i,v in ipairs(arg) do
		--print(i, v);
		table.insert(t.__inherit, v);
	end
	
	if insert_meta then
		table.insert(t.__inherit, meta);
	end
	
	setmetatable(t, new_meta);
end

function JL.copy(from, to)
	local to = to or {};
	local meta = getmetatable(from);
	for k, v in pairs(from) do
		to[k] = v;
	end
	to = setmetatable(to, meta);
	return to;
end
function JL.empty(t)
	for k, v in pairs(t) do
		t[k] = nil;
	end
end
JL.timedPrint_time = love.timer.getTime()
function JL.timedPrint(string, Multiplier)
	local Multiplier = Multiplier or 1;
	print(string, math.floor(1000 * Multiplier * (love.timer.getTime() - JL.timedPrint_time)));io.flush();
	JL.timedPrint_time = love.timer.getTime()
end
function JL.timeReset(time)
	JL.timedPrint_time = time or love.timer.getTime()
end