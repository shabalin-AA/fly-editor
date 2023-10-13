palette = {
  green = {r=166/256, g=255/256, b=150/256},
  red = {r=255/256, g=105/256, b=105/256},
  blue = {r=23/256, g=107/256, b=135/256},
  lightblue = {r=228/256, g=241/256, b=255/256},
  grey = {r=34/256, g=34/256, b=34/256},
  bone = {r=250/256, g=241/256, b=228/256},
  lightbrown = {r=116/256, g=103/256, b=103/256}
}

function setColor(palette_color)
	love.graphics.setColor(palette_color.r, palette_color.g, palette_color.b)
end
