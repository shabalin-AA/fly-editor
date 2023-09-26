function Rectangle(p1, p2)
  local this = {}
  this.type = 'rect'
  this.p = {p1, p2}
  this.color = {r=0,g=0,b=0}
  
  function this:draw()
    love.graphics.setColor(self.color.r, self.color.g, self.color.b)
    love.graphics.rectangle('line', self.p[1].x, self.p[1].y, self.p[2].x-self.p[1].x, self.p[2].y-self.p[1].y)
    self.p[1]:draw()
    self.p[2]:draw()
  end
  
  function this:serialize(filename)
    love.filesystem.append(filename, 
      string.format(
        '%d %d %d %d %f %f %f %s\n', 
        self.p[1].x, self.p[1].y, self.p[2].x, self.p[2].y,
        self.color.r, self.color.g, self.color.b,
        self.type
      )
    )
  end
  
  return this
end
