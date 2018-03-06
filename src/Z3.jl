module Z3

using PyCall
import Base.push!, Base.pop!

# Load z3 Python library
const z3 = PyNULL()

function __init__()
    copy!(z3, pyimport_conda("z3", "z3"))
end

export z3, Z3Real, Z3Int, Z3Bool, Z3Model,
    add_var!, add_cvar!,add_ivar!,add_bvar!,
    add_constraint!, check, get_unsat_core

Z3Real(name::String) = z3[:Real](name)
Z3Int(name::String) = z3[:Int](name)
Z3Bool(name::String) = z3[:Bool](name)

mutable struct Z3Model
    ptr::PyObject
    numvars::Int
    varvalue::Vector{Float64}
    varlower::Vector{Float64}
    varupper::Vector{Float64}
    vartype::Vector{Symbol}
    varptr::Vector{PyObject}
    varname::Vector{String}
    numconstr::Int
    constr::Vector{PyObject}
    obj
    objvalue::Float64
    objbound::Float64
    objsense::Symbol
    objlower::Float64
    objupper::Float64
    checkstatus::Symbol
    Z3Model() = new(z3[:Solver](), 0, Float64[],Float64[],Float64[],Symbol[],PyObject[],String[],0,PyObject[],nothing,NaN,NaN,:Min,1e-12,1e12,:Unchecked)
end

function add_var!(model::Z3Model,vartype::Symbol,lb::Real=-Inf, ub::Real=Inf)
  model.numvars += 1
  numvars = model.numvars
  push!(model.varvalue,NaN)
  push!(model.varlower,lb)
  push!(model.varupper,ub)
  push!(model.vartype,vartype)
  if vartype == :Cont
    varname = "x$numvars"
    var = Z3Real(varname)
  elseif vartype == :Int     
    varname = "z$numvars"
      var = Z3Int(varname)
  elseif vartype == :Bool || vartype == :Bin
      varname = "y$numvars"
      var = Z3Bool(varname)
  else
      error("Invalid variable type. Valid types ar :Cont, :Int, :Bool")
  end
    push!(model.varname,varname)
    push!(model.varptr,var)
    lb != -Inf && model.ptr[:add](var >= lb)
    ub != Inf && model.ptr[:add](var <= ub)
    return var
end

add_cvar!(model::Z3Model,lb::Real=-Inf,ub::Real=Inf) = add_var!(model,:Cont,lb,ub)
add_ivar!(model::Z3Model,lb::Real=-Inf,ub::Real=Inf) = add_var!(model,:Int,lb,ub)
add_bvar!(model::Z3Model,lb::Real=-Inf,ub::Real=Inf) = add_var!(model,:Bool,lb,ub)

function add_constraint!(model::Z3Model, constr)
    model.numconstr += 1
    numconstr = model.numconstr
    trackvar = Z3Bool("c$numconstr")
    push!(model.constr,trackvar)
    model.ptr[:assert_and_track](constr,trackvar)
    return trackvar
end

function check(model::Z3Model)
    result = model.ptr[:check]()
    if result == z3[:sat]
        model.checkstatus = :Feasible
    elseif result == z3[:unsat]
        model.checkstatus = :Infeasible
    else
        model.checkstatus = :Unknown
    end
    return model.checkstatus
end

push!(model::Z3Model) = model.ptr[:push]()
pop!(model::Z3Model) = model.ptr[:pop]()
    
function get_unsat_core(model::Z3Model)
    IIS = Int64[]
    if model.checkstatus != :Infeasible
        warn("IIS available for infeasible models only. Make sure to run check(model) first")
    else
        unsat_core = model.ptr[:unsat_core]()
        for (i,c) in enumerate(model.constr)
            if unsat_core[:__contains__](c)
                push!(IIS,i)
            end
        end
    end
    return IIS
end

function optimize(model::Z3Model,gap)
    if abs((model.objupper - m.objlower)/model.objupper) < gap
        model.checkstatus = :Optimal 
        return model.checkstatus
    else
        
    end
    
end


end
