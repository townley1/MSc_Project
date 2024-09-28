
true_message = readmatrix('bit_seq_thresh.txt');

for xx = 3:3 % 14 and 15 appear to have no modulation
    S = [int2str(xx), '.txt'];
    C = readmatrix('test.txt')';
%C = C(701:end);
for i = 1:length(C)
    if(C(i) < max(C)+1 || C(i) > min(C)-1)
        continue
    else
        C(i) = sum(C)/length(C);
    end

end


[b, a] = butter(3, 0.05); %%%%%%%%%%% works better with 0.08


fc = 13.56*10^6;
adc_cycles = 12.80; 
ADC_period = 1/((84/(adc_cycles*4))*10^6);
bit_period = 4*512/fc; 
bit_samples = (bit_period/ADC_period);%244;%288; %7544;

threshold = sum(C)/length(C);


time = 0:ADC_period:ADC_period*length(C);
figure;
plot(time(1:length(C))*10^6,C, 'cyan')
hold on 

confidence = 0; increment = 20;
message = zeros(1,98);
big = 0; small = 0; count_big = 0; count_small =0;
for i = 1:100 % break signal into sections 
    if(i == 60)
        threshold = threshold*0.999;
    end
    first_half = 0; second_half = 0; eof = 0;
    c_1=0;c_0=0;


    start = floor((i-1)*bit_samples+1);
    middle = floor((i-1)*bit_samples) +floor(124);
    end_p = floor(i*bit_samples);

    for k = start:(start+100)
        if(C(k) > threshold)
            c_0  = c_0+1;
        end
    end
    for k = end_p:-1:(end_p - 100)
        if(C(k) > threshold)
            c_1  = c_1+1;
        end
    end

    if(c_0 < 5 && c_1 <5 && i>24)
        message(i) = 3;
    else
        if (c_0 > c_1)
            message(i) = 0;
            confidence = confidence + (c_0 - c_1);
            big = big+sum(C(start:middle));
            small = small + sum(C(middle:end_p));
            count_big = count_big+length(C(start:middle));
            count_small = count_small + length(C(middle:end_p));
        else
            message(i) = 1;
            confidence = confidence + (c_1 - c_0);
            small = small+sum(C(start:middle));
            big = big + sum(C(middle:end_p));
            count_big = count_big+length(C(middle:end_p));
            count_small = count_small + length(C(start:middle));
        end
    end

end
big_avg = big/count_big;
small_avg =  small/count_small;
total_avg = sum(C)/length(C);
plot([0,15000],[ total_avg, total_avg]) % not 100% correct due to windowing not being exact 
plot([0,15000],[ total_avg*0.999, total_avg*0.999]) % not 100% correct due to windowing not being exact 

error = 0;
for i = 1:length(message)-1
    if(true_message(i) ~= message(i+1))
        error = error+1;
        plot([i*bit_period*10^6,i*bit_period*10^6],[min(C),max(C)], 'red')
    else
        plot([i*bit_period*10^6,i*bit_period*10^6],[min(C),max(C)], 'black')
    end
end


 


end



