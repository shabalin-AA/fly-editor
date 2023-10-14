require 'ui'

local win_w = 300
local win_h = 200
local W, H = love.window.getDesktopDimensions()
local win_x = W/2 - win_w/2
local win_y = H/2 - win_h/2 - 100

local transform_window = UI:Window(UI:Rect(win_x, win_y, win_w, win_h, palette.grey, palette.lightbrown), 'Transform')


local scale_window = UI:Window(UI:Rect(win_x, win_y, win_w, win_h, palette.grey, palette.lightbrown), 'Scale')


local mirror_window = UI:Window(UI:Rect(win_x, win_y, win_w, win_h, palette.grey, palette.lightbrown), 'Mirror')


local rotate_window = UI:Window(UI:Rect(win_x, win_y, win_w, win_h, palette.grey, palette.lightbrown), 'Rotate')



popup_windows = {
	Transform = transform_window,
	Scale = scale_window,
	Mirror = mirror_window,
	Rotate = rotate_window
}