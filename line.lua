function Line(p1, p2)
  local this = {}
  this.type = 'line'
  this.p = {p1, p2}
  this.color = {r=1,g=1,b=1}

  function this:draw()
    love.graphics.setColor(self.color.r, self.color.g, self.color.b)
    love.graphics.line(self.p[1].x, self.p[1].y, self.p[2].x, self.p[2].y)
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
