function Point(screen_x, screen_y)
  local this = {}
  this.type = 'point'
  this[axis_mode+0] = screen_x or 0
  this[axis_mode+1] = screen_y or 0
	if axis_mode == 1 then this[3] = 100
	else this[1] = 100 end
	this[4] = 1
	this.screen_x = this[axis_mode+0]
	this.screen_y = this[axis_mode+1]
	
  this.in_focus = false
  this.r = 3
	
	function this:update()
		self.screen_x = self[axis_mode+0]
		self.screen_y = self[axis_mode+1]
	end

  function this:draw()
    if not self.in_focus then return end
    love.graphics.circle('line', self.screen_x, self.screen_y, self.r)
  end

  return this
end
