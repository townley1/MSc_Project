
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% COLLECT DATA FROM SCOPE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



% to load once 
% inst = myScopeInitialise;
% 
% message = 'antenna9_100M_det_move_'; %antenna and sampling rate, end with underscore, p means point
% % % message = 'test'; %antenna and sampling period, end with underscore, p means point
% for i = 1:100
% 
%     waveform1 = CaptureDataFromScopeII(inst, 1, 1, 100000);
%     waveform3 = CaptureDataFromScopeII(inst, 2, 2, 100000);
% 
%     x1 = waveform1.XData;
%     T = (x1(end) - x1(1))/length(x1);
%     1/T;
%     
%     S1 = [message,'in_',int2str(i)] ;
%     S2 = [message,'out_',int2str(i)];
% 
%     save(S1, "waveform3")
%     save(S2, "waveform1")
%     
%     pause(1);
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PLOT DATA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % 
% % 
% % %%% USE 7 AND HAVE THE 4th  AS MID POINT, i.e. use that as zero time
% % %%% difference
% 
% 
% 
% % true_time_diff = [5.6e-,-550,-380,-320,0,210,350,400, 640].*10^-9;
% true_delay = [-940,-550,-380,-320,0,210,350,400, 640].*10^-9;
% error_time_diff = zeros(1,9);
% error_delay = zeros(1,9);
% vc = 1;
% fr_sampling = zeros(1,9);
% fr2_sampling = zeros(1,9);
% sampling_rates = [1, 2, 4, 5, 10, 20, 25, 50, 100];
% filter_order =   [5,5, 5, 5,  6,  7,  7, 8, 10];
% % figure
% for sampling_rate_MHz = 100%sampling_rates
% 
%     prescaler = 100/sampling_rate_MHz;
%     delay = zeros(9,10);
%     time_difference = zeros(9,10);
% 
%     for j =  1
%         for k = 1:5
%         %% load waveform
%             message = ['antenna',int2str(j),'_100M_det__diff_heights'];
%             S = [message,'in_',int2str(k), '.mat'];
%             c1Temp = load(S)';
%             S = [message,'out_',int2str(k), '.mat'];
%             c2Temp = load(S)';
%             c1 = c1Temp.waveform3.YData;
%             c2 = c2Temp.waveform1.YData;      
%             x1 = c1Temp.waveform3.XData;
%             x2 = c2Temp.waveform1.XData;
% 
%             if (k == 5)
%                 c1 = c1*-1;
%             end
% 
% 
% 
%        
%         
%         % apply prescaler
%         c1 = c1(1:prescaler:end);
%         c2 = c2(1:prescaler:end);
%         x1 = x1(1:prescaler:end);
%         x2 = x2(1:prescaler:end);
%         
%         
%         T = (x1(end) - x1(1))/length(x1);
%         
%         [b, a] = butter(5, 0.05);
%         b = fir1(filter_order(vc),0.000000001);
%                 b = fir1(20,0.000000001);
% 
% %         b = fir1(20,0.0001);
% %         b = fir1(3,0.0001);
%           a =1;
%         c1 = filter(b,a,c1);
%         c2= filter(b,a,c2);
% 
% %             c1 = bandpass(c1, [300,500].*10^3,1/T);
% %             c2 = bandpass(c2, [300,500].*10^3,1/T);
% %% FFT
% %         y1 =  fftshift(fft(c1));
% %         y2 =  fftshift(fft(c2));
% %         for b = 1:length(y1)
% %             if(b > 52086 || b <47900)
% %                 y1(b) = 0;
% %                 y2(b) = 0;
% %             end
% %         end
% % %         figure
% % %         plot(1:length(y1),10*log10(y1))
% % %         figure 
% % %         plot(1:length(y1),10*log10(y2))
% % %         figure
% %         c1 = ifft(fftshift(y1));
% %         c2 = ifft(fftshift(y2));
% 
%         
% %% CORRELATOR
% 
% %         
% %         c2 = c2(10187:23509);
% %         c1 = c1(10187:23509);
%         [rho, phval] = xcorr(c2,c1, 60);
%         [maxi,index]  = max(abs(rho));
%         delay(j,k) = -1*phval(index) *T;
% %          error_delay(j) =  error_delay(j) + abs(true_delay(j) - (in2 - in1));
% %         figure
% %         stem(phval,rho)
%         
%         
%         %%%% THRESHOLDING
%         threshold1 = 0.015; %mean(c1(1:1e4))*10;
%         threshold2 = -0.015; %mean(c2(1:1e4))/10;
%         i = 10;
%         found = 0;
%         in1 = 0; in2 = 0;
%         while found < 2 && i <length(c1)
%             if(c2(i)<threshold2 && in1 ==0)
%                 found = found+1;
%                 in1 = x2(i);
%                 in11 = i;
%             end
%             if(c1(i) > threshold1 && in2 == 0)
%                 in2 = x1(i);
%                 found = found+1;
%                 in23 = i;
%             end
%             i = i+1;
%         end
%         time_difference(j,k) = in2- in1;
% %         error_time_diff(j) =  error_time_diff(j) + abs(true_time_diff(j) - (in2 - in1));
%         time_diff2 = (in23 - in11) * T;
%         
% 
% 
% %% plot scope data 
%         figure 
%         plot(1:length(x1),c1, 'cyan')
%         hold on
%         plot(1:length(x2),c2,'red')        
%         plot([x1(1),x1(end)], [threshold1, threshold1], 'cyan')
%         plot([x2(1),x2(end)], [threshold2, threshold2])
%         
%         end
%     end
% 
%     %% fishers ratio
%     fr = zeros(1,9);
%     t = 1;
%     for i =1:9
%         mean1 = mean(time_difference(i,:));
%         var1 = var(time_difference(i,:));
%         if(i~= 9)
%             mean2 = mean(time_difference(i+1,:));
%             var2 = var(time_difference(i+1,:));
%             fr(i) = (mean1 - mean2)^2 / (var1+var2);
%             t = 2;
%         end
%         if(i ~=1)
%             mean3 = mean(time_difference(i-1,:));
%             var3 = var((time_difference(i-1,:)));
%              fr(i) = (fr(i) + (mean1 - mean3)^2 / (var1+var3))/t;
%         end
%     end
%     fr_sampling(vc) = mean(fr);
% 
%     %% distance between means
%     fr2 = zeros(1,9);
%     t = 1; temp = 1; 
%     for i =1:9
%         temp1 = 0; temp2 = 0;
%         mean1 = mean(delay(i,:));
%         var1 = var(delay(i,:));
%         if(i~= 9)
%             mean2 = mean(delay(i+1,:));
%             temp1 = (mean1 - mean2)^2 ;
%             t = 2;
%         end
%         if(i ~=1)
%             mean3 = mean(delay(i-1,:));
%              temp2=   (mean1 - mean3)^2;
%         end
%         fr2(i) = min(temp1,temp2);
%     end
%     fr2_sampling(vc) = (mean(fr2));
% 
%     vc = vc+1;
% 
% end
% colus = ["#e70e1b", "#e70ebd", "#7b0ee7", "#0eb2e7", "#0ee7d9", "#0ee769", "#1c850b", "#dacd11", "#ee5613"];
% 
% 
% 
% %% delay all loops and iterations
% figure
% hold on 
% for i = [1,3,5,7]
% plot(1:10, delay(i,:))
% end
% legend('loop 1',  'loop 3',  'loop 5',  'loop 7')
% xlabel('Iteration Number')
% ylabel('Measured Delay')
% 
% % time difference all loops and iterations
% figure
% hold on 
% for i = 1:9
% plot(1:10, time_difference(i,:))
% end
% legend('loop 1', 'loop 2', 'loop 3', 'loop 4', 'loop 5', 'loop 6', 'loop 7',  'loop 8','loop 9')
% xlabel('Iteration Number')
% ylabel('Measured Time Difference')



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% PLOT DATA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% difference

