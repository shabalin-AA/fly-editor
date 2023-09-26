require 'palette'

function Points(color)
  local this = {}
  this.p = {}
  this.type = 'points'
  if color then this.color = color
  else this.color = palette.lightbrown end

  function this:draw()
    love.graphics.setColor(self.color.r, self.color.g, self.color.b)
    for i=2, #self.p do
      love.graphics.line(self.p[i-1].x, self.p[i-1].y, self.p[i].x, self.p[i].y)
    end
    for _,v in ipairs(self.p) do v:draw() end
  end

  return this
end
