using Z3

# Optimize model
# Min x + y
# s.t x > 3
#     y > 5

# Model
m = Z3Model()
@assert isa(m,Z3Model)

# Variables
x = variable(m)
y = variable(m,:Bin)

# Constraints
constraint(m, x == 5)
implies(m, x > 0, y)

# Objective
objective(m, :Min, x*10 + y*100)

#status = solve(m)
