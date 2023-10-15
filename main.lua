require 'line'
require 'point'
require 'ui'
require 'rectangle'
require 'palette'
require 'points'
require 'serialize'
require 'state_line'
require 'grouping'
require 'popup_windows'


function focus_all(arr)
	for _,v in ipairs(arr) do
		for _,p in ipairs(v.p) do p.in_focus = true end
		v.in_focus = true
	end
end

function unfocus_all(arr)
	for _,v in ipairs(arr) do
		for _,p in ipairs(v.p) do p.in_focus = false end
		v.in_focus = false
	end
end


function love.load()
  love.graphics.setBackgroundColor(palette.grey.r, palette.grey.g, palette.grey.b)
  love.graphics.setNewFont(18)
  love.graphics.setLineWidth(2)
  obj_stack = {} 
  drawing = false
  prev_mouse_pos = {0, 0}
  current_color = palette.blue
  mode_list = UI:FoldList(UI:List(UI:Label(UI:Rect(10, 10, 110, 26), 'Mode')))
    mode_list:add_element(UI:Label(UI:Rect(), 'Focus'))
    mode_list:add_element(UI:Label(UI:Rect(), 'Edit'))
    mode_list:add_element(UI:Label(UI:Rect(), 'Pen'))
    mode_list:add_element(UI:Label(UI:Rect(), 'Line'))
    mode_list:add_element(UI:Label(UI:Rect(), 'Rectangle'))
  color_list = UI:FoldList(UI:List(UI:Label(UI:Rect(130, 10, 110, 26), 'Color')))
    color_list:add_element(UI:Label(UI:Rect(), 'red'))
    color_list:add_element(UI:Label(UI:Rect(), 'green'))
    color_list:add_element(UI:Label(UI:Rect(), 'blue'))
    color_list:add_element(UI:Label(UI:Rect(), 'lightbrown'))
  transform_button  = UI:Button(UI:Label(UI:Rect(250, 10, 110, 26), 'Transform'))
  scale_button 			= UI:Button(UI:Label(UI:Rect(370, 10, 110, 26), 'Scale'))
  mirror_button 		= UI:Button(UI:Label(UI:Rect(490, 10, 110, 26), 'Mirror'))
  rotate_button 		= UI:Button(UI:Label(UI:Rect(610, 10, 110, 26), 'Rotate'))
  state_line:load()
	groups = {}
	group_list = UI:FoldList(UI:List(UI:Label(UI:Rect(love.graphics.getWidth() - 120, 10, 110, 26), 'Groups')))
end


