function [fishratio] = fishers(data,num_loops)

    fr = zeros(1,num_loops);
    for i =1:num_loops
        mean1 = mean(data(i,:));
        var1 = var(data(i,:));
        t = 1;
        if(i~= num_loops)
            mean2 = mean(data(i+1,:));
            var2 = var(data(i+1,:));
            fr(i) = (mean1 - mean2)^2 / (var1+var2);
            t = 2;
        end
        if(i ~=1)
            mean3 = mean(data(i-1,:));
            var3 = var((data(i-1,:)));
             fr(i) = (fr(i) + ((mean1 - mean3)^2 / (var1+var3)))/t;
        end
    end

    for i = 1:length(fr)
        if(fr(i) > 10000)
            fr(i) = 0;
        end
    end
    fishratio = mean(fr);

end