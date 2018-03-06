using Z3

m = Z3Model()

x1 = add_cvar!(m)

add_constraint!(m, x1 > 5)
push!(m)
add_constraint!(m, x1 < 3)
status = check(m)
println("Status = $status")

iis = get_unsat_core(m)

pop!(m)
check(m)
