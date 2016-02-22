%N-back 
%simple exposure to 1,2 and 3 back
%subject must respond to every stimulus
%give them a hint and say that there is only one hit
%hit=h (for present, i.e. a 3 back response is present)
%miss=f (for fail to hit)
%check location on the keyboard
%can randomize these???

%after this they get baseline assessment (should be no difference between
%the group)
%then trainng with DC stimulation
%then test to assess the effects of DC stimulation

%%
clc
clear
% addpath(genpath('C:/Users/BMElab/Desktop/EEG Record Program_NBack/Cog2000v133'));
rand('state',sum(100*clock));%set random number generator
format('shortG')

%% Input variables

parameters.name=input('Enter subject name (e.g piki)? ','s');
switch parameters.name
    case ''
        disp('No subject name entered')
        return
end
parameters.session=input('Enter section number (e.g 01)? ');
switch parameters.session
    case []
        disp('No section number entered')
        return
end
% parameters.session=1;

parameters.subj_code=[date '_' parameters.name '_session' num2str(parameters.session)];
subj_code=parameters.subj_code;

%% variable options

[ParameterName,ParameterValue]=textread('parameter.txt','%s %s','commentstyle','matlab');
for i=1:length(ParameterName)
    eval(strcat('parameters.',strtrim(ParameterName{i}),'=',strtrim(ParameterValue{i}),';'));
end
% parameters.trials=10;
% parameters.hitnum=1; %how many hits required at least
% parameters.letters={'q','w','y','z','m'};
% parameters.ITI=1500; % "+" display time
% parameters.stim_dur=500; % "character display time
% parameters.resp_button=[6, 8];
% parameters.blocks=3;

%% Cogent start
config_display(parameters.displaymode,parameters.resolution)
config_keyboard
start_cogent;
%%
cgpencol(1,1,1)
cgfont('Arial', 30)
cgtext('Researcher - Wait...',0,0);
cgflip(0,0,0);
%% TCP/IP
% s1=tcpip('192.168.0.20',4000, 'NetworkRole', 'Server');
% set(s1,'InputBufferSize',9);
% fopen(s1);
% disp('open')
% content=fread(s1,1);
% while content~=90
%     content=fread(s1,1);  
% end
disp('Start')

%% Instructions

cgpencol(1,1,1) %change the text
cgfont('Arial', 20)
cgtext('Welcome to the N-Back training session!',0,75);
cgtext('The N-Back tests your ability to maintain items in memory.',0,50);
cgtext('You must quickly update your memory by forgetting irrelevant letters.',0,25);
cgtext('Respond to all letters, (H) is for hit, (F) is for fail to hit!.',0,-25);
cgtext('Respond as quickly and as accurately as possible.',0,-50);
cgtext('Responses during the fixation are permitted.',0,-75);

cgtext('Press space to continue or esc to quit',0,-150);
cgflip(0,0,0);
k=waitkeydown(inf,[52 71]);
if k(1)==52
%     fclose(s1);
    stop_cogent; cgshut; clear; clc;return;
end


% parameters.hitnum=1;
% results.rep(1:3,1)=0;
%% task block loop
for k1=parameters.min_back%:parameters.max_block
    repeat_track=0;

    totlets=repmat(parameters.letters,1,(parameters.trials/length(parameters.letters)));
    
    %% task start
    success=0;
    while success==0
        
        looptracker=0;
        Proceed=0;
        while Proceed==0
            r=randperm(length(totlets));
            parameters.numorder=totlets(r)';
            results.shudaprsd(1:parameters.trials,1)=0;
            parameters.trial_letter=parameters.numorder;
            for j3=k1+1:parameters.trials  %
                if parameters.trial_letter{j3,1}==parameters.trial_letter{j3-k1,1}
                    results.shudaprsd(j3,1)=1; %shows where the correct answers were
                else
                    results.shudaprsd(j3,1)=0;
                end 
            end          
            % hitnum setting
            if k1==1
                if sum(results.shudaprsd(:,1))>0
                    Proceed=1;
                end
            elseif k1>1
                if sum(results.shudaprsd(:,1))<parameters.hitnum
                    Proceed=0;
                else%if sum(results.shudaprsd(:,1))==parameters.hitnum
                    Proceed=1;
                end
            else
                Proceed=1;
            end
            looptracker=looptracker+1;
        end
        
        %%
        results.key_press(1:parameters.trials,1)=0;
        cgfont('Arial', 30)
        cgpencol(1,1,1)
        
        cgfont('Arial', 20)
        cgtext(sprintf('Now try the %d-back!',k1),0,50);
        cgtext('Hit the (H) button when...',0,25);
        cgtext(sprintf('the onscreen letter is the same as the letter %d-back.',k1),0,0);
        cgtext('e.g.  A B A C D A A ',0,-50);
        if k1==1
            cgtext('i.e. when a letter repeats itself straight away.',0,-25);
            cgtext('Here, hit (H) when the letter A repeats at the end, otherwise press (F)',0,-75);
        elseif k1==2
            cgtext('Here, hit (H) when the letter 2nd A appears, otherwise press (F)',0,-75);
            cgtext('i.e. when there is one letter between the same letter repeated',0,-25);
            cgtext('hint - only 1 hit here',0,-100);
        elseif k1==3
            cgtext('Here, respond (H) when the letter 3rd A appears, otherwise (F)',0,-75);
            cgtext('i.e when there are two letters between the same letter repeated',0,-25);
            cgtext('hint - only 1 hit here',0,-100);
        end
        cgtext('Press space to begin or esc to quit',0,-150);
        cgflip(0,0,0);
        k=waitkeydown(inf,[52 71]);
        if k(1)==52
