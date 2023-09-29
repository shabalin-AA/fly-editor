function Line(p1, p2)
  local this = {}
  this.type = 'Line'
  this.p = {p1, p2}
  this.color = {r=1,g=1,b=1}

  function this:draw()
    love.graphics.setColor(self.color.r, self.color.g, self.color.b)
    love.graphics.line(self.p[1].x, self.p[1].y, self.p[2].x, self.p[2].y)
    self.p[1]:draw()
    self.p[2]:draw()
  end

  return this
end
