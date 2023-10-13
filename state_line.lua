require 'ui'

local function gcd(a, b)
  if a == 0 then return b end
  return gcd(math.fmod(b, a), a)
end

state_line = UI:Rect(0,0,0,0, palette.bone)

function state_line:load()
  self.chosen_obj = nil
  self.a_input = UI:TextInput(UI:Rect(0, 0, 80, 0, palette.bone, palette.lightbrown), palette.grey)
  self.b_input = UI:TextInput(UI:Rect(0, 0, 80, 0, palette.bone, palette.lightbrown), palette.grey)
  self.c_input = UI:TextInput(UI:Rect(0, 0, 80, 0, palette.bone, palette.lightbrown), palette.grey)
  self.active = false
end

function state_line:update()
  local font_h = love.graphics.getFont():getHeight() + 8
  self.y = love.graphics.getHeight() - font_h
  self.width = love.graphics.getWidth()
  self.height = font_h
  self.a_input.y = self.y + 3
  self.a_input.height = self.height - 6
  self.b_input.y = self.y + 3
  self.b_input.height = self.height - 6
  self.c_input.y = self.y + 3
  self.c_input.height = self.height - 6
  self.active = self.a_input.active or self.b_input.active or self.c_input.active
end

function state_line:draw()
  self:draw_back()
  self:draw_border()
  setColor(palette.grey)
  love.graphics.printf(
    string.format('%d; %d', love.mouse.getX(), love.mouse.getY()), 
    0, self.y+4, self.width-4, 'right'
  )
  if not self.chosen_obj then return end
  if self.chosen_obj.type ~= 'Line' then return end
  local x1, y1 = self.chosen_obj.p[1].x, self.chosen_obj.p[1].y
  if self.a_input.active then
    self.chosen_obj.p[2].y = (tonumber(table.concat(self.a_input.text)) or 0) + y1
	elseif self.b_input.active then
	  self.chosen_obj.p[2].x = -(tonumber(table.concat(self.b_input.text)) or 0) + x1
	end
  local x2, y2 = self.chosen_obj.p[2].x, self.chosen_obj.p[2].y
  local A = y2 - y1
  local B = -x2 + x1
  local C = -y1 * B - x1 * A
  -- if not self.active then 
  --   local gcd_ABC = gcd(A, gcd(B, C))
  --   A, B, C = A/gcd_ABC, B/gcd_ABC, C/gcd_ABC
  -- end
  if not self.active then
    self.a_input:set_text(tostring(A))
    self.b_input:set_text(tostring(B))
	  self.c_input:set_text(tostring(C))
	end
	local type_text = self.chosen_obj.type .. ':'
  love.graphics.print(type_text, self.x + 4, self.y + 4)
  self.a_input.x = love.graphics.getFont():getWidth(type_text) + 16
	self.a_input:draw()
	love.graphics.print('x + ', self.a_input.x + self.a_input.width + 2, self.y + 4)
	self.b_input.x = self.a_input.x + self.a_input.width + 2 + 40
	self.b_input:draw()
	love.graphics.print('y + ', self.b_input.x + self.b_input.width + 2, self.y + 4)
	self.c_input.x = self.b_input.x + self.b_input.width + 2 + 40
	self.c_input:draw()
	love.graphics.print(' = 0', self.c_input.x + self.c_input.width + 2, self.y + 4)
end

function state_line:mousereleased(x, y, button)
	self.a_input:mousereleased(x, y, button)
	self.b_input:mousereleased(x, y, button)
end

function state_line:keypressed(key)
	self.a_input:keypressed(key)
	self.b_input:keypressed(key)
end
