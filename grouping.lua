function Group(elements, name)
	local this = {}
	
	this.elements = elements or {}
	this.name = name or 'group'
	
	function this:add_elements(to_add)
		for _,v in ipairs(to_add) do
			table.insert(self.elements, v)
		end
	end
	
	return this
end


--