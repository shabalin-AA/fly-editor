function matrix_dot(m1, m2)
	local dot = {}
	for i=1, #m1 do
		table.insert(dot, {})
		for j=1, #m1[i] do
			local sum = 0
			for k=1, #m1[i] do
				sum = sum + m1[i][k] * m2[k][j]
			end
			dot[i][j] = sum
		end
	end
	return dot
end