figure
true_delay = [-940,-550,-380,-320,0,210,350,400, 640].*10^-9;
error_time_diff = zeros(1,9);
error_delay = zeros(1,9);
vc = 1;
fr_sampling = zeros(1,9);
fr2_sampling = zeros(1,9);
sampling_rates = [1, 2, 4, 5, 10, 20, 25, 50, 100];
filter_order =   [10,10, 10, 15,  15,  20,  20, 25, 30];
error_rate_time_diff = zeros(1,9);
error_rate_delay = zeros(1,9);
for sampling_rate_MHz = sampling_rates

    prescaler = 100/sampling_rate_MHz;
    delay = zeros(9,100);
    time_difference = zeros(9,100);
    toa1 =  zeros(9,100);
    m = 1;
    for j = [1:9]
        for k = 1:100
        %% load waveform
        message = ['antenna',int2str(j),'_100M_det_move_'];
        S = [message,'out_',int2str(k), '.mat'];
        c1Temp = load(S)';
        S = [message,'in_',int2str(k), '.mat'];
        c2Temp = load(S)';
        c1 = c1Temp.waveform1.YData;
        c2 = c2Temp.waveform3.YData;      
        x1 = c1Temp.waveform1.XData;
        x2 = c2Temp.waveform3.XData;
        
        % apply prescaler
        c1 = c1(1:prescaler:end);
        c2 = c2(1:prescaler:end);
        x1 = x1(1:prescaler:end);
        x2 = x2(1:prescaler:end);
        
        T = (x1(end) - x1(1))/length(x1);

        %% filter
        b = fir1(10,0.000000001);
        a =1;
        c1 = filter(b,a,c1);
        c2= filter(b,a,c2);


        
