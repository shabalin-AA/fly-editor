function Rectangle(p1, p2)
  local this = {}
  this.type = 'Rectangle'
  this.p = {p1, p2}
  this.color = {r=0,g=0,b=0}
  
  function this:draw()
    setColor(self.color)
    love.graphics.rectangle(
			'line', 
			self.p[1].screen_x, self.p[1].screen_y, 
			self.p[2].screen_x-self.p[1].screen_x, self.p[2].screen_y-self.p[1].screen_y
		)
    self.p[1]:draw()
    self.p[2]:draw()
  end
  
  return this
end
