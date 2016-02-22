global s1
global subinfo
global parameters

%
[ParameterName,ParameterValue]=textread('Laptop_Client.Para','%s %s','commentstyle','matlab');
for i=1:length(ParameterName)
    eval(strcat('parameters.',strtrim(ParameterName{i}),'=',strtrim(ParameterValue{i}),';'));
end
parameters.EEGRecord_Path=strcat(parameters.Main_Path,'\',parameters.EEGRecord_Path);
% Initial
open_s1=0;
if exist('s1','var')
    if strcmpi(class(s1),'tcpip')
        if strcmpi(s1.Status,'closed')
            try
                set(s1,'InputBufferSize',8);
                fopen(s1);
                state=0;
            catch
                disp('Cannot connect server')
                return
            end
        else
            state=0;
        end
    else
        try
            s1=tcpip(parameters.IP,4000);
            set(s1,'InputBufferSize',8);
            pause(5);
            fopen(s1);
            state=0;
        catch
            disp('Cannot connect server')
            return
        end
    end
else
   try
        s1=tcpip(parameters.IP,4000);
        set(s1,'InputBufferSize',8);
        pause(5);
        fopen(s1);
        state=0;
   catch
        disp('Cannot connect server')
        return;
    end 
end
%
addpath(strcat(parameters.Main_Path,'\Laptop'))
cd ..
addpath(genpath(parameters.EEGRecord_Path));
%addpath(genpath(parameters.Baseline_Path));
disp('Start Task')
            prompt={'Name:',...
            'Task:',...
            'Day:',...
            'Trial Num:'};
            name='Experimental Information';
            numlines=1;
            defaultanswer={'','','',''};
            options.Resize='on';
            options.WindowStyle='normal';
            options.Interpreter='tex';

            subinfo=inputdlg(prompt,name,numlines,defaultanswer,options);

            while (isempty(subinfo{1})|| isempty(subinfo{2}) || isempty(subinfo{3}) || isempty(subinfo{4})) || (~ismember(subinfo{2},parameters.Task_List))
                subinfo=inputdlg(prompt,name,numlines,defaultanswer,options);
            end
            temp=strcat('task:',subinfo(2),':sub:',subinfo(1),':day:',subinfo(3));
                fprintf(s1,temp{1});
                pause(1);
                disp(temp)
            global currentpath;
                currentpath=cd;
                try
                    cd(parameters.EEGRecord_Path)
                    temp=cd;
                    while ~strcmpi(temp,parameters.EEGRecord_Path)
                        cd(parameters.EEGRecord_Path)
                        temp=cd;
                    end
                    %disp('start simulink')
                    %simulink;
                    pause(3);
                    disp('start')
                catch
                    disp('Sim Error')
                end  
%


% s1=tcpip('10.119.70.114',4000);
% s1=tcpip('192.168.0.100',4000);
% set(s1,'InputBufferSize',9);
% fopen(s1);
% t0=0;
[ParameterName,ParameterValue]=textread('EEGRecord.Para','%s %s','commentstyle','matlab');
for i=1:length(ParameterName)
    eval(strcat('parameters.',strtrim(ParameterName{i}),'=',strtrim(ParameterValue{i}),';'));
end
parameters.Sub_Task=subinfo{2};
parameters.Sub_Name=subinfo{1};
parameters.Sub_Day=subinfo{3};
parameters.Sub_Trial=subinfo{4};
global Data_Path
Data_Path=strcat(parameters.Main_Path,'\',parameters.Data_Folder,'\',parameters.Sub_Task,'\',parameters.Sub_Name,'\D',parameters.Sub_Day);
if ~exist(Data_Path)
    mkdir(Data_Path);
end

set_param(strcat(gcs,'/To File'),'FileName',strcat(Data_Path,'\',parameters.Sub_Name,'_',parameters.Sub_Trial,'.mat'));
%
fprintf(s1,'?');
% content='';
% content=fscanf(s1);content=content(1:end-1);
% while ~strcmpi(content,'!')
%     content='';
%     content=fscanf(s1);content=content(1:end-1);
% end
% fprintf(s1,'z');
% pause(3)
% fprintf(s1,'?');
global mystate 
mystate='start';
global transfer_state
transfer_state=1;
global Voice
for i=1:5
[y,fs]=wavread(strcat(parameters.Main_Path,'\',parameters.Voice_Path,'\',num2str(i),'.wav'));
Voice(i).y=y;
Voice(i).fs=fs;
end
[y,fs]=wavread(strcat(parameters.Main_Path,'\',parameters.Voice_Path,'\go.wav'));
Voice(6).y=y;
Voice(6).fs=fs;

% Fs=128;
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % PARAMETER
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ct_no=5;    %gaze_leng=gazing interval, rest_len=resting interval, ct_no=continuous discrimination times 
% buf_len=floor(3*Fs);    %construct a buffer, the length=gazing interval length-1s, when gaze_len=2s, buf_len=1s
% Nfft=4*Fs; %no. of fft points, triple of buf_len
% channelNum=4;   % no. of channels (electrodes)
% %stim_freq=[8 60/7 9 9.5 15.5 10.5 11 11.5 10 12.5 13 13.5 14 14.5 12 15];   %stimulus frequencies
% % stim_freq=[8 9 10 11 12 13 14 15 8.5 9.5 10.5 11.5 12.5 13.5 14.5 15.5];   %stimulus frequencies
% stim_freq=[12 13 14 15];
% % stim_freq=120./[7 8 9 10 11 13 15];
% threshold_value=0.2;
% f=(0:Nfft-1)*Fs/Nfft;   %frequency axis 768
% ts=1/Fs;    %sampling time
% tt=(0:ts:(buf_len-1)*ts);   %time axis which has the same length as buffer
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % CCA parameter
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% y_ref=zeros(length(stim_freq),buf_len,4);
% for k=1:length(stim_freq)   %from 1 to the no. of sti.
%     [min_v,fl(k)]=min(abs(f-1*stim_freq(k)));   
%     y_ref(k,:,:)=[sin(2*pi*stim_freq(k)*tt);cos(2*pi*stim_freq(k)*tt);sin(4*pi*stim_freq(k)*tt);cos(4*pi*stim_freq(k)*tt)]';
% end
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Phase Locking Index (PLI) parameter
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% pli_ch_no=3; % To indicate which channel is used to extract the PLI 
% pli_buf=zeros(ct_no,length(stim_freq));
% pli_scalar=10; 
% x_shift=0;
% trig_t=0;
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ybuffer=zeros(channelNum,buf_len);    %first 6 channel is signal, 
% cca_idx=zeros(ct_no,length(stim_freq)); %cca coefficient for every sti and , totally 5 times
% trig_label=64; % 64/256 = 0.25 s