%% CORRELATOR
        [rho, phval] = xcorr(c2,c1, 140);
        [maxi,index]  = max(abs(rho));
        delay(j,k) = -1*phval(index)*T;
        
        
        %% THRESHOLDING
        threshold1 = 0.05; 
        threshold2 = -0.05;
        i = 10;
        found = 0;
        in1 = 0; in2 = 0;
        while found < 2 && i <length(c1)
            if(c2(i)<threshold2 && in1 ==0)
                found = found+1;
                in1 = x2(i);
                in11 = i;
            end
            if(c1(i) > threshold1 && in2 == 0)
                in2 = x1(i);
                found = found+1;
                in23 = i;
            end
            i = i+1;
        end
        time_difference(j,k) =  in2 - in1;
        toa1(j,k) = in1;
%         error_time_diff(j) =  error_time_diff(j) + abs(true_time_diff(j) - (in2 - in1));
        time_diff2 = (in23 - in11) * T;
        


%% plot scope data 

%         subplot(1,2,m)
%         plot((1:length(x1)).*T*10^6,c1, 'cyan')
%         hold on
%         plot((1:length(x2)).*T*10^6,c2,'red')
%                 fontsize(gcf,14,"points")
%                 if(m==2)
%         legend('Output 1', 'Output 2', 'FontSize',12) % output 1 is from end of antenna
%                 end
%         xlim([46,54])
%         S = ['Signals Received When VICC Is At Loop ',int2str(j)];
%         title(S, 'FontSize',14)
%         xlabel('Time (\mus)', 'FontSize',14)
%         ylabel('Voltage (V)', 'FontSize',14)

       
%         hold on
%         fontsize(gcf,14,"points")
%         plot((1:length(x1)).*T*10^6,c1, 'cyan')
%         
%         plot((1:length(x2)).*T*10^6,c2,'red')
%         
%         
%         legend('Output 1', 'Output 2') % output 1 is from end of antenna
%         S = ['Two Signals Received From Antenna When VICC Is 1cm From Loop ',int2str(j)];
%         title(S, 'FontSize',14)
%         xlabel('Time (\mus)', 'FontSize',14)
%         ylabel('Voltage (V)', 'FontSize',14)
%         
       m=m+1;



        
        end
    end

    %% pick number of loops
    num_loops = 9;


    if(num_loops == 5)
        temp = [1,3,5,7,9];
    elseif (num_loops == 3)
        temp = [1,5,7];
    else
        temp = 1:9;
    end
    time_difference = time_difference(temp,:);
    delay = delay(temp,:);
    %% fishers ratio
    fr_sampling(vc) = fishers(time_difference, num_loops);
    fr2_sampling(vc) = fishers(delay,num_loops);



%% get classification error and plot confusion matrix
%     figure
%     subplot(1,2,1)
    error_rate_delay(vc) = oob(delay, 9);
