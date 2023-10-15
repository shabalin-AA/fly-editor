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


scale_window = UI:Window(UI:Rect(win_x, win_y, win_w, win_h, palette.grey, palette.lightbrown), 'Scale')


mirror_window = UI:Window(UI:Rect(win_x, win_y, win_w, win_h, palette.grey, palette.lightbrown), 'Mirror')


rotate_window = UI:Window(UI:Rect(win_x, win_y, win_w, win_h, palette.grey, palette.lightbrown), 'Rotate')