function love.update(dt)
  mode_list:update()
  color_list:update()
	group_list:update()
  state_line:update()
  if drawing then
    local last_obj = obj_stack[#obj_stack]
    if last_obj then 
      if last_obj.type == 'Points' then
        table.insert(last_obj.p, Point())
      end
      local last_point = last_obj.p[#last_obj.p]
      last_point.x, last_point.y = love.mouse.getPosition() 
    end
  end
  if mode_list.active_element.text == 'Edit' and love.mouse.isDown(1) then
    for _,obj in ipairs(obj_stack) do
      for _,p in ipairs(obj.p) do
        if p.in_focus then 
          p.x = p.x + love.mouse.getX() - prev_mouse_pos[1]
          p.y = p.y + love.mouse.getY() - prev_mouse_pos[2]
          state_line.chosen_obj = obj
        end
      end
    end
  end
	transform_window:update()
	transform_window.m = tonumber(table.concat(transform_window.m_in.text)) or 0
	transform_window.n = tonumber(table.concat(transform_window.n_in.text)) or 0
  prev_mouse_pos = {love.mouse.getX(), love.mouse.getY()}
end


function love.draw()
  for _,v in ipairs(obj_stack) do v:draw() end
  mode_list:draw()
  color_list:draw()

	transform_button:draw()
	scale_button:draw()
	mirror_button:draw()
	rotate_button:draw()
	
	group_list:draw()
  state_line:draw()
	transform_window:draw()
end


local function activate_win_event(args)
	transform_window.active = false
	scale_window.active = false
	mirror_window.active = false
	rotate_window.active = false
	args.win.active = true
end

function love.mousepressed(x, y, button)
  if button > 1 then return end
  if y > state_line.y then return end
	transform_button:mousepressed(x, y, button, activate_win_event,
		{win = transform_window}
	)
	scale_button:mousepressed(x, y, button, activate_win_event,
		{}
	)
	mirror_button:mousepressed(x, y, button, activate_win_event,
		{}
	)
	rotate_button:mousepressed(x, y, button, activate_win_event,
		{}
	)
  if y < mode_list.y + mode_list.header.height then return end
	transform_window:mousepressed(x, y, button,
		function(args)
			for _,v in ipairs(args.objects) do
				if v.in_focus then
					for _,p in ipairs(v.p) do
						p.x = p.x + args.win.m
						p.y = p.y + args.win.n
					end
				end
			end
		end,
		{objects = obj_stack, win = transform_window}
	)
  local temp_obj = nil
  if mode_list.active_element.text == 'Edit' then return end
	unfocus_all(obj_stack)
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
  drawing = true
  state_line.chosen_obj = temp_obj
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
	transform_button:mousereleased(x, y, button)
	scale_button:mousereleased(x, y, button)
	mirror_button:mousereleased(x, y, button)
	rotate_button:mousereleased(x, y, button)
  drawing = false
  if mode_list.active_element.text == 'Focus' then
    local focus_rect = obj_stack[#obj_stack]
    local one_focused = false
    for _,v in ipairs(obj_stack) do
      v.in_focus = true
      for _,p in ipairs(v.p) do
        p.in_focus = p.x > math.min(focus_rect.p[1].x, focus_rect.p[2].x) and
                     p.x < math.max(focus_rect.p[1].x, focus_rect.p[2].x) and
                     p.y > math.min(focus_rect.p[1].y, focus_rect.p[2].y) and
                     p.y < math.max(focus_rect.p[1].y, focus_rect.p[2].y)
        v.in_focus = v.in_focus and p.in_focus
        one_focused = one_focused or p.in_focus
      end
    end
    table.remove(obj_stack)
    if one_focused then mode_list:set_active('Edit') end
  end
  mode_list:mousereleased(x, y, button)
  color_list:mousereleased(x, y, button)
  current_color = palette[color_list.active_element.text]
	local _, i = group_list:mousereleased(x, y, button)
	if i then 
		unfocus_all(obj_stack)
		focus_all(groups[i-1].elements) 
		mode_list:set_active('Edit')
	end
  state_line:mousereleased(x, y, button)
	transform_window:mousereleased(x, y, button)
end


function love.keypressed(key)
	if state_line:keypressed(key) then return end
	if transform_window:keypressed(key) then return end
  local save_filename = 'save'
  if love.keyboard.isDown('lctrl') then
    if key == 'z' then 
			table.remove(obj_stack)
		elseif key == 's' then 
      love.filesystem.write(save_filename, '')
      for _,v in ipairs(obj_stack) do serialize(v, save_filename) end
		elseif key == 'l' then
      for line in love.filesystem.lines(save_filename) do
        table.insert(obj_stack, deserialize(line))
      end
		elseif key == 'a' then
			focus_all(obj_stack)
		elseif key == 'g' then
			local group = {}
			for _,v in ipairs(obj_stack) do
				if v.in_focus then table.insert(group, v) end
			end
			table.insert(groups, Group(group, tostring(#groups)))
			group_list:add_element(UI:Label(UI:Rect(), tostring(#groups)))
    end
  end
  if key == 'backspace' then
    local new_stack = {}
    for _,v in ipairs(obj_stack) do
      if not v.in_focus then table.insert(new_stack, v) end
    end
    obj_stack = new_stack
	elseif key == 'escape' then
		unfocus_all(obj_stack)
		mode_list:set_active('Focus')
  end
end 
