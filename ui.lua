require 'palette'

UI = {}

function UI:Rect(x, y, width, height, fillcolor, linecolor)
  local this = {}
  this.x = x
  this.y = y
  this.width = width
  this.height = height
  
  if fillcolor then this.fillcolor = fillcolor
  else this.fillcolor = palette.grey end
  if linecolor then this.linecolor = linecolor
  else this.linecolor = palette.lightbrown end
  
  function this:draw_back()
    love.graphics.setColor(self.fillcolor.r, self.fillcolor.g, self.fillcolor.b)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
  end

  function this:draw_border()
    love.graphics.setColor(self.linecolor.r, self.linecolor.g, self.linecolor.b)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
  end
  
  function this:draw()
    self:draw_back()
    self:draw_border()
  end
  
  return this
end

function UI:Label(rect, text, text_color)
  local this = rect
  this.text = text
  if text_color then this.text_color = text_color
  else this.text_color = palette.bone end
  
  function this:draw()
    self:draw_back()
    love.graphics.setColor(self.text_color.r, self.text_color.g, self.text_color.b)
    love.graphics.print(self.text, self.x+4, self.y+4)
    self:draw_border()
  end
  
  return this
end


function UI:List(rect, name)
  local this =rect
  this.elements = {}
  this.active_color = palette.blue
  
  function this:add_element(label)
    self.active_element = label
    table.insert(self.elements, label)
    local element_height = self.height / #self.elements
    for i,v in ipairs(self.elements) do
      v.width = self.width
      v.height = element_height
      v.y = self.y + (i-1) * element_height
      v.x = self.x
    end
  end

  function this:get_element(name)
    for _,v in ipairs(self.elements) do
      if v.text == name then return v end
    end
    return nil
  end

  this.label = UI:Label(UI:Rect(), name)
  this:add_element(this.label)
  
  function this:update()
    --
  end

  function this:mousereleased(x, y, button)
    local active = x < self.x + self.width and 
                   x > self.x and
                   y < self.y + self.height and 
                   y > self.y
    if not active then return end
    for i,v in ipairs(self.elements) do
      v.linecolor = self.linecolor
    end
    for i,v in ipairs(self.elements) do
      if i > 1 and y < v.y + v.height then 
        self.active_element = v 
        v.linecolor = self.active_color
        break
      end
    end
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
    self.active_element:draw()
    love.graphics.setLineWidth(2)
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
    love.graphics.setColor(self.text_color.r, self.text_color.g, self.text_color.b)
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
    self.active = 
      x > self.x and
      x < self.x + self.width and
      y > self.y and
      y < self.y + self.height
    self.cursor_pos = #self.text
  end

  function this:keypressed(key)
    if not self.active then return end
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
    else
      self.cursor_pos = self.cursor_pos + 1
      table.insert(self.text, self.cursor_pos, key)
    end
    if self.cursor_pos < 0 then self.cursor_pos = 0 
    elseif self.cursor_pos > #self.text then self.cursor_pos = #self.text end
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
