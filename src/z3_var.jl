# Variables
Z3Real(name::String) = z3[:Real](name)
Z3Int(name::String) = z3[:Int](name)
Z3Bool(name::String) = z3[:Bool](name)

function variable(model::Z3Model,vartype::Symbol=:Cont,lb::Real=-Inf, ub::Real=Inf;name=nothing)
  model.numvars += 1
  numvars = model.numvars
  push!(model.varvalue,NaN)
  push!(model.varlower,lb)
  push!(model.varupper,ub)
  push!(model.vartype,vartype)
  if vartype == :Cont
    name = name == nothing ? "x$numvars" : name
    var = Z3Real(name)
  elseif vartype == :Int
    name = name == nothing ? "z$numvars" : name
    var = Z3Int(name)
  elseif vartype == :Bool || vartype == :Bin
    name = name == nothing ? "y$numvars" : name
      var = Z3Bool(name)
  else
      error("Invalid variable type. Valid types ar :Cont, :Int, :Bool")
  end
    push!(model.varname,name)
    push!(model.varptr,var)
    if vartype != :Bool
        lb != -Inf && untrackedconstraint(model, var >= lb)
        ub != Inf && untrackedconstraint(model, var <= ub)
    end
    return var
end

add_cvar!(model::Z3Model,lb::Real=-Inf,ub::Real=Inf) = variable(model,:Cont,lb,ub)
add_ivar!(model::Z3Model,lb::Real=-Inf,ub::Real=Inf) = variable(model,:Int,lb,ub)
add_bvar!(model::Z3Model) = variable(model,:Bool,0,1)
