function Point(screen_x, screen_y)
  local this = {}
  this.type = 'point'
  this[ axis[axis_mode+0] ] = screen_x
  this[ axis[axis_mode+1] ] = screen_y
	this[ axis[axis_mode+2] ] = 100
	
  this.in_focus = false
  this.r = 3
	
	function this:update()
		self.screen_x = self[axis[axis_mode] ]
		self.screen_y = self[axis[axis_mode+1] ]
	end

  function this:draw()
    if not self.in_focus then return end
    love.graphics.circle('line', self.screen_x, self.screen_y, self.r)
  end

  return this
end
