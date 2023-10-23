require 'palette'

UI = {}

function UI:Rect(x, y, width, height, fillcolor, linecolor)
  local this = {}
  this.x = x
  this.y = y
  this.width = width
  this.height = height
	
	function this:focused()
		local x,y = love.mouse.getPosition()
		return x < self.x + self.width and 
           x > self.x and
           y < self.y + self.height and 
           y > self.y
  end

  this.fillcolor = fillcolor or palette.grey
  this.linecolor = linecolor or palette.lightbrown
  
  function this:draw_back()
    setColor(self.fillcolor)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
  end

  function this:draw_border()
    setColor(self.linecolor)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
  end
  
  function this:draw()
    self:draw_back()
    self:draw_border()
  end
	
	function this:update() end
	function this:mousepressed(x, y, button) end
	function this:mousereleased(x, y, button) end
	function this:keypressed(key) end
  
  return this
end

function UI:Label(rect, text, text_color)
  local this = rect
  this.text = text
  this.text_color = text_color or palette.bone
  
  function this:draw()
    self:draw_back()
    setColor(self.text_color)
    love.graphics.printf(self.text, self.x, self.y+2, self.width, 'center')
    self:draw_border()
  end
  
  return this
end

function UI:List(header_label)
  local this = UI:Rect()
	this.x = header_label.x
	this.y = header_label.y
	this.width = header_label.width
	this.height = header_label.height
	
	this.header = header_label
  this.elements = {}
	table.insert(this.elements, header_label)
	
  this.active_color = palette.blue
  
  function this:add_element(label)
    self.active_element = label
    label.width = self.header.width
    label.height = self.header.height
    label.y = self.header.y + self.header.height * #self.elements
    label.x = self.header.x
    table.insert(self.elements, label)
		self.height = self.height + label.height
  end

  function this:get_element(name)
    for _,v in ipairs(self.elements) do
      if v.text == name then return v end
    end
    return nil
  end
	
  function this:mousereleased(x, y, button)
    if not self:focused() then return false end
    for i,v in ipairs(self.elements) do
      v.linecolor = self.linecolor
    end
    for i,v in ipairs(self.elements) do
      if i > 1 and y < v.y + v.height then 
        self.active_element = v 
        v.linecolor = self.active_color
				return v, i
      end
    end
		return true
  end

  function this:set_active(name)
    for _,v in ipairs(self.elements) do
      if v.text == name then 
        self.active_element = v
        v.linecolor = self.active_color
      else 
        v.linecolor = palette.lightbrown
      end
    end
  end

  this.draw_rect = this.draw
  
  function this:draw()
    self:draw_rect()
    for _,v in ipairs(self.elements) do v:draw() end
    love.graphics.setLineWidth(3)
    if self.active_element then self.active_element:draw() end
    love.graphics.setLineWidth(2)
  end
  
  return this
end

function UI:FoldList(list)
	local this = list
	this.folded = true
	
	function this:update()
    if self.folded and self.elements[1]:focused() then
			self.folded = false
		end
		if not self.folded and not self:focused() then
			self.folded = true
		end
	end
	
	this.draw_list = this.draw
	
	function this:draw()
		if self.folded then self.elements[1]:draw()
		else self:draw_list() end
	end
	
	return this
end

