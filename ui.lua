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


function UI:List(background_rect, name)
  local this = {}
  this.background_rect = background_rect
  this.elements = {}
  this.active_color = palette.blue
  
  function this:add_element(label)
    self.active_element = label
    table.insert(self.elements, label)
    local element_height = self.background_rect.height / #self.elements
    for i,v in ipairs(self.elements) do
      v.width = self.background_rect.width
      v.height = element_height
      v.y = self.background_rect.y + (i-1) * element_height
      v.x = self.background_rect.x
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
    local active = x < self.background_rect.x+self.background_rect.width and 
                   x > self.background_rect.x and
                   y < self.background_rect.y+self.background_rect.height and 
                   y > self.background_rect.y
    if not active then return end
    for i,v in ipairs(self.elements) do
      v.linecolor = self.background_rect.linecolor
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
  
  function this:draw()
    self.background_rect:draw()
    for _,v in ipairs(self.elements) do v:draw() end
    love.graphics.setLineWidth(3)
    self.active_element:draw()
    love.graphics.setLineWidth(2)
  end
  
  return this
end
