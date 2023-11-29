require 'rectangle'
require 'line'
require 'points'
require 'point'

function serialize(obj, filename)
   local str = string.format('%s %f %f %f ', obj.type, obj.color.r, obj.color.g, obj.color.b)
   for _,v in ipairs(obj.p) do
   	str = str .. string.format('%d %d %d ', v[1], v[2], v[3])
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
  for i=5, #words, 3 do
		local temp_p = Point()
		temp_p[1] = tonumber(words[i+0])
		temp_p[2] = tonumber(words[i+1])
		temp_p[3] = tonumber(words[i+2])
  	table.insert(obj.p, temp_p)
  end
  return obj
end
