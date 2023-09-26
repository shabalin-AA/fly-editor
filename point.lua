function Point(x,y)
  local this = {}
  this.type = 'point'
  this.x = x
  this.y = y

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
  
  return this
end
