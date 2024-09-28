
%load true message
true_message = readmatrix('bit_sequence.txt');

for xx = 25:25
    S = [int2str(xx), '.txt'];
%     C = readmatrix('data.txt')';
    C = readmatrix('data.txt')';

for i = 1:length(C) % get rid of NAN's
    if(C(i) < max(C)+1 || C(i) > min(C)-1)
        continue
    else
        C(i) = C(i-1);
    end

end
figure
[b, a] = butter(3, 0.05);
% [b,a] = cheby2(5,65,0.1);
C = round(filter(1, a,C));


fc = 13.56*10^6;
adc_cycles =12.815;
ADC_period = 1/((84/(adc_cycles*4))*10^6);
bit_period = 4*512/fc; %%%%%%%%%%%%%%% weird
bit_samples = (bit_period/ADC_period);%244;%288; %7544; 247.59

time = 0:ADC_period:ADC_period*length(C);

highh = zeros(124,1);
lowww = zeros(124,1);
increment = 40;
message = zeros(1,99);
message(1) = 1;
message(2) = 0;
diff = ones(1,28318);
envelope = ones(1,2510);
base_envelope = ones(1,2510);
first_half = 0; second_half = 0;
j = 1;
for i = 2:98 % break signal into sections 
    first_half = 0; second_half = 0;


    start = floor((i-1)*bit_samples+1) ;
    middle = floor((i-1)*bit_samples) +(124) ;
    end_p = floor(i*bit_samples) ;


    k = start;
    while k < middle
        high_val = k+(increment-1);
        if( high_val>middle)
            high_val = middle;
        end
        max_10 = max(C(k:high_val));
        envelope(k:high_val) = max_10; 
        min_10 = min(C(k:high_val));
        base_envelope(k:high_val) = min_10; 
        first_half = first_half+abs(max_10 - min_10);
        k = k+increment;
    end
    k=middle;
    while k< end_p
        high_val = k+(increment-1);
        if( high_val>end_p)
            high_val = end_p;
        end
        max_10 = max(C(k:high_val));
        envelope(k:high_val) = max_10; 
        min_10 = min(C(k:high_val));
        base_envelope(k:high_val) = min_10; 
        second_half = second_half+abs(max_10 - min_10);
        k = k+increment;
    end

    t(1,i-1) = first_half;
    t(2,i-1) = second_half;
  
    
    if (first_half > second_half)
        message(i) = 0;
        highh = [highh; C(start:middle)];
        lowww = [lowww; C(middle:end_p)];
        t(3,i) = 0;
            i;

    else 
    message(i) = 1;
    highh = [highh; C(middle:end)];
        lowww = [lowww; C(start:middle)];
        i;

    end


end
% v = sort(t(3,1:98));
error = 0;hold on
for i = 1:length(message)
    if(true_message(i) ~= message(i))
        error = error+1;
        plot([i*bit_period*10^6,i*bit_period*10^6],[min(C),max(C)], 'red')
    else
        plot([i*bit_period*10^6,i*bit_period*10^6],[min(C),max(C)], 'black')
    end
end
message1 = [message; true_message(1:length(message))];
x = time(1:length(envelope));
plot(x*10^6,envelope, 'green')
x = time(1:length(base_envelope));
plot(x*10^6,base_envelope, 'green')
plot(time(1:length(C))*10^6,C, 'cyan')


end

