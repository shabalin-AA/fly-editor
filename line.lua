function Line(p1, p2)
  local this = {}
  this.type = 'Line'
  this.p = {p1, p2}
  this.color = {r=1,g=1,b=1}

  function this:draw()
    setColor(self.color)
    love.graphics.line(
			self.p[1].screen_x, self.p[1].screen_y, 
			self.p[2].screen_x, self.p[2].screen_y
		)
    self.p[1]:draw()
    self.p[2]:draw()
  end

  return this
end
