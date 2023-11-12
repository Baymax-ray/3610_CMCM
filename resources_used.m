for y = 1:size(policy,3)
   disp(sum(opt_policy(:,1,y))*C_inspection+sum(opt_policy(:,2,y))*C_tree_trap)
end