%     title('Confusion Matrix For Cross Correlator')
%     subplot(1,2,2)
    error_rate_time_diff(vc) = oob(time_difference, 9);
%         title('Confusion Matrix For Threshold System')
%         fontsize(gcf,14,"points")

error_rate_toa(vc) = oob(toa1, num_loops);

%% 5 loops 
        num_loops = 5;
    time_difference2 = time_difference([1,3,5,7,9],:);
    delay2 = delay([1,3,5,7,9],:);
    fr_sampling3(vc) = fishers(time_difference2, num_loops);
    fr2_sampling3(vc) = fishers(delay2,num_loops);
    error_rate_delay3(vc) = oob(delay2, num_loops);
    error_rate_time_diff3(vc) = oob(time_difference2, num_loops);
    toa11 = toa1([1,3,5,7,9],:);
    error_rate_toa2(vc) = oob(toa11, num_loops);

%% 3 loops 
        num_loops = 3;
    time_difference3 = time_difference([1,5,9],:);
    delay3 = delay([1,5,9],:);
    fr_sampling2(vc) = fishers(time_difference3, num_loops);
    fr2_sampling2(vc) = fishers(delay3,num_loops);
    error_rate_delay2(vc) = oob(delay3, num_loops);
    error_rate_time_diff2(vc) = oob(time_difference3, num_loops);

toa12 = toa1([1,5,9],:);
    error_rate_toa3(vc) = oob(toa12, num_loops);


    vc = vc+1;


