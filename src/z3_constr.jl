# Constraints
untrackedconstraint(model::Z3Model, constr) = model.ptr[:add](constr)
trackedconstraint(model::Z3Model, constr, trackvar) = model.ptr[:assert_and_track](constr,trackvar)

function constraint(model::Z3Model, constr)
    model.numconstr += 1
    numconstr = model.numconstr
    trackvar = variable(model,:Bool,name="c$numconstr")
    push!(model.constr,trackvar)
    trackedconstraint(model,constr,trackvar)
    return trackvar
end

function objective(m::Z3Model,sense::Symbol,expr)
    objvar = variable(m, name="obj")
    m.objvar = objvar
    if sense == :Min
        constraint(m, objvar >= expr)
    elseif sense == :Max
        constraint(m, objvar <= expr)
    else
        error("Invalid sense, valid senses are :Min, :Max")
    end
end

implies(m::Z3Model, prop1, prop2) = constraint(m, z3[:Implies](prop1,prop2))
atmost(m::Z3Model,arr::Array,k::Int64) = constraint(m, z3[:AtMost](arr..., k))
atleast(m::Z3Model,arr::Array,k::Int64) = constraint(m, z3[:AtLeast](arr..., k))
