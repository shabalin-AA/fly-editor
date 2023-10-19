function Point(x,y,z)
  local this = {}
  this.type = 'point'
  this.x = x
  this.y = y
	this.z = z or 0

  this.in_focus = false
  this.r = 3

  function this:draw()
    if not self.in_focus then return end
    love.graphics.circle('line', self.x, self.y, self.r)
  end

  function this:same_with(x,y)
    return  x > self.x - 2*self.r and x < self.x + 2*self.r and
            y > self.y - 2*self.r and y < self.y + 2*self.r
  end
	
	function this:swap_coords()
		local x_backup = self.x
		self.x = self.y
		self.y = self.z
		self.z = x_backup
	end
  
  return this
end