end
colus = ["#e70e1b", "#e70ebd", "#7b0ee7", "#0eb2e7", "#0ee7d9", "#0ee769", "#1c850b", "#dacd11", "#ee5613"];
mean(time_difference')
mean(delay')

%% time difference all loops and iterations
% figure
% hold on 
% for i = 1:9
% plot(1:length(time_difference(i,:)), time_difference(i,:))
% end
% legend('loop 1', 'loop 2', 'loop 3', 'loop 4', 'loop 5', 'loop 6', 'loop 7',  'loop 8','loop 9')
% xlabel('Iteration Number')
% ylabel('Measured Time Difference')
% ylim([-1.5*10^-6,1.5*10^-6])
% 
%% delay all loops and iterations
% figure
% hold on 
% for i = 1:9
% plot(1:length(time_difference(i,:)), delay(i,:))
% end
% legend('loop 1', 'loop 2', 'loop 3', 'loop 4', 'loop 5', 'loop 6', 'loop 7',  'loop 8','loop 9')
% xlabel('Iteration Number')
% ylabel('Measured Delay')
% ylim([-1.5*10^-6,1.5*10^-6])


%% all loops 1 iteration
% figure
% plot(1:9, time_difference(:,1))
% hold on 
% plot(1:9, delay(:,1))
% legend('Threshold', 'Correlator')


%% sampling error
% figure
% sampling_rate = [1, 2, 4, 5, 10, 20, 25, 50, 100];
% plot(sampling_rate, error_sample_rate_time_diff)
% hold on
% plot(sampling_rate, error_sample_rate_delay)
% xlabel('Sampling rate')
% ylabel('Average Error')

%% fishers ratio 

% figure
% % subplot(2,1,1)
% loglog(sampling_rates,10*log10(fr_sampling), 'blue')
% hold on
% loglog(sampling_rates,10*log10(fr2_sampling), 'red')
% 
% ylim([0,20])
% title('Fishers Discriminant Ratio For The 9-Loop Classification Systems')
% xlabel('Sampling Frequency (MHz)')
% ylabel('Fishers Discriminant Ratio (dB)')
% fontsize(gcf,14,"points")
% legend('Thresholding' ,'Cross-Correlation','FontSize',14)
% xticks([1,2,4,5,10,15,20,25,50,100])
% yticks([1,5,10,15,20])
% 
% figure
% % subplot(2,1,1)
% loglog(sampling_rates,10*log10(fr_sampling3), 'blue')
% hold on
% loglog(sampling_rates,10*log10(fr_sampling2), 'cyan')
% loglog(sampling_rates,10*log10(fr2_sampling3), 'red')
% loglog(sampling_rates,10*log10(fr2_sampling2), 'm')
% ylim([0,30])
% title('Fishers Discriminant Ratio For 3-Loop and 5-Loop Classification Systems')
% xlabel('Sampling Frequency (MHz)')
% ylabel('Fishers Discriminant Ratio (dB)')
% fontsize(gcf,14,"points")
% legend('Thresholding: 5 Loops','Thresholding: 3 Loops', 'Cross Correlation: 5 Loops', 'Cross Correlation: 3 Loops','FontSize',12)
% xticks([1,2,4,5,10,15,20,25,50,100])


%% data line
% figure
% subplot(2,1,1)
% hold on 
% for i = 1:9
% scatter(time_difference(i,:)*10^6,zeros(1,100)+i,  'filled',MarkerFaceColor= colus(i))
% end
% plot(-0.9: 0.175:0.5, [9,8,7,6,5,4,3,2,1])
% fontsize(gcf,14,"points")
% xlabel('Time Difference (\mus)', 'FontSize',14)
% title('TDOA Measured At Each Loop (Thresholding)', 'FontSize',14)
% ylabel('Loop Number', 'FontSize',14)
% xlim([-1,0.8])
% yticks([1:9])
% grid on
% 
% subplot(2,1,2)
% hold on 
% for i = 1:9
% scatter(delay(i,:)*10^6,zeros(1,100)+i,  'filled',MarkerFaceColor= colus(i))
% end
% plot(-0.75: 0.193:0.8, [9,8,7,6,5,4,3,2,1])
% % legend('loop 1', 'loop 2', 'loop 3', 'loop 4', 'loop 5', 'loop 6', 'loop 7',  'loop 8','loop 9', 'FontSize',11)
% fontsize(gcf,14,"points")
% xlabel('Time Difference (\mus)', 'FontSize',14)
% title('TDOA Measured At Each Loop (Cross-Correlation)', 'FontSize',14)
% ylabel('Loop Number', 'FontSize',14)
% xlim([-1,0.8])
% yticks([1:9])
% grid on


%% PERFORM BAGGING
% figure
% loglog(sampling_rates,(error_rate_time_diff + 10^-6).*100, 'blue')
% hold on 
% loglog(sampling_rates, (error_rate_delay + 10^-6).*100, 'red')
% ylabel('Classification Error Rate (%)')
% title('Error Rate For The 9-Loop Classification Systems')
% xlabel('Sampling Frequency (MHz)')
% xticks([1,2,4,5,10,15,20,25,50,100])
% fontsize(gcf,14,"points")
% legend('Thresholding' ,'Cross-Correlation','FontSize',12)
% 
% 
% figure
% loglog(sampling_rates, (error_rate_time_diff3 + 10^-6).*100, 'blue')
% hold on 
% loglog(sampling_rates, (error_rate_time_diff2 + 10^-6).*100, 'cyan')
% loglog(sampling_rates, (error_rate_delay3 + 10^-6).*100, 'red')
% loglog(sampling_rates, (error_rate_delay2 + 10^-6).*100, 'm')
% ylabel('Classification Error Rate (%)')
% xlabel('Sampling Frequency (MHz)')
% title('Error Rate For 3-Loop and 5-Loop Classification Systems')
% fontsize(gcf,14,"points")
% legend('Thresholding: 5 Loops','Thresholding: 3 Loops', 'Cross Correlation: 5 Loops', 'Cross Correlation: 3 Loops', 'FontSize',12)
% xticks([1,2,4,5,10,15,20,25,50,100])
% ylim([10^-1,10^2])



%% frequency polygon
% figure
% m = 1;
% for j  =1:9
%     c1 = delay(j,:);
%     z = 100;
%     x = -14:14;
%     y = zeros(1,length(x));
%     for i = x
%         y(i-x(1)+1) = sum(c1 == i)/z;
%     end
%     for i = 1:length(y)-1
%         if((y(i+1) == 0 && y(i) ~=0 ))
%             x(i+1) = x(i);
%         end
%         if((y(i+1) ~=0 && y(i) == 0))
%             x(i+1) = x(i);
%         end
%     end
%     b = x -x(round(length(x)/2));
%     plot(b.*T,y, 'color',colus(m)) 
%     hold on
%     m = m+1;
% end
% title('Frequency polygon')