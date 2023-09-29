require 'ui'

state_line = UI:Rect(0,0,0,0, palette.bone)

function state_line:load()
  self.chosen_obj = nil
  self.a_input = UI:TextInput(UI:Rect(0,0,0,0, palette.bone, palette.lightbrown), palette.grey)
  self.b_input = UI:TextInput(UI:Rect(0,0,0,0, palette.bone, palette.lightbrown), palette.grey)
  self.c_input = UI:TextInput(UI:Rect(0,0,0,0, palette.bone, palette.lightbrown), palette.grey)
end

function state_line:update()
  local font_h = love.graphics.getFont():getHeight() + 8
  self.y = love.graphics.getHeight() - font_h
  self.width = love.graphics.getWidth()
  self.height = font_h
  self.a_input.x, self.a_input.y = 50, self.y + 3
  self.a_input.width, self.a_input.height = 80, self.height - 6
  self.b_input.x, self.b_input.y = 170, self.y + 3
  self.b_input.width, self.b_input.height = 80, self.height - 6
end

function state_line:draw()
  self:draw_back()
  self:draw_border()
  love.graphics.setColor(palette.grey.r, palette.grey.g, palette.grey.b)
  love.graphics.printf(
    string.format('%d; %d', love.mouse.getX(), love.mouse.getY()), 
    0, self.y+4, self.width-4, 'right'
  )
  if not self.chosen_obj then return end
  if self.chosen_obj.type == 'Line' then 
    local A = self.chosen_obj.p[2].y - self.chosen_obj.p[1].y
    local B = -self.chosen_obj.p[2].x + self.chosen_obj.p[1].x
    local C = self.chosen_obj.p[1].y * B - self.chosen_obj.p[1].x * A
    local function gcd(a, b)
      if a == 0 then return b end
      return gcd(math.fmod(b, a), a)
    end
    local gcd_ABC = gcd(A, gcd(B, C))
    A, B, C = A/gcd_ABC, B/gcd_ABC, C/gcd_ABC
    love.graphics.print('Line: ', self.x + 4, self.y + 4)
    if not self.a_input.active then
    	self.a_input:set_text(tostring(A))
    end
  	self.a_input:draw()
  	love.graphics.print('x + ', self.a_input.x + self.a_input.width + 2, self.y + 4)
  	if not self.b_input.active then 
  		self.b_input:set_text(tostring(B))
  	end
  	self.b_input:draw()
  	love.graphics.print('y + ', self.b_input.x + self.b_input.width + 2, self.y + 4)
  end
end

function state_line:mousereleased(x, y, button)
	self.a_input:mousereleased(x, y, button)
	self.b_input:mousereleased(x, y, button)
end

function state_line:keypressed(key)
	self.a_input:keypressed(key)
	self.b_input:keypressed(key)
end
