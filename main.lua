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
require 'axis'
require 'camera'


local function focus_all(arr)
	for i=4, #obj_stack do
		for _,p in ipairs(obj_stack[i].p) do p.in_focus = true end
		obj_stack[i].in_focus = true
	end
end

local function unfocus_all(arr)
	for _,v in ipairs(arr) do
		for _,p in ipairs(v.p) do p.in_focus = false end
		v.in_focus = false
	end
end


local function load_mode_list()
  mode_list = UI:FoldList(UI:List(UI:Label(UI:Rect(10, 10, 110, 26), 'Mode')))
    mode_list:add_element(UI:Label(UI:Rect(), 'Focus'))
    mode_list:add_element(UI:Label(UI:Rect(), 'Edit'))
    mode_list:add_element(UI:Label(UI:Rect(), '3D'))
    mode_list:add_element(UI:Label(UI:Rect(), 'Pen'))
    mode_list:add_element(UI:Label(UI:Rect(), 'Line'))
    -- mode_list:add_element(UI:Label(UI:Rect(), 'Rectangle'))
end

local function load_color_list()
  color_list = UI:FoldList(UI:List(UI:Label(UI:Rect(130, 10, 110, 26), 'Color')))
    color_list:add_element(UI:Label(UI:Rect(), 'red'))
    color_list:add_element(UI:Label(UI:Rect(), 'green'))
    color_list:add_element(UI:Label(UI:Rect(), 'blue'))
    color_list:add_element(UI:Label(UI:Rect(), 'lightbrown'))
end

local function load_op_buttons()
  translate_button = UI:Button(UI:Label(UI:Rect(250, 10, 110, 26), 'Translate'))
  scale_button = UI:Button(UI:Label(UI:Rect(370, 10, 110, 26), 'Scale'))
  rotate_button = UI:Button(UI:Label(UI:Rect(490, 10, 110, 26), 'Rotate'))
end


function love.load()
  love.graphics.setBackgroundColor(palette.grey.r, palette.grey.g, palette.grey.b)
  love.graphics.setNewFont(18)
  love.graphics.setLineWidth(2)
	local o = Point()
	o[1], o[2], o[3], o[4] = 0, 0, 0, 1
	local i = Point()
	i[1], i[2], i[3], i[4] = 1000, 0, 0, 1
	local j = Point()
	j[1], j[2], j[3], j[4] = 0, 1000, 0, 1
	local k = Point()
	k[1], k[2], k[3], k[4] = 0, 0, 1000, 1
  obj_stack = {
		Line(o,i,palette.red), Line(o,j,palette.green), Line(o,k,palette.blue)
	} 
  drawing = false
  prev_mouse_pos = {0, 0}
  current_color = palette.lightbrown
	groups = {}
	load_mode_list()
	load_color_list()
	group_list = UI:FoldList(UI:List(
		UI:Label(
			UI:Rect(love.graphics.getWidth() - 120, 10, 110, 26), 
			'Groups'
		)
	))
	load_op_buttons()
  state_line:load()
	camera = Camera(0, 0, -3000)
end


