--JL.XML = {}
JL.XML.__index = JL.XML;
--parses arguments
function JL.XML.new(fileName)
	return JL.XML.load(fileName);
end

function JL.XML:_loadmetatable()
	setmetatable(self, JL.XML);
	local length = self:length();
	for i = 1, length do
		local child = self:getChildByID(i);
		JL.XML._loadmetatable(child);
	end
end

function JL.XML.load(fileName)
	--[[local file,err = io.open(fileName);
	if err ~= nil then print(err); return end;
	if file == nil then print("No such file") return; end
	local x = JL.XML.parse(file:read("*all"));
	file:close();]]
	local file,err = love.filesystem.newFile(fileName, "r");
	if err ~= nil then
		print(err);
		return
	end
	local x = JL.XML.parse(file:read());
	file:close();
	collectgarbage();
	--x = setmetatable(x, JL.XML);
	JL.XML._loadmetatable(x);
	return x;
end

function JL.XML:name()
	local name = self.label;
	if (name ~= nil) then return name end
	return "";
end

function JL.XML:getArgument(name)
	return self.xarg[name];
end

function JL.XML:content()
	--typically, the XML parser sets the first index in the table as the content. 
	--if the first index is a table, SURPRISE! there is no content.
	local value = self[1];
	if type(value) == "string" then
		return value;
	end
	return nil;
end

function JL.XML:length()
	local value = self[1];
	if type(value) == "string" then
		return #self - 1;
	else
		return #self
	end
end

function JL.XML:getChildren(name)
	local array = {}
	for i = 1, #self do
		local child = self[i];
		if type(child) == "table" then
			if child:name() == name then 
				array:insert(child);
			end
		end
	end
	return array;
end

function JL.XML:getChild(name, ID)
	if type(name) == "number" then 
		return self:getChildByID(name)
	else
		return self:getChildByName(name, ID);
	end
end

function JL.XML:getChildByName(name, ID)
	local ID = ID or 1;
	local count = 0;
	for i = 1, #self do
		local child = self[i];
		if type(child) == "table" then
			if child:name() == name then 
				count = count + 1
				if count == ID then
					return child
				end
			end
		end
	end
	return nil;
end

function JL.XML:count(name)
	local count = 0;
	for i = 1, #self do
		local child = self[i];
		if type(child) == "table" then
			if child:name() == name then 
				count = count + 1
			end
		end
	end
	return count;
end

function JL.XML:getChildByID(ID)
	local value = self[1];
	if type(value) == "string" then
		ID = ID + 1;
	end
	return self[ID];
end

function JL.XML:getFirstChild()
	--iterate through all children.
	--the first index might be a string if the tag has content in it.
	--the loop should end by at least 2. If there are no tags then the function returns nil
	for i = 1,#self do
		local value = self[1];
		if type(value) == "table" then
			return value;
		end
	end
	return nil;
end

function JL.XML:getLastChild()
	--iterate through all children.
	--the first index might be a string if the tag has content in it.
	--the loop should end by at least 2. If there are no tags then the function returns nil
	for i = #self,1,-1 do
		local value = self[1];
		if type(value) == "table" then
			return value;
		end
	end
	return nil;
end

function JL.XML.parseArgs(s)
	local arg = {}
	string.gsub(s, "([%w:]+)=([\"'])(.-)%2", function (w, _, a)arg[w] = a;end)
	for k,v in pairs(arg) do
		if tonumber(v) ~= nil then
			arg[k] = tonumber(v);
		end
	end
	return arg
end

function JL.XML.parse(s)
	local stack = {}
	local top = {}
	table.insert(stack, top)
	local ni,c,label,xarg, empty
	local i, j = 1, 1
	while true do
		ni,j,c,label,xarg, empty = string.find(s, "<(%/?)([%w:]+)(.-)(%/?)>", i)
		if not ni then break end
		local text = string.sub(s, i, ni-1)
		if not string.find(text, "^%s*$") then
			table.insert(top, text)
		end
		if empty == "/" then  -- empty element tag
			table.insert(top, {label=label, xarg=JL.XML.parseArgs(xarg), empty=1})
		elseif c == "" then   -- start tag
			top = {label=label, xarg=JL.XML.parseArgs(xarg)}
			table.insert(stack, top)   -- new level
		else  -- end tag
			local toclose = table.remove(stack)  -- remove top
			top = stack[#stack]
			if #stack < 1 then
				error("nothing to close with "..label)
			end
			if toclose.label ~= label then
				error("trying to close "..toclose.label.." with "..label)
			end
			table.insert(top, toclose)
		end
		i = j+1
	end
	local text = string.sub(s, i)
	if not string.find(text, "^%s*$") then
		table.insert(stack[#stack], text)
	end
	if #stack > 1 then
		error("unclosed "..stack[#stack].label)
	end
	return stack[1]
end

function JL.XML.print(xml, depth)
	local depth = depth or 0;
	--print(string.rep("| ",depth)..xml:name());
	local tabulated = string.rep(" |",depth);
	local content = xml:content();
	if content ~= nil then
		local length = string.len(content);
		content = string.gsub(content, "%s+", "");
		content = string.sub(content,1, math.min(string.len(content), 50));
		io.write(tabulated.."Content: ");
		io.write(content);
		if (length > 50) then io.write("..."); end
		print("");
	end
	local arguments = xml.xarg;
	if arguments ~= nil then
		local has_printed_first = false;
		for k,v in pairs(arguments) do
			if not has_printed_first then print(tabulated.."Arguments: ") end
			has_printed_first = true;
			print(tabulated.." "..k.."="..v);
		end
	end
	local length = xml:length();
	if (length > 0) then
		print(tabulated.."Children:")
		for i = 1, length do
			local child = xml:getChildByID(i);
			print(tabulated.." "..child:name());
			child:print(depth + 1);
		end
	end
end
JL.XML.meta = {}
function JL.XML.meta.__call(t, ...)
	--print("FOO")
	return t.new(...);
end
setmetatable(JL.XML, JL.XML.meta);
