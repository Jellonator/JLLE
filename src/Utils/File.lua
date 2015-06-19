JL.File = {}

function JL.File.load(File, Mode)
	local Mode = Mode or "r";
	if string.sub(File, 1, 1) ~= "/" then File = "/" .. File end
	return io.open(love.filesystem.getWorkingDirectory()..File, Mode);
end

JL.File.open = JL.File.load;