%             fclose(s1);
            stop_cogent; cgshut; clear; clc;return;
        end
        
        %% Present the stimuli
%         fwrite(s1,'1');
        
        cgfont('Arial', 30)
        cgpencol(.7,.7,.7)
        cgtext('+',0,0);
        cgtext(sprintf('%d back',k1,0,150));
        results.fixation(k1+1,1)=cgflip(0,0,0); %Need to organize these in the correct manner!!
        waituntil((results.fixation(k1+1,1)*1000)+parameters.ITI);
        
        for k2=1:parameters.trials%
            cgflip(0,0,0)
            cgpencol(.7,.7,.7)
            cgfont('Arial', 80)
            cgtext(parameters.numorder{k2},0,0);%puts the letter onscreen
            cgtext(sprintf('%d back',k1,0,150));
            
%             clearkeys
            results.letter_onscreen(k2,1)=cgflip(0,0,0);
            
            cgfont('Arial', 20)
            waituntil((results.letter_onscreen(k2,1))*1000+parameters.stim_dur);
            cgflip(0,0,0)
            cgtext('+',0,0);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            results.stimulus_interval(k2,1)=cgflip(0,0,0);
            
            [k,reaction_time,n]=waitkeydown(parameters.ITI,[parameters.resp_button]);
            waituntil(((results.stimulus_interval(k2,1))*1000+parameters.ITI));
            if n>0
                if k(1)==52
                    state=-1;break;
                end
                results.key_press(k2,1)=k(1);
                results.RT(k2,1)=reaction_time(1)/1000-results.stimulus_interval(k2,1);
            end
            
%             readkeys
%             [k,reaction_time,n]=getkeydown([parameters.resp_button]);
%             if n>0
%                 if k(1)==52
%                     fclose(s1);stop_cogent; cgshut; clear; clc;return;
%                 end
%                 %results.key_press(k2,1)=1;%need to alter this
%                 results.key_press(k2,1)=k(1);%need to alter this
%                 results.RT(k2,1)=reaction_time(1)/1000-results.letter_onscreen(k2,1);
%             end
%             waituntil((results.stimulus_interval(k2,1))*1000+parameters.ITI);
            
%             if results.key_press(k2,1)==0
%                 readkeys
%                 [k,reaction_time,n]=getkeydown([parameters.resp_button]);
%                 if n>0
%                     if k(1)==52
%                         fclose(s1);stop_cogent; cgshut; clear; clc;return;
%                     end
%                     results.key_press(k2,1)=k(1);%need to alter this
%                     results.RT(k2,1)=reaction_time(1)/1000-results.letter_onscreen(k2,1);
%                 end
%             end
        end
        
