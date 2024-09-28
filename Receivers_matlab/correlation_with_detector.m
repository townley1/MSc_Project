

true_message = readmatrix('bit_sequence.txt');
for xx = 3:3 %goes up to 13
    S = [int2str(xx), '.txt'];
    C = readmatrix('data.txt')';
%     C = C(2,:);
%     C = readmatrix('withdetector_5cm_lc.txt')';
    for i = 1:length(C) % get rid of NAN's
        if(C(i) < max(C)+1 || C(i) > min(C)-1)
            continue
        else
            C(i) = C(i+1);
        end
    
    end
    [b, a] = butter(3, 0.05);

   % a = a*100;
    threshold_v = 0;

    
    fc = 13.56*10^6;
    adc_cycles =12.8;
    ADC_period = 1/((84/(adc_cycles*4))*10^6);
    bit_period = 4*512/fc; %%%%%%%%%%%%%%% weird
    bit_samples = 247.4;%(bit_period/ADC_period);%244;%288; %7544; 247.59
    
    time = 0:ADC_period:ADC_period*length(C);
%     figure;
    plot(time(1:length(C))*10^6,C,'cyan')
    
    hold on 
    
    
    confidence = 0; increment = 3;
    message = zeros(1,98);
    message(1) = 1;
    message(2) = 0;
    past_1 = 0; past_2 = 0;
    temp1 = [0,0,0];
    first_half = 0; second_half = 0; eof = 0;
    for i = 2:101 % break signal into sections 
        first_half_p = first_half;
        second_half_p = second_half;
        first_half = 0; second_half = 0; eof = 0;    
        start = floor((i-1)*bit_samples+1);
        middle = floor((i-1)*bit_samples) +floor(124);
        end_p = floor(i*bit_samples);
    
        k = start;
        while k <= middle
            max_10 = max(C(k:k+(increment-1)));
            first_half = first_half+max_10;
            k = k+increment;
        end
        k=middle;
        while k<= end_p
            max_10 = max(C(k:k+(increment-1)));
            second_half = second_half+max_10;
            k = k+increment;
        end
    
        t(1,i) = first_half;
        t(2,i) = second_half;

            if (first_half > second_half)
                message(i) = 1;
                t(3,i) = (past_2 - first_half);
                if(t(3,i) > 0.018 && i>24 && message(i-1) == 0)
                    i;
                end
                
                past_2 = past_1;
                past_1 = second_half;
                confidence = confidence + abs(first_half - max(second_half, eof)) / first_half;
            else 
                message(i) = 0;
                t(3,i) = (past_2 - second_half);
                if(t(3,i) > 0.018 && i>24 && message(i-1) == 0)
                    i;
                end               
                confidence = confidence + abs(second_half - max(first_half, eof)) / second_half;
                past_2 = past_1;
                past_1 = first_half;
            end
    
    end

    C = filter(b,a,C);
    plot(time(1:length(C))*10^6,C, 'red')
    error = 0;
    for i = 1:98
        if(true_message(i) ~= message(i))
            error = error+1;
        end
        if (true_message(i) == 1)
            plot([i*bit_period*10^6,i*bit_period*10^6],[min(C),max(C)+100], 'black')
        else
            
              plot([i*bit_period*10^6,i*bit_period*10^6],[min(C),max(C)+100], 'black')
        end
    end
        legend('Original', 'Filtered')

    xlim([bit_samples*11, bit_samples*19])

    if(error >1)
        disp(error)
    else
        disp(['Good'])
    end

    mess = [message(1:100);true_message];

end


