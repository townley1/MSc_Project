
true_message = readmatrix('bit_sequence.txt');


for xx = 25:25 %26
    S = [int2str(xx), '.txt'];
    C = readmatrix('data.txt')';
for i = 1:length(C) % get rid of NAN's
    if(C(i) < max(C)+1 || C(i) > min(C)-1)
        continue
    else
        C(i) = C(i-1);
    end

end

[b, a] = butter(3, 0.05);
C = round(filter(1, a, C));


fc = 13.56*10^6;
adc_cycles =12.815;
ADC_period = 1/((84/(adc_cycles*4))*10^6);
bit_period = 4*512/fc; %%%%%%%%%%%%%%% weird
bit_samples = 247.594;%(bit_period/ADC_period);%244;%288; %7544; 247.59


time = 0:ADC_period:ADC_period*length(C);
figure;

hold on 
plot(time(1:length(C))*10^6,C, 'red')
temp = 0;
count =0;

for i = 1:length(C)
    if(C(i) ==0)
        count = count+1;
    end
end


confidence = 0; increment = 20;
message = zeros(1,99);
message(1) = 1;
message(2) = 0;
count1 = 1; count2 = 1;
big = ones(1,100);t = zeros(2,100);
small = ones(1,100);
diff = ones(1,28318);
envelope = ones(1,2510);
base_envelope = ones(1,2510);
first_half = 0; second_half = 0; first_half_low = 0; second_half_low = 0; 
j = 1;
for i = 2:98 % break signal into sections 
    first_half = 0; second_half = 0; first_half_low = 0; second_half_low = 0; 
    start = floor((i-1)*bit_samples+1);
    middle = floor((i-1)*bit_samples) +floor(124);
    end_p = floor(i*bit_samples);

    k = start;
    while k <= middle
        max_10 = max(C(k:k+(increment-1)));
        envelope(k:(k+increment-1)) = max_10; 
        min_10 = min(C(k:k+(increment-1)));
        base_envelope(k:(k+increment-1)) = min_10; 
        first_half = first_half+max_10;
        first_half_low = first_half_low+min_10;
        k = k+increment;
    end
    k=middle;
    while k<= end_p
        max_10 = max(C(k:k+(increment-1)));
        envelope(k:(k+increment-1)) = max_10; 
        min_10 = min(C(k:k+(increment-1)));
        base_envelope(k:(k+increment-1)) = min_10; 
        second_half = second_half+max_10;
        second_half_low = second_half_low+min_10;
        k = k+increment;
    end
    
    confidence_low = abs(second_half_low - first_half_low);
    confidence_high = abs(second_half - first_half);

    if( confidence_high > confidence_low)
        if(first_half>second_half)
            message(i) = 0;
            t(1,count1) = (second_half+first_half)*first_half;
        else
            message(i) =1;
            t(1,count1) = (second_half+first_half)*second_half;
        end
        count1=count1+1;
    else
        if(first_half_low<second_half_low) 
            message(i) = 0;
            t(2,count2) = (second_half_low+first_half_low)*first_half_low;
        else
            message(i) =1;
            t(2,count2) = (second_half_low+first_half_low)*second_half_low;
        end
        count2 = count2+1;
    end
end
error = 0;
for i = 1:length(message)
    if(true_message(i) ~= message(i))
        error = error+1;
        plot([i*bit_period*10^6,i*bit_period*10^6],[min(C),max(C)], 'red')
    else
        plot([i*bit_period*10^6,i*bit_period*10^6],[min(C),max(C)], 'black')
    end
end
message1 = [message; true_message(1:length(message))];


end




