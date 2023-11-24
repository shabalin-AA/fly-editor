function matrix_dot(m1, m2)
  local dot = {}
  for i=1, #m1 do
    local dot_row = {}
    for j=1, #m1[i] do
      local s = 0
      for k=1, #m1[i] do
        s = s + m1[i][k] * m2[k][j]
      end
      dot_row[j] = s
    end
    dot[i] = dot_row
  end
  return dot
end

function normalize(vec)
	vec[1] = vec[1] / vec[4]
	vec[2] = vec[2] / vec[4]
	vec[3] = vec[3] / vec[4]
end

function rot_x(angle)
	return {
		{1, 0, 0, 0},
		{0, math.cos(angle), math.sin(angle), 0},
		{0, -math.sin(angle), math.cos(angle), 0},
		{0, 0, 0, 1}
	}
end

function rot_y(angle)
	return {
		{math.cos(angle), 0, -math.sin(angle), 0},
		{0, 1, 0, 0},
		{math.sin(angle), 0, math.cos(angle), 0},
		{0, 0, 0, 1}
	}
end

function Camera(x, y, z, n, f, h_fov)
	local this = {}
	this.x = x or 0
	this.y = y or 0
	this.z = z or -100
	this.n = n or 0.1
	this.f = f or 100
	this.h_fov = h_fov or math.pi / 3
	this.v_fov = this.h_fov * love.graphics.getHeight() / love.graphics.getWidth()
	
	this.forward = {0, 0, 1, 1}
	this.up = {0, 1, 0, 1}
	this.right = {1, 0, 0, 1}
	
	this.yaw = 0
	this.pitch = 0
	
	function this:get_proj(V)
		self.forward = {0, 0, 1, 1}
		self.up = {0, -1, 0, 1}
		self.right = {1, 0, 0, 1}
		local rot = matrix_dot(rot_x(self.pitch), rot_y(self.yaw))
		self.forward = matrix_dot({self.forward}, rot)[1]
		self.up = matrix_dot({self.up}, rot)[1]
		self.right = matrix_dot({self.right}, rot)[1]
		local translate = {
			{1, 0, 0, 0},
			{0, 1, 0, 0},
			{0, 0, 1, 0},
			{-self.x, -self.y, -self.z, 1}
		}
		local look_at = {
			{self.right[1], self.up[1], self.forward[1], 0},
			{self.right[2], self.up[2], self.forward[2], 0},
			{self.right[3], self.up[3], self.forward[3], 0},
			{0, 0, 0, 1}
		}
		local camera_m = matrix_dot(translate, look_at)
		local right = math.tan(self.h_fov / 2)
		local left = -right
		local top = math.tan(self.v_fov / 2)
		local bot = - top
		local projection_m = {
			{2 / (right - left), 0, 0, 0},
			{0, 2 / (top - bot), 0, 0},
			{0, 0, (self.f + self.n) / (self.f - self.n), 1},
			{0, 0, -2 * self.n * self.f / (self.f - self.n), 0}
		}
		local W,H = love.graphics.getDimensions()
		local to_screen = {
			{W, 0, 0, 0},
			{0, -H, 0, 0},
			{0, 0, 1, 0},
			{W, H, 0, 1}
		}
		local v_res = matrix_dot(V, camera_m)
		v_res = matrix_dot(v_res, projection_m)
		for _,v in ipairs(v_res) do 
			normalize(v) 
			for i=1, #v do
				if v[i] > 2 or v[i] < -2 then v[i] = 0 end
			end
		end
		v_res = matrix_dot(v_res, to_screen)
		for i,p in ipairs(V) do
			p.screen_x = v_res[i][1]
			p.screen_y = v_res[i][2]
		end
		return v_res
	end
	
	function this:update()
		local speed = 10
		if love.keyboard.isDown('a') then
			self.x = self.x - self.right[1] * speed
			self.y = self.y - self.right[2] * speed
			self.z = self.z - self.right[3] * speed
		end
		if love.keyboard.isDown('d') then
			self.x = self.x + self.right[1] * speed
			self.y = self.y + self.right[2] * speed
			self.z = self.z + self.right[3] * speed
		end
		if love.keyboard.isDown('s') then
			self.x = self.x - self.forward[1] * speed
			self.y = self.y - self.forward[2] * speed
			self.z = self.z - self.forward[3] * speed
		end
		if love.keyboard.isDown('w') then
			self.x = self.x + self.forward[1] * speed
			self.y = self.y + self.forward[2] * speed
			self.z = self.z + self.forward[3] * speed
		end
		if love.keyboard.isDown('lshift') then
			self.x = self.x - self.up[1] * speed
			self.y = self.y - self.up[2] * speed
			self.z = self.z - self.up[3] * speed
		end
		if love.keyboard.isDown('space') then
			self.x = self.x + self.up[1] * speed
			self.y = self.y + self.up[2] * speed
			self.z = self.z + self.up[3] * speed
		end
	end
	
	function this:mousemoved(x, y, dx, dy)
		local speed = 10
		if love.mouse.isDown(1) then
		  self.yaw = self.yaw + dx * 0.01 / math.pi
		  self.pitch = self.pitch - dy * 0.01 / math.pi
		elseif love.mouse.isDown(2) then
			self.x = self.x + self.right[1] * speed * dx
			self.y = self.y + self.right[2] * speed * dx
			self.z = self.z + self.right[3] * speed * dx
			self.x = self.x - self.up[1] * speed * dy
			self.y = self.y - self.up[2] * speed * dy
			self.z = self.z - self.up[3] * speed * dy
		end
	end
	
	function this:wheelmoved(x, y)
		local speed = 20
		self.x = self.x + self.forward[1] * speed * y
		self.y = self.y + self.forward[2] * speed * y
		self.z = self.z + self.forward[3] * speed * y
	end
	
	return this
end
