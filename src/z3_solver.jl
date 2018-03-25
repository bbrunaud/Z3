# Solver
function check(model::Z3Model)
    result = model.ptr[:check]()
    if result == z3[:sat]
        model.status = :Feasible
    elseif result == z3[:unsat]
        model.status = :Infeasible
    else
        model.status = :Unknown
    end
    return model.status
end

function get_unsat_core(model::Z3Model)
    IIS = Int64[]
    if model.status != :Infeasible
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

function checkbound(model::Z3Model,bound)
    push!(model)
    if model.sense == :Min
        untrackedconstraint(model, model.objvar <= bound)
    else
        untrackedconstraint(model, model.objvar >= bound)
    end
    status = check(model)
    pop!(model)
    return status
end

function solve(m::Z3Model,lb=-1e12,ub=1e12; AbsGap=1,Precision=1)
    println("lb = $lb, ub = $ub")
    if m.status == :Unchecked
        status = check(m)
        m.status = status
        if status == :Infeasible
            warn("Infeasible Model")
            return :Infeasible
        end
    end
    rlb = rlog(lb)
    rub = rlog(ub)
    if abs(ub-lb) <= AbsGap
        m.status = :Optimal
        return :Optimal
    elseif rub - rlb > 1
        mid = 10^(0.5*(rub + rlb))
    else
        mid = 0.5*(ub + lb)
    end
    mid = round(mid,Precision)
    status = checkbound(m,mid)
    if status == :Feasible
        solve(m,lb,mid,AbsGap=AbsGap)
    else
        solve(m,mid,ub,AbsGap=AbsGap)
    end
end

function rlog(n)
    n = round(n, 0)
    if n == 0
        return 0
    elseif n < 0
        return round(-log10(abs(n)),0)
    else
        return round(log10(n),0)
    end
end
