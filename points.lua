require 'palette'

function Points(color)
  local this = {}
  this.p = {}
  this.type = 'Points'
  if color then this.color = color
  else this.color = palette.lightbrown end

  function this:draw()
    setColor(self.color)
    for i=2, #self.p do
      love.graphics.line(
				self.p[i-1].screen_x, self.p[i-1].screen_y, 
				self.p[i].screen_x, self.p[i].screen_y
			)
    end
    for _,v in ipairs(self.p) do v:draw() end
  end

  function this:serialize()
  	--
  end

  return this
end