function UI:TextInput(rect, text_color) 
  local this = rect
  this.text = {}
  this.cursor_pos = 0
  this.text_color = text_color
  this.active = false
  this.active_color = palette.blue
  this.common_color = rect.linecolor

  this.draw_rect = this.draw

  function this:draw()
  	local align = 'right'
    if self.active then 
      self.linecolor = self.active_color
      love.graphics.setLineWidth(3)
      align = 'left'
    else 
      self.linecolor = self.common_color 
      love.graphics.setLineWidth(2)
    end
    self:draw_rect()
    setColor(self.text_color)
    love.graphics.printf(table.concat(self.text), self.x+2, self.y+2, self.width-4, align)
    -- cursor
    if self.active then
      love.graphics.setLineWidth(1)
      love.graphics.setColor(0,0,0)
      local cursor_pos_x = self.x+2 + love.graphics.getFont():getWidth(string.sub(table.concat(self.text), 1, self.cursor_pos))
      love.graphics.line(cursor_pos_x, self.y+3, cursor_pos_x, self.y-3 + self.height)
      love.graphics.setLineWidth(2)
    end
  end

  function this:mousereleased(x, y, button)
    self.active = self:focused()
		if not self:focused() then return false end
    self.cursor_pos = #self.text
		return true
  end

  function this:keypressed(key)
    if not self.active then return false end
    if key == 'backspace' then
      table.remove(self.text, self.cursor_pos)
      self.cursor_pos = self.cursor_pos - 1
    elseif key == 'return' then
    	self.active = false
    elseif key == 'delete' then
      self.text = {}
      self.cursor_pos = 0
    elseif key == 'up'    then self.cursor_pos = 0
    elseif key == 'down'  then self.cursor_pos = #self.text
    elseif key == 'right' then self.cursor_pos = self.cursor_pos + 1
    elseif key == 'left'  then self.cursor_pos = self.cursor_pos - 1
		elseif string.len(key) == 1 then
      self.cursor_pos = self.cursor_pos + 1
      table.insert(self.text, self.cursor_pos, key)
    end
    if self.cursor_pos < 0 then self.cursor_pos = 0 
    elseif self.cursor_pos > #self.text then self.cursor_pos = #self.text end
		return true
  end

  function this:set_text(str)
  	self.text = {}
  	for i=1, string.len(str) do
  		table.insert(self.text, string.sub(str, i, i))
  	end
  	self.cursor_pos = #self.text
  end
  
  return this
end

function UI:Button(label, active_color)
	local this = label
	
	this.active_color = active_color or palette.blue
	this.common_color = label.linecolor
	this.active = false
	
	function this:mousepressed(x, y, button, event, event_args)
		if not self:focused() then return false end
		if event then event(event_args) end
		self.active = true
		return true
	end
	
	function this:mousereleased(x, y, button, event, event_args)
		if not self:focused() then return false end
		if event then event(event_args) end
		self.active = false
		return true
	end
	
	this.draw_label = this.draw
	
	function this:draw()
		if self.active then 
			love.graphics.setLineWidth(3)
			self.linecolor = self.active_color
		else
			love.graphics.setLineWidth(2)
			self.linecolor = self.common_color
		end
		self:draw_label()
	end
	
	return this
end

function UI:Window(rect, title)
	local this = {}
	
	this.title = title or 'window'
	this.active = false
	
	local close_button = UI:Button(
		UI:Label(
			UI:Rect(
				rect.x+rect.width-26, rect.y+2, 
				24, 24, 
				{r=1, g=0, b=0}, 
				{r=1, g=0, b=0}
			), 
			'X', 
			palette.bone
		)
	)
	close_button.active_color = {r=1, g=0, b=0}
	this.elements = {rect, close_button}
	
	function this:add_element(el)
		el.x = el.x + self.elements[1].x
		el.y = el.y + self.elements[1].y
		table.insert(self.elements, el)
		return #self.elements
	end
	
	function this:update()
		if not self.active then return end
		for _,v in ipairs(self.elements) do
			v:update()
		end
	end
	
	function this:draw()
		if not self.active then return end
		for _,v in ipairs(self.elements) do
			v:draw()
		end
		setColor(palette.bone)
		love.graphics.printf(self.title, self.elements[1].x, self.elements[1].y+4, self.elements[1].width, 'center')
	end
	
	function this:mousepressed(x, y, button, onclose_event, onclose_event_args)
		if not self.active then return false end
		if not self.elements[1]:focused() then return false end
		if self.elements[2]:mousepressed(x, y, button, 
			function(args) 
				args.win.active = false 
				for _,v in pairs(args.win.elements) do
					v.active = false
				end
			end, 
			{win = self}
		) then onclose_event(onclose_event_args) end
		for _,v in ipairs(self.elements) do
			v:mousepressed(x, y, button)
		end
		return true
	end
	
	function this:mousereleased(x, y, button)
		if not self.active then return false end
		if not self.elements[1]:focused() then return false end
		for _,v in ipairs(self.elements) do
			v:mousereleased(x, y, button)
		end
		return true
	end
	
	function this:keypressed(key)
		if not self.active then return false end
		for _,v in ipairs(self.elements) do
			v:keypressed(key)
		end
		return true
	end
	
	return this
end
