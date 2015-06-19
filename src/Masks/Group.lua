JL.Mask.Group = {}
JL.Mask.Group.__index = JL.Mask.Group;

function JL.Mask.Group.new()
	local group = setmetatable({
		masks = {},
		entities = {}
	}, JL.Mask.Group);
end

JL.Mask.Group.meta = {};
function JL.Mask.Group.meta.__call(t,...)
	return JL.Mask.Group.new(..);
end
setmetatable(JL.Mask.Group, JL.Mask.Group.meta);