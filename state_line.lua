require 'ui'

state_line = UI:Rect(0,0,0,0, palette.bone)

function state_line:load()
  self.chosen_obj = nil
  self.a_input = UI:TextInput(UI:Rect(0,0,0,0, palette.bone, palette.grey), palette.grey)
  self.b_input = UI:TextInput(UI:Rect(0,0,0,0, palette.bone, palette.grey), palette.grey)
  self.c_input = UI:TextInput(UI:Rect(0,0,0,0, palette.bone, palette.grey), palette.grey)
end

function state_line:update()
  local font_h = love.graphics.getFont():getHeight() + 8
  self.y = love.graphics.getHeight() - font_h
  self.width = love.graphics.getWidth()
  self.height = font_h
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
    love.graphics.print(
      string.format('%s: %dx + %dy + %d = 0', self.chosen_obj.type, A, B, C),
      0 + 4, self.y + 4
    )
  end
end
