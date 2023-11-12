function valid=check_valid(policy,total_reource_per_year,C_inspection,C_tree_trap)
    valid=1;
    for y = 1:size(policy,3)
        if sum(policy(:,1,y))*C_inspection+sum(policy(:,2,y))*C_tree_trap>total_reource_per_year
            valid=0;
            return
        end
    end
end