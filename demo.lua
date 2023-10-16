require 'matrix'

m1 = {
	{1, 3, 1},
	{3, 2, 1},
	{1, 2, 1}
}

m2 = {
	{0, 1, 0},
	{-1, 0, 0},
	{0, 0, 1}
}

dot = matrix_dot(m1, m2)

for i=1, #dot do
	print(table.concat(dot[i], ' '))
end