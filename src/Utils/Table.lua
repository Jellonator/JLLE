function JL.Table.print(t, b)
	local b = b or 0;
	for k,v in pairs(t) do
		if type(v) == "table" then 
			print(string.rep("-", b)..k..":"); JL.Table.print(v, b + 1); 
		else
			print(string.rep("-", b)..k.." = "..v);
		end
	end
end
