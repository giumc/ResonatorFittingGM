function populate_boundaries_edit(r)

if isempty(r.boundaries_edit)
    r.setup_bars;
else
    if any(~isvalid([r.boundaries_edit{:}]))
        r.setup_bars;
    end
end
    for i=1:length(r.boundaries_edit)

        name=r.param_name(i);
        opt_param=r.get_param(name);

        edits=r.boundaries_edit{i};
        
        edits(1).String=opt_param.convert2sci(opt_param.min);
        edits(2).String=opt_param.convert2sci(opt_param.max);
        
    end
end