local function update_drawing_obj()
  if drawing then
    local last_obj = obj_stack[#obj_stack]
    if last_obj then 
      if last_obj.type == 'Points' then
        table.insert(last_obj.p, Point(love.mouse.getX(), love.mouse.getY()))
			else
	      local last_point = last_obj.p[#last_obj.p]
	      last_point[axis_mode+0], last_point[axis_mode+1] = love.mouse.getPosition() 
      end
    end
  end
end

local function move_selected_objects()
  if mode_list.active_element.text == 'Edit' and love.mouse.isDown(1) then
		local mx, my = love.mouse.getPosition()
    for _,obj in ipairs(obj_stack) do
      for _,p in ipairs(obj.p) do
        if p.in_focus then 
          p[axis_mode+0] = p[axis_mode+0] + mx - prev_mouse_pos[1]
          p[axis_mode+1] = p[axis_mode+1] + my - prev_mouse_pos[2]
          state_line.chosen_obj = obj
        end
      end
    end
  end
end

local function update_windows()
	translate_window:update()
	translate_window.m = tonumber(table.concat(translate_window.m_in.text)) or 0
	translate_window.n = tonumber(table.concat(translate_window.n_in.text)) or 0
	translate_window.l = tonumber(table.concat(translate_window.l_in.text)) or 0
	scale_window:update()
	scale_window.a = tonumber(table.concat(scale_window.a_in.text)) or 1
	scale_window.b = tonumber(table.concat(scale_window.b_in.text)) or 1
	scale_window.c = tonumber(table.concat(scale_window.c_in.text)) or 1
	scale_window.m = tonumber(table.concat(scale_window.m_in.text)) or 0
	scale_window.n = tonumber(table.concat(scale_window.n_in.text)) or 0
	scale_window.l = tonumber(table.concat(scale_window.l_in.text)) or 0
	rotate_window:update()
	rotate_window.alpha = tonumber(table.concat(rotate_window.alpha_in.text)) or 0
	rotate_window.beta = tonumber(table.concat(rotate_window.beta_in.text)) or 0
	rotate_window.gamma = tonumber(table.concat(rotate_window.gamma_in.text)) or 0
	rotate_window.m = tonumber(table.concat(rotate_window.m_in.text)) or 0
	rotate_window.n = tonumber(table.concat(rotate_window.n_in.text)) or 0
	rotate_window.l = tonumber(table.concat(rotate_window.l_in.text)) or 0
end

function love.update(dt)
	if mode_list.active_element.text ~= '3D' then
		for _,v in ipairs(obj_stack) do
			for _,p in ipairs(v.p) do p:update() end
		end
	end
	update_drawing_obj()
	move_selected_objects()
  mode_list:update()
  color_list:update()
	group_list:update()
  state_line:update()
	update_windows()
	camera:update()
  prev_mouse_pos = {love.mouse.getX(), love.mouse.getY()}
end


local function draw_objects()
	if mode_list.active_element.text == '3D' then
		local V = {}
		for _,obj in ipairs(obj_stack) do
			for _,p in ipairs(obj.p) do table.insert(V, p) end
		end
		camera:get_proj(V)
	end
  for _,v in ipairs(obj_stack) do v:draw() end
end

local function draw_lists()
  mode_list:draw()
  color_list:draw()
	group_list:draw()
end

local function draw_buttons()
	translate_button:draw()
	scale_button:draw()
	rotate_button:draw()
end

local function draw_windows()
	translate_window:draw()
	scale_window:draw()
	rotate_window:draw()
end

function love.draw()
	draw_objects()
	draw_buttons()
	draw_lists()
	draw_windows()
  if mode_list.active_element.text ~= '3D' then 
		state_line:draw()
	end
	setColor(palette.blue)
end


local function activate_win_event(args)
	translate_window.active = false
	scale_window.active = false
	rotate_window.active = false
	args.win.active = true
end

local function mpressed_buttons(x, y, button)
	if translate_button:mousepressed(x, y, button, activate_win_event,
		{win = translate_window}
	) then return true end
	if scale_button:mousepressed(x, y, button, activate_win_event,
		{win = scale_window}
	) then return true end
	if rotate_button:mousepressed(x, y, button, activate_win_event,
		{win = rotate_window}
	) then return true end
end

local function mpressed_windows(x, y, button)
	local points_matrix = {}
	for _,obj in ipairs(obj_stack) do
		if obj.in_focus then 
			for _,p in ipairs(obj.p) do
				p[4] = 1
				table.insert(points_matrix, p)
			end
		end
	end
	if translate_window:mousepressed(x, y, button,
		function(args)
			for _,p in ipairs(args.points) do
				p[1] = p[1] + args.win.m
				p[2] = p[2] + args.win.n
				p[3] = p[3] + args.win.l
			end	
			args.win.m_in.text = {}
			args.win.n_in.text = {}
			args.win.l_in.text = {}
		end,
		{points = points_matrix, win = translate_window}
	) then return true end
	if scale_window:mousepressed(x, y, button,
		function(args)
			for _,p in ipairs(args.points) do
				p[1] = (p[1] - args.win.m) * args.win.a + args.win.m
				p[2] = (p[2] - args.win.n) * args.win.b + args.win.n
				p[3] = (p[3] - args.win.l) * args.win.c + args.win.l
			end
			args.win.a_in.text = {}
			args.win.b_in.text = {}
			args.win.c_in.text = {}
			args.win.m_in.text = {}
			args.win.n_in.text = {}
			args.win.l_in.text = {}
		end,
		{points = points_matrix, win = scale_window}
	) then return true end
	if rotate_window:mousepressed(x, y, button,
		function(args)
			local a = args.win.alpha * math.pi / 180
			local b = args.win.beta * math.pi / 180
			local g = args.win.gamma * math.pi / 180
			local sin_a = math.sin(a)
			local cos_a = math.cos(a)
			local sin_b = math.sin(b)
			local cos_b = math.cos(b)
			local sin_g = math.sin(g)
			local cos_g = math.cos(g)
			local rotate_matrix = matrix_dot(matrix_dot(rot_x(a), rot_y(b)), rot_z(g))
			for i,p in ipairs(args.points) do
				p[1] = p[1] - args.win.m
				p[2] = p[2] - args.win.n
				p[3] = p[3] - args.win.l
			end	
			local dot = matrix_dot(args.points, rotate_matrix)
			for i=1, #dot do
				args.points[i][1] = dot[i][1] + args.win.m
				args.points[i][2] = dot[i][2] + args.win.n
				args.points[i][3] = dot[i][3] + args.win.l
			end
			args.win.alpha_in.text = {}
			args.win.beta_in.text = {}
			args.win.gamma_in.text = {}
			args.win.m_in.text = {}
			args.win.n_in.text = {}
			args.win.l_in.text = {}
		end,
		{points = points_matrix, win = rotate_window}
	) then return true end
end

local function handle_drawing(x, y, button)
  local temp_obj = nil
  if mode_list.active_element.text == 'Edit' then return end
	if mode_list.active_element.text == '3D' then return end
	unfocus_all(obj_stack) 
	if mode_list.active_element.text == 'Line' then 
    temp_obj = Line(Point(x,y), Point(x,y))
  elseif mode_list.active_element.text == 'Rectangle' then 
    temp_obj = Rectangle(Point(x,y), Point(x,y))
  elseif mode_list.active_element.text == 'Focus' then 
    temp_obj = Rectangle(Point(x,y), Point(x,y))
		temp_obj.type = 'FocusRectangle'
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

function love.mousepressed(x, y, button)
  if button > 1 then return end
  if y > state_line.y then return end
	if mpressed_buttons(x, y, button) then return end
	if mpressed_windows(x, y, button) then return end
	handle_drawing(x, y, button)
end


local function mreleased_buttons(x, y, button)
	translate_button:mousereleased(x, y, button)
	scale_button:mousereleased(x, y, button)
	rotate_button:mousereleased(x, y, button)
end

local function handle_focus(x, y, button)
  drawing = false
  if mode_list.active_element.text == 'Focus' then
    local focus_rect = obj_stack[#obj_stack]
		if focus_rect.type ~= 'FocusRectangle' then return end
    local one_focused = false
    for _,v in ipairs(obj_stack) do
      v.in_focus = true
      for _,p in ipairs(v.p) do
        p.in_focus = p[axis_mode+0] > math.min(focus_rect.p[1][axis_mode+0], focus_rect.p[2][axis_mode+0]) and
                     p[axis_mode+0] < math.max(focus_rect.p[1][axis_mode+0], focus_rect.p[2][axis_mode+0]) and
                     p[axis_mode+1] > math.min(focus_rect.p[1][axis_mode+1], focus_rect.p[2][axis_mode+1]) and
                     p[axis_mode+1] < math.max(focus_rect.p[1][axis_mode+1], focus_rect.p[2][axis_mode+1])
        v.in_focus = v.in_focus and p.in_focus
        one_focused = one_focused or p.in_focus
      end
    end
    table.remove(obj_stack)
    if one_focused then mode_list:set_active('Edit') end
  end
end

local function mreleased_lists(x, y, button)
  if mode_list:mousereleased(x, y, button) then
		if drawing then table.remove(obj_stack) end
		return
	end
  if color_list:mousereleased(x, y, button) then
  	current_color = palette[color_list.active_element.text]
		if drawing then table.remove(obj_stack) end
		return 
	end
	local _, i = group_list:mousereleased(x, y, button)
	if i then 
		if drawing then table.remove(obj_stack) end
		unfocus_all(obj_stack)
		focus_all(groups[i-1].elements) 
		-- mode_list:set_active('Edit')
	end
end

local function mreleased_windows(x, y, button)
	translate_window:mousereleased(x, y, button)
	scale_window:mousereleased(x, y, button)
	rotate_window:mousereleased(x, y, button)
end

function love.mousereleased(x, y, button)
  if button > 1 then return end
	mreleased_buttons(x, y, button)
	mreleased_lists(x, y, button)
	mreleased_windows(x, y, button)
	handle_focus(x, y, button)
  state_line:mousereleased(x, y, button)
end


local function handle_hotkeys(key)
  if love.keyboard.isDown('lctrl') then
    if key == 'z' then 
			table.remove(obj_stack)
		elseif key == 's' then 
			local save_filename = tostring('save_'..os.date("%d_%m_%Y_%H_%M_%S"))
			local res,err = love.filesystem.write(save_filename, '')
      for i=4, #obj_stack do serialize(obj_stack[i], save_filename) end
			-- load functionality in filedropped function
		elseif key == 'a' then
			focus_all(obj_stack)
			if mode_list.active_element.text ~= '3D' then 
				mode_list:set_active('Edit')
			end
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
	elseif key == 'tab' then
		axis_mode = math.fmod(axis_mode, 2) + 1
	elseif key == '3' then 
		mode_list:set_active('3D')
	elseif key == 'r' then
		camera = Camera(0, 0, -3000)
  end
end

function love.keypressed(key)
	if state_line:keypressed(key) then return end
	if translate_window:keypressed(key) then return end
	if scale_window:keypressed(key) then return end
	if rotate_window:keypressed(key) then return end
	handle_hotkeys(key)
end 

function love.wheelmoved(x, y) 
	camera:wheelmoved(x, y)
end

function love.mousemoved(x, y, dx, dy)
	if translate_window:mousemoved(x, y, dx, dy) then return end
	if scale_window:mousemoved(x, y, dx, dy) then return end
	if rotate_window:mousemoved(x, y, dx, dy) then return end
	if mode_list.active_element.text == '3D' then 
		camera:mousemoved(x, y, dx, dy)
	end
end

function love.filedropped(file)
	for line in io.lines(file:getFilename()) do
		table.insert(obj_stack, deserialize(line))
	end
end