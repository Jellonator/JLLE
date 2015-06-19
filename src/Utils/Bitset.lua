JL.Util.Bitset = {};

JL.Util.Bitset.__index = JL.Util.Bitset;

do	--Initialization functions
	function JL.Util.Bitset.new(count)
		local b = {};
		for i = 1, count, 1 do
			b[i] = false;
		end
		setmetatable(b,JL.Util.Biset);
		return b;
	end
end

do --Get/Set Functions
	function JL.Util.Bitset:set(k, v)
		self[k] = v;
	end

	function JL.Util.Bitset:get(k)
		return self[k];
	end
end

--metatables
JL.Util.Bitset.meta = {}
function JL.Util.Bitset.meta.__call(t,...)
	return t.new(...);
end
setmetatable(JL.Util.Bitset, JL.Util.Bitset.meta);
