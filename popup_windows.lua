require 'ui'

local win_w = 250
local win_h = 160
local W, H = love.window.getDesktopDimensions()
local win_x = W/2 - win_w/2
local win_y = H/2 - win_h/2 - 100

transform_window = UI:Window(
	UI:Rect(win_x, win_y, win_w, win_h, palette.grey, palette.lightbrown), 
	'Transform'
)
transform_window:add_element(
	UI:Label(
		UI:Rect(20, 50, 60, 24, nil, palette.grey), 
		'm = ', 
		palette.bone
	)
)
transform_window.m_in = transform_window.elements[
	transform_window:add_element(
		UI:TextInput(
			UI:Rect(80, 50, 120, 24, palette.bone, palette.grey), 
			palette.grey
		)
	)
]
transform_window:add_element(
	UI:Label(
		UI:Rect(20, 100, 60, 24, nil, palette.grey), 
		'n = ', 
		palette.bone
	)
)
transform_window.n_in = transform_window.elements[
	transform_window:add_element(
		UI:TextInput(
			UI:Rect(80, 100, 120, 24, palette.bone, palette.grey), 
			palette.grey
		)
	)
]
transform_window.m = 0
transform_window.n = 0


scale_window = UI:Window(
	UI:Rect(win_x, win_y-100, win_w, win_h*2, palette.grey, palette.lightbrown), 
	'Scale'
)
scale_window:add_element(
	UI:Label(
		UI:Rect(20, 50, 60, 24, nil, palette.grey), 
		'a = ', 
		palette.bone
	)
)
scale_window.a_in = scale_window.elements[
	scale_window:add_element(
		UI:TextInput(
			UI:Rect(80, 50, 120, 24, palette.bone, palette.grey), 
			palette.grey
		)
	)
]
scale_window:add_element(
	UI:Label(
		UI:Rect(20, 100, 60, 24, nil, palette.grey), 
		'b = ', 
		palette.bone
	)
)
scale_window.b_in = scale_window.elements[
	scale_window:add_element(
		UI:TextInput(
			UI:Rect(80, 100, 120, 24, palette.bone, palette.grey), 
			palette.grey
		)
	)
]
scale_window.a = 0
scale_window.b = 0

scale_window:add_element(
	UI:Label(
		UI:Rect(20, 150, 210, 24, nil, palette.grey), 
		'relative to point with coordinates:', 
		palette.bone
	)
)
scale_window:add_element(
	UI:Label(
		UI:Rect(20, 200, 60, 24, nil, palette.grey), 
		'm = ', 
		palette.bone
	)
)
scale_window.m_in = scale_window.elements[
	scale_window:add_element(
		UI:TextInput(
			UI:Rect(80, 200, 120, 24, palette.bone, palette.grey), 
			palette.grey
		)
	)
]
scale_window:add_element(
	UI:Label(
		UI:Rect(20, 250, 60, 24, nil, palette.grey), 
		'n = ', 
		palette.bone
	)
)
scale_window.n_in = scale_window.elements[
	scale_window:add_element(
		UI:TextInput(
			UI:Rect(80, 250, 120, 24, palette.bone, palette.grey), 
			palette.grey
		)
	)
]
scale_window.m = 0
scale_window.n = 0



rotate_window = UI:Window(
	UI:Rect(win_x, win_y-100, win_w, win_h+100, palette.grey, palette.lightbrown), 
	'Rotate'
)
rotate_window:add_element(
	UI:Label(
		UI:Rect(20, 50, 80, 24, nil, palette.grey), 
		'alpha = ', 
		palette.bone
	)
)
rotate_window.alpha_in = rotate_window.elements[
	rotate_window:add_element(
		UI:TextInput(
			UI:Rect(100, 50, 120, 24, palette.bone, palette.grey), 
			palette.grey
		)
	)
]

rotate_window:add_element(
	UI:Label(
		UI:Rect(20, 100, 210, 24, nil, palette.grey), 
		'relative to point with coordinates:', 
		palette.bone
	)
)
rotate_window:add_element(
	UI:Label(
		UI:Rect(20, 150, 60, 24, nil, palette.grey), 
		'm = ', 
		palette.bone
	)
)
rotate_window.m_in = rotate_window.elements[
	rotate_window:add_element(
		UI:TextInput(
			UI:Rect(80, 150, 120, 24, palette.bone, palette.grey), 
			palette.grey
		)
	)
]
rotate_window:add_element(
	UI:Label(
		UI:Rect(20, 200, 60, 24, nil, palette.grey), 
		'n = ', 
		palette.bone
	)
)
rotate_window.n_in = rotate_window.elements[
	rotate_window:add_element(
		UI:TextInput(
			UI:Rect(80, 200, 120, 24, palette.bone, palette.grey), 
			palette.grey
		)
	)
]
rotate_window.m = 0
rotate_window.n = 0
