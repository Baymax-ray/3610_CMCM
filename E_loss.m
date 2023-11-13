function economic_loss=E_loss(population)
    agriculture_production=[273899000 ,673429000,323695000,892293000,260715000,786178000,320780000,502582000,275718000,597500000];
    grape_region=[0,1,1,1,1,0,1,0,0,1,1,1,1,1];

    economic_loss=0;
    for i = 1:size(population,1)
        if grape_region(i)==0
            economic_loss=economic_loss+population(i,3,end)*agriculture_production(i);
        else
            economic_loss=economic_loss+population(i,3,end)*agriculture_production(i)*5;
        end
    end
end