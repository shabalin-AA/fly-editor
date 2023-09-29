require 'rectangle'
require 'line'
require 'points'
require 'point'

function serialize(obj, filename)
   local str = string.format('%s %f %f %f ', obj.type, obj.color.r, obj.color.g, obj.color.b)
   for _,v in ipairs(obj.p) do
   	str = str .. string.format('%d %d ', v.x, v.y)
   end
   str = str .. '\n'
  love.filesystem.append(filename, str)
 end
  
function deserialize(line)
  local words = {}
  for word in line:gmatch("%S+") do table.insert(words, word) end
  local obj = nil
  local type = words[1]
  if type == 'Line' then obj = Line()
  elseif type == 'Rectangle' then obj = Rectangle()
  elseif type == 'Points' then obj = Points()
  end
  if obj == nil then return nil end
  obj.color = {r=words[2], g=words[3], b=words[4]}
  obj.p = {}
  for i=5, #words, 2 do
  	table.insert(obj.p, Point(tonumber(words[i]), tonumber(words[i+1])))
  end
  return obj
end
