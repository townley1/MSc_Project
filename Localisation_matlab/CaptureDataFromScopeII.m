function waveform = CaptureDataFromScopeII(visaObj, channel, first, pointz)
if (first ==1)
    writeline(visaObj,':DIGITIZE');
end

if(channel == 1)
    fopen(visaObj);
    writeline(visaObj,':WAVEFORM:SOURCE CHAN1'); 
    % Set up acquisition type and count. 
    writeline(visaObj,':ACQUIRE:TYPE NORMAL');
    writeline(visaObj,':ACQUIRE:COUNT 1');
    % Specify 5000 points at a time by :WAV:DATA?
    writeline(visaObj,':WAV:POINTS:MODE RAW');
    writeline(visaObj,[':WAV:POINTS ', int2str(pointz)]); %16384 cut-off 25MHz
    % Now tell the instrument to digitize channel1
    % writeline(visaObj,':DIGITIZE CHAN1');

elseif (channel == 2) 
    fopen(visaObj);
    writeline(visaObj,':WAVEFORM:SOURCE CHAN2'); 
    % Set up acquisition type and count. 
    writeline(visaObj,':ACQUIRE:TYPE NORMAL');
    writeline(visaObj,':ACQUIRE:COUNT 1');
    % Specify 5000 points at a time by :WAV:DATA?
    writeline(visaObj,':WAV:POINTS:MODE RAW');
    writeline(visaObj,[':WAV:POINTS ', int2str(pointz)]); %16384 cut-off 25MHz
    % Now tell the instrument to digitize channel1
%     writeline(visaObj,':DIGITIZE CHAN2');

else
    fopen(visaObj);
    writeline(visaObj,':WAVEFORM:SOURCE CHAN3'); 
    % Set up acquisition type and count. 
    writeline(visaObj,':ACQUIRE:TYPE NORMAL');
    writeline(visaObj,':ACQUIRE:COUNT 1');
    % Specify 5000 points at a time by :WAV:DATA?
    writeline(visaObj,':WAV:POINTS:MODE RAW');
    writeline(visaObj,[':WAV:POINTS ', int2str(pointz)]); %16384 cut-off 25MHz
    % Now tell the instrument to digitize channel1
%     writeline(visaObj,':DIGITIZE CHAN3');
end


% Wait till complete
operationComplete = str2double(query(visaObj,'*OPC?'));
while ~operationComplete
    operationComplete = str2double(query(visaObj,'*OPC?'));
end
% Get the data back as a WORD (i.e., INT16), other options are ASCII and BYTE
writeline(visaObj,':WAVEFORM:FORMAT WORD');
% Set the byte order on the instrument as well
writeline(visaObj,':WAVEFORM:BYTEORDER LSBFirst');
% Get the preamble block
preambleBlock = query(visaObj,':WAVEFORM:PREAMBLE?');
% The preamble block contains all of the current WAVEFORM settings.  
% It is returned in the form <preamble_block><NL> where <preamble_block> is:
%    FORMAT        : int16 - 0 = BYTE, 1 = WORD, 2 = ASCII.
%    TYPE          : int16 - 0 = NORMAL, 1 = PEAK DETECT, 2 = AVERAGE
%    POINTS        : int32 - number of data points transferred.
%    COUNT         : int32 - 1 and is always 1.
%    XINCREMENT    : float64 - time difference between data points.
%    XORIGIN       : float64 - always the first data point in memory.
%    XREFERENCE    : int32 - specifies the data point associated with
%                            x-origin.
%    YINCREMENT    : float32 - voltage diff between data points.
%    YORIGIN       : float32 - value is the voltage at center screen.
%    YREFERENCE    : int32 - specifies the data point where y-origin
%                            occurs.
% Now send commmand to read data
writeline(visaObj,':WAV:DATA?');
% read back the BINBLOCK with the data in specified format and store it in
% the waveform structure. FREAD removes the extra terminator in the buffer
waveform.RawData = binblockread(visaObj,'uint16'); fread(visaObj,1);
% Read back the error queue on the instrument
instrumentError = query(visaObj,':SYSTEM:ERR?');
while ~isequal(instrumentError,['+0,"No error"' char(10)])
    %disp(['Instrument Error: ' instrumentError]);
    instrumentError = query(visaObj,':SYSTEM:ERR?');
end
% Close the VISA connection.
fclose(visaObj);



% Data processing: Post process the data retreived from the scope
% Extract the X, Y data and plot it 

% Maximum value storable in a INT16
maxVal = 2^16; 

%  split the preambleBlock into individual pieces of info
preambleBlock = regexp(preambleBlock,',','split');

% store all this information into a waveform structure for later use
waveform.Format = str2double(preambleBlock{1});     % This should be 1, since we're specifying INT16 output
waveform.Type = str2double(preambleBlock{2});
waveform.Points = str2double(preambleBlock{3});
waveform.Count = str2double(preambleBlock{4});      % This is always 1
waveform.XIncrement = str2double(preambleBlock{5}); % in seconds
waveform.XOrigin = str2double(preambleBlock{6});    % in seconds
waveform.XReference = str2double(preambleBlock{7});
waveform.YIncrement = str2double(preambleBlock{8}); % V
waveform.YOrigin = str2double(preambleBlock{9});
waveform.YReference = str2double(preambleBlock{10});
waveform.VoltsPerDiv = (maxVal * waveform.YIncrement / 8);      % V
waveform.Offset = ((maxVal/2 - waveform.YReference) * waveform.YIncrement + waveform.YOrigin);         % V
waveform.SecPerDiv = waveform.Points * waveform.XIncrement/10 ; % seconds
waveform.Delay = ((waveform.Points/2 - waveform.XReference) * waveform.XIncrement + waveform.XOrigin); % seconds

% Generate X & Y Data
waveform.XData = (waveform.XIncrement.*(1:length(waveform.RawData))) - waveform.XIncrement;
waveform.YData = (waveform.YIncrement.*(waveform.RawData - waveform.YReference)) + waveform.YOrigin; 

% Plot it
% plot(waveform.XData,waveform.YData);
% set(gca,'XTick',(min(waveform.XData):waveform.SecPerDiv:max(waveform.XData)))
% xlabel('Time (s)');
% ylabel('Volts (V)');
% title('Oscilloscope Data');
% grid on;


end