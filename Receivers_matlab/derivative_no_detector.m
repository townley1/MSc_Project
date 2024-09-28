
true_message = readmatrix('bit_seq_thresh.txt');


C = readmatrix('25.txt')';
for i = 1:length(C)
    if(C(i) < max(C)+1 || C(i) > min(C)-1)
        continue
    else
        C(i) = C(i-1);
    end

end

j = 0;
fc = 13.56*10^6;
adc_cycles = 12.82;
ADC_period = 1/((84/(adc_cycles*4))*10^6);
bit_period = 4*512/fc; %%%%%%%%%%%%%%% weird
bit_samples = (bit_period/ADC_period);%244;%288; %7544;


time = 0:ADC_period:ADC_period*length(C);
figure;
plot(time(1:length(C))*10^6,C, 'cyan')
hold on 

confidence = 0; increment = 20;
message = zeros(1,98);
big = 0; small = 0; count_big = 0; count_small =0;
for i = 2:98 % break signal into sections 
    first_half = 0; second_half = 0; 
    c_1=0;c_0=0;
    start = floor((i-1)*bit_samples+1);
    middle = floor((i-1)*bit_samples) +floor(124);
    end_p = floor(i*bit_samples);

    for k = start:(start+140)
         if (diff(k) > 0 && diff(k+1) < 0) || (diff(k) < 0 && diff(k+1) > 0)
            temp1(j) = C(k);
            temp2(j) = C(k);
            j = j+1;

        end
    end
    for k = end_p:-1:(end_p - 140)
        if (diff(k) > 0 && diff(k+1) < 0) || (diff(k) < 0 && diff(k+1) > 0)
            temp3(jj) = C(k);
            temp4(jj) = C(k);
            jj = jj+1;
        end
    end

    t(i) = c_0+c_1;
    if(c_0 < c_1)
        message(i) = 0;
    else
        message(i) = 1;
    end

end

y = sort(t);

plot([99*bit_period*10^6,99*bit_period*10^6],[min(C),max(C)], 'black')
error = 0;
for i = 1:length(message)
    if(true_message(i) ~= message(i))
        error = error+1;
        plot([i*bit_period*10^6,i*bit_period*10^6],[min(C),max(C)], 'red')
    else
        plot([i*bit_period*10^6,i*bit_period*10^6],[min(C),max(C)], 'black')
    end
end
error
confidence
message1 = [message; true_message(1:length(message))];


xlabel('time us')



