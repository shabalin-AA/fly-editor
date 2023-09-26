require 'line'
require 'point'
require 'ui'
require 'rectangle'
require 'palette'
require 'points'


function love.load()
  love.graphics.setBackgroundColor(palette.grey.r, palette.grey.g, palette.grey.b)
  love.graphics.setNewFont(18)
  love.graphics.setLineWidth(2)
  obj_stack = {} 
  drawing = false
  dragging = nil
  current_color = palette.blue
  mode_list = UI:List(UI:Rect(10, 10, 110, 150), 'Mode')
    mode_list:add_element(UI:Label(UI:Rect(), 'Focus'))
    mode_list:add_element(UI:Label(UI:Rect(), 'Edit'))
    mode_list:add_element(UI:Label(UI:Rect(), 'Pen'))
    mode_list:add_element(UI:Label(UI:Rect(), 'Line'))
    mode_list:add_element(UI:Label(UI:Rect(), 'Rectangle'))
  color_list = UI:List(UI:Rect(10, 170, 110, 130), 'Color')
    color_list:add_element(UI:Label(UI:Rect(), 'red'))
    color_list:add_element(UI:Label(UI:Rect(), 'green'))
    color_list:add_element(UI:Label(UI:Rect(), 'blue'))
    color_list:add_element(UI:Label(UI:Rect(), 'lightbrown'))
  state_line = UI:Rect(0,0,0,0, palette.bone)
  function state_line:update()
    local font_h = love.graphics.getFont():getHeight() + 8
    state_line.y = love.graphics.getHeight() - font_h
    state_line.width = love.graphics.getWidth()
    state_line.height = font_h
  end
  chosen_obj = nil
end


function love.update(dt) 
  mode_list:update()
  color_list:update()
  state_line:update()
  if drawing then
    local last_obj = obj_stack[#obj_stack]
    if last_obj then 
      if last_obj.type == 'points' then
        table.insert(last_obj.p, Point())
      end
      local last_point = last_obj.p[#last_obj.p]
      last_point.x, last_point.y = love.mouse.getPosition() 
    end
  end
  if dragging then
    dragging.x, dragging.y = love.mouse.getPosition()
  end
end


function love.draw()
  for _,v in ipairs(obj_stack) do v:draw() end
  mode_list:draw()
  color_list:draw()
  state_line:draw()
  love.graphics.setColor(palette.grey.r, palette.grey.g, palette.grey.b)
  love.graphics.printf(
    string.format('%d; %d', love.mouse.getX(), love.mouse.getY()), 
    0, state_line.y+4, state_line.width-4, 'right'
  )
  if not chosen_obj then return end
  if chosen_obj.type == 'line' then 
    local A = chosen_obj.p[2].y - chosen_obj.p[1].y
    local B = -chosen_obj.p[2].x + chosen_obj.p[1].x
    local C = chosen_obj.p[1].y * B - chosen_obj.p[1].x * A
    local function gcd(a, b)
      if a == 0 then return b end
      return gcd(math.mod(b, a), a)
    end
    local gcd_ABC = gcd(A, gcd(B, C))
    A, B, C = A/gcd_ABC, B/gcd_ABC, C/gcd_ABC
    love.graphics.print(
      string.format('%s: %dx + %dy + %d = 0', chosen_obj.type, A, B, C),
      0 + 4, state_line.y + 4
    )
  end
end


function love.mousepressed(x, y, button)
  if button > 1 then return end
  if mode_list.active_element.text == 'Edit' then
    for _,v in ipairs(obj_stack) do
      for _,p in ipairs(v.p) do
        p.in_focus = true
        if p:same_with(x,y) then 
          dragging = p 
          chosen_obj = v
        end
      end
    end
    return
  end
  drawing = true
  local temp_obj = nil
  if mode_list.active_element.text == 'Line' then 
    temp_obj = Line(Point(x,y), Point(x,y))
  elseif mode_list.active_element.text == 'Rectangle' then 
    temp_obj = Rectangle(Point(x,y), Point(x,y))
  elseif mode_list.active_element.text == 'Focus' then 
    temp_obj = Rectangle(Point(x,y), Point(x,y))
  elseif mode_list.active_element.text == 'Pen' then
    temp_obj = Points()
    table.insert(temp_obj.p, Point(x,y))
  end
  if temp_obj then
    temp_obj.color = current_color
    if mode_list.active_element.text == 'Focus' then
      temp_obj.color = palette.lightblue
    end
    table.insert(obj_stack, temp_obj)
  end
end


function love.mousereleased(x, y, button)
  if button > 1 then return end
  dragging = nil
  drawing = false
  if mode_list.active_element.text == 'Focus' then
    local focus_rect = obj_stack[#obj_stack]
    for _,v in ipairs(obj_stack) do
      v.in_focus = true
      for _,p in ipairs(v.p) do
        p.in_focus = p.x > math.min(focus_rect.p[1].x, focus_rect.p[2].x) and
                     p.x < math.max(focus_rect.p[1].x, focus_rect.p[2].x) and
                     p.y > math.min(focus_rect.p[1].y, focus_rect.p[2].y) and
                     p.y < math.max(focus_rect.p[1].y, focus_rect.p[2].y)
        v.in_focus = v.in_focus and p.in_focus
      end
    end
    table.remove(obj_stack)
  end
  current_color = palette[color_list.active_element.text]
end


function deserialize(line)
  local words = {}
  for word in line:gmatch("%S+") do table.insert(words, word) end
  local p1 = Point(tonumber(words[1]), tonumber(words[2]))
  local p2 = Point(tonumber(words[3]), tonumber(words[4]))
  local color = {r=tonumber(words[5]), g=tonumber(words[6]), b=tonumber(words[7])}
  local obj = nil
  if words[8] == 'line' then obj = Line(p1, p2) end
  if words[8] == 'rect' then obj = Rectangle(p1, p2) end
  if obj then obj.color = color end
  return obj
end


function love.keypressed(key)
  if love.keyboard.isDown('lctrl') then
    if key == 'z' then table.remove(obj_stack) end
    local save_filename = 'save'
    if key == 's' then 
      love.filesystem.write(save_filename, '')
      for _,v in ipairs(obj_stack) do v:serialize(save_filename) end
    end
    if key == 'l' then
      for line in love.filesystem.lines(save_filename) do
        table.insert(obj_stack, deserialize(line))
      end
    end
  end
  if key == 'backspace' then
    local new_stack = {}
    for _,v in ipairs(obj_stack) do
      if not v.in_focus then table.insert(new_stack, v) end
    end
    obj_stack = new_stack
  end
end 
