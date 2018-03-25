# Model
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
    objvar::PyObject
    objvalue::Float64
    objbound::Float64
    sense::Symbol
    objlower::Float64
    objupper::Float64
    status::Symbol
    Z3Model() = new(z3[:Solver](), 0, Float64[],Float64[],Float64[],Symbol[],PyObject[],String[],0,PyObject[],nothing,NaN,NaN,:Min,1e-12,1e12,:Unchecked)
end

push!(model::Z3Model) = model.ptr[:push]()
pop!(model::Z3Model) = model.ptr[:pop]()