%     fwrite(s1,'0');
        
        %% work out performance related stuff here
        
        results.Hits=0; %detected x-back
        results.CRs=0; %correct rejection - detected incorrect letter
        results.FAs=0; %false alarm - responded when they shouldn't have
        results.Misses=0; %a hit classified as a miss
        
        parameters.trial_letter=parameters.numorder;
        
        for j3=k1+1:parameters.trials  %goes from either 2 or 4:
            
            if parameters.trial_letter{j3,1}==parameters.trial_letter{j3-k1,1}
                results.shudaprsd(j3,1)=1; %shows where the correct answers were
            else
                results.shudaprsd(j3,1)=0;
            end
            
        end
        for k5=k1+1:parameters.trials%could go from the second one...
            %% ommissions-any failure to respond is a big mistake
                
            %%  CRs or misses  
            if results.key_press(k5,1)==parameters.resp_button(1) && results.shudaprsd(k5,1)==1
                results.Misses=results.Misses+1;
            elseif results.key_press(k5,1)==parameters.resp_button(1) && results.shudaprsd(k5,1)==0
                results.CRs=results.CRs+1;
               
            %% Hits or FAs
            elseif results.key_press(k5,1)==parameters.resp_button(2) && results.shudaprsd(k5,1)==1
                results.Hits=results.Hits+1;
            elseif results.key_press(k5,1)==parameters.resp_button(2) && results.shudaprsd(k5,1)==0
                results.FAs=results.FAs+1;
            end
        end
        
        results.HR=results.Hits/(results.Hits + results.Misses);
        results.FAR = results.FAs/(results.FAs + results.CRs);
        results.Z_HR = norminv(results.HR);
        results.Z_FAR= norminv(results.FAR);
        %results.d=Z_HR-Z_FAR
        results.d=dprime(results.HR,results.FAR,results.HR+results.Misses,results.FAR+results.CRs);
        
             %% correct rate and misspress
        results.correct_rate=(results.Hits+results.CRs)/(length(results.key_press)-k1);
        results.user_miss_press=sum(results.key_press==0)-k1;
        if results.user_miss_press<0
            results.user_miss_press=0;
        end
        
        cgpencol(1,1,1)
        cgfont('Arial', 20)
        if results.Hits==sum(results.shudaprsd) && results.CRs==length(results.shudaprsd)-sum(results.shudaprsd) %performance is good
            cgtext('Very good, no mistakes!',0,50);
            cgtext('Please keep your focus',0,25);
            success=1;
        else
            success=1;
%             if results.FAs>0
%                 cgtext(sprintf('%d False Alarms',results.FAs),0,50);
%             elseif results.FAs==1
%                 cgtext(sprintf('%d False Alarm',results.FAs),0,50);
%             end
            cgtext(sprintf('%0.5f Correct',results.correct_rate),0,50)
%             if results.Misses>0
%                 cgtext(sprintf('%d Misses',results.Misses),0,25);
%             elseif results.Misses==1
%                 cgtext(sprintf('%d Miss',results.Misses),0,25);
%             end
            cgtext(sprintf('%d Miss',results.user_miss_press),0,25);
            cgtext('Please Focus!!',0,0);
            repeat_track=repeat_track+1;
        end        
        results.feedback(k1,1)=cgflip(0,0,0);
        waituntil(results.feedback(k1,1)*1000+3000);
    end
%     results.rep(k1,1)=results.rep(k1,1)+repeat_track;
% save([parameters.subj_code '_block' num2str(k1)],'parameters','results');
% clear results
end
%% Save the final 3 back exposure, don't care about this to be honest
% clear parameters

%% Now for the baseline phase
% [parameters,results]=d3_back(150,20);%150 = 5 minutes baseline
% parameters.subj_code=subj_code;
% save([parameters.subj_code '_baseline'],'parameters','results')
% clear parameters results 

%% tDCS
% cgtext('Apply DCS',0,50);
% cgtext('Researcher press space.',0,-150);
% cgflip(0,0,0);
% waitkeydown(inf,71);
% [parameters,results]=d3_back(300,20); %10 minutes of training
%% Call N-back function - first one is number of stimuli
% %300 = 10 minutes
% parameters.subj_code=subj_code; %% save the output
% save([parameters.subj_code '_DCS'],'parameters','results')
% clear parameters results 

%% test - no DCS
% cgtext('Now time for the test.',0,50);
% cgtext('Progress to tomorrow''s session is test performance dependent - do your best!',0,25);
% cgtext('Researcher press space.',0,-150);
% cgflip(0,0,0);
% waitkeydown(inf,71);
% [parameters,results]=d3_back(300,20); %10 minutes of testing
%% save the output
% parameters.subj_code=subj_code;
% save([parameters.subj_code '_Test'],'parameters','results')

%% End
% fclose(s1);
stop_cogent; cgshut;