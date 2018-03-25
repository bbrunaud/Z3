__precompile__()

module Z3


using PyCall
import Base.push!, Base.pop!

# Load z3 Python library
const z3 = PyNULL()

function __init__()
    copy!(z3, pyimport_conda("z3", "z3"))
end

export
# Low-level access
z3,
# Model
Z3Model,
# Variables
variable,
# Constraints
constraint, objective, implies, atmost, atleast,
# Solver
check, get_unsat_core, solve


# Model
include("z3_model.jl")
# Variables
include("z3_var.jl")
# Constraints
include("z3_constr.jl")
# Solver
include("z3_solver.jl")

end
