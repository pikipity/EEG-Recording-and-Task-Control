function run_PL(s1,subinfo,data_path)
    disp(s1);
    disp(['Run PL for subject ',subinfo.name,' at Day ',subinfo.day,' in ',data_path]);
    current_path=cd;
    eval(['cd ',data_path]);
    %%
    % initial
    rand('state',sum(100*clock));%set random number generator
    format('shortG');
    parameters.name=subinfo.name;
    parameters.session=1;
    parameters.subj_code=[parameters.name '_' num2str(parameters.session)];
    state=0;
    % read options
    [ParameterName,ParameterValue]=textread([data_path,'\parameter.txt'],'%s %s','commentstyle','matlab');
    for i=1:length(ParameterName)
        eval(strcat('parameters.',strtrim(ParameterName{i}),'=',strtrim(ParameterValue{i}),';'));
    end
    parameters.num_qp=[parameters.num_q parameters.trials-parameters.num_q];
    % Cogent start
    config_display(parameters.displaymode,parameters.resolution)
    config_keyboard
    start_cogent;
    % main loop
    while 1
        switch state
            case -1
                stop_cogent; cgshut; break;
            case 0
                cgpencol(1,1,1) %change the text
                cgfont('Arial', 20)
                cgtext('Welcome to the Perceptual Learning testing!',0,75);
                cgtext(['Sub: ' parameters.name ', Trial: ' num2str(parameters.session)],0,-25);
%                 cgtext('You must quickly update your memory by forgetting irrelevant letters.',0,25);
%                 cgtext('Respond to all letters, (H) is for hit, (F) is for fail to hit!.',0,-25);
%                 cgtext('Respond as quickly and as accurately as possible.',0,-50);
                cgtext('Responses during the fixation are permitted.',0,-75);
                cgtext('Press space to continue',0,-150);
                cgflip(0,0,0);
                k=waitkeydown(inf,[52 71]);
                if k(1)==52
                    state=0;
                else
                    cgpencol(1,1,1) %change the text
                    cgfont('Arial', 20)
                    cgtext('Welcome to the Perceptual Learning testing!',0,75);
                    cgtext(['Sub: ' parameters.name ', Trial: ' num2str(parameters.session)],0,-25);
    %               cgtext('You must quickly update your memory by forgetting irrelevant letters.',0,25);
    %               cgtext('Respond to all letters, (H) is for hit, (F) is for fail to hit!.',0,-25);
    %               cgtext('Respond as quickly and as accurately as possible.',0,-50);
                    cgtext('Responses during the fixation are permitted.',0,-75);
                    cgtext('Wait',0,-150);
                    cgflip(0,0,0);
                    while 1
                        content='';
                        content=fscanf(s1);content=content(1:end-1);
                        if strcmpi(content,'z')
                            disp('start task')
                            state=1;break;
                        elseif strcmpi(content,'e')
                            disp('quit task')
                            state=-1;break;
                        elseif strcmpi(content,'d')
                            disp('start trial -> cannot start')
                        elseif strcmpi(content,'f')
                            disp('end trial -> cannot end')
                        elseif strcmpi(content,'?')
                            fprintf(s1,'!');
                        end
                    end
                end
            case 1
%                 for k1=parameters.min_block:parameters.max_block
%                     k1=parameters.min_back;
                    % generate required number of fonts
                    totlets=[repmat(parameters.letters{1},1,parameters.num_qp(1)) repmat(parameters.letters{2},1,parameters.num_qp(2))];
                    r=randperm(length(totlets));
                    parameters.numorder=totlets(r)';
                    results.shudaprsd(1:parameters.trials,1)=0;
                    parameters.trial_letter=parameters.numorder;
                    for j3=1:parameters.trials  %
                        if parameters.trial_letter(j3)=='p'
                            results.shudaprsd(j3,1)=1; %shows where the correct answers were
                        else
                            results.shudaprsd(j3,1)=0;
                        end 
                    end  
                    % random all fonts
%                     looptracker=0;
%                     Proceed=0;
%                     while Proceed==0
%                         r=randperm(length(totlets));
%                         parameters.numorder=totlets(r)';
%                         results.shudaprsd(1:parameters.trials,1)=0;
%                         parameters.trial_letter=parameters.numorder;
%                         for j3=k1+1:parameters.trials  %
%                             if parameters.trial_letter{j3,1}==parameters.trial_letter{j3-k1,1}
%                                 results.shudaprsd(j3,1)=1; %shows where the correct answers were
%                             else
%                                 results.shudaprsd(j3,1)=0;
%                             end 
%                         end          
%                         % hitnum setting
%                         if k1>=1
%                             if sum(results.shudaprsd(:,1))<parameters.hitnum
%                                 Proceed=0;
%                             else%if sum(results.shudaprsd(:,1))==parameters.hitnum
%                                 Proceed=1;
%                             end
%                         else
%                             if sum(results.shudaprsd(:,1))>0
%                                 Proceed=1;
%                             end
%                         end
%                         looptracker=looptracker+1;
%                     end
                    %
                    results.key_press(1:parameters.trials,1)=0;
                    cgfont('Arial', 30)
                    cgpencol(1,1,1)

                    cgfont('Arial', 20)
                    cgtext('Now Start PL Test',0,50);
                    cgtext('Hit the left button when q',0,25);
                    cgtext('Hit the right button when p',0,0);
%                     cgtext('e.g.  A B A C D A A ',0,-50);
%                     cgtext('i.e. when a letter repeats itself straight away.',0,-25);
%                     cgtext('Here, hit (H) when the letter A repeats at the end, otherwise press (F)',0,-75);
                    cgtext('Press space to begin',0,-150);
                    cgflip(0,0,0);
                    k=waitkeydown(inf,[52 71]);
                    if k(1)==52
                        state=0;
                    else
                        cgfont('Arial', 20)
                        cgtext('Now Start PL Test',0,50);
                        cgtext('Hit the left button when q',0,25);
                        cgtext('Hit the right button when p',0,0);
    %                     cgtext('e.g.  A B A C D A A ',0,-50);
    %                     cgtext('i.e. when a letter repeats itself straight away.',0,-25);
    %                     cgtext('Here, hit (H) when the letter A repeats at the end, otherwise press (F)',0,-75);
                        cgtext('Wait',0,-150);
                        cgflip(0,0,0);
                        while 1
                            content='';
                            content=fscanf(s1);content=content(1:end-1);
                            if strcmpi(content,'z')
                                disp('start task -> cannot start')
                            elseif strcmpi(content,'e')
                                disp('quit task')
                                state=-1;break;
                            elseif strcmpi(content,'d')
                                disp('start trial')
                                state=2;break;
                            elseif strcmpi(content,'f')
                                disp('end trial -> cannot end')
                            elseif strcmpi(content,'o?')
                                fprintf(s1,'o');
                            end
                        end
                    end
                    %
%                 end
            case 2
                %
                cgfont('Arial', 30)
                cgpencol(1,1,1)
                cgtext('+',0,0);
%                 cgtext(sprintf('%d back',k1,0,150));
                results.fixation(1,1)=cgflip(0,0,0);
                waituntil((results.fixation(1,1)*1000)+parameters.ITI);
                %
                for k2=1:parameters.trials
%                     clearkeys
                    % cgflip(0,0,0)
                    cgfont('Arial', 80)
                    cgpencol(1,1,1)
                    cgtext(parameters.numorder(k2),0,0);%puts the letter onscreen
%                     if strcmpi(parameters.numorder(k2),'q')
%                         cgtext(parameters.numorder(k2),-20,0);%puts the letter onscreen
%                     else
%                         cgtext(parameters.numorder(k2),20,0);%puts the letter onscreen
%                     end
%                     cgtext(sprintf('%d back',k1,0,150));
                    results.letter_onscreen(k2,1)=cgflip(0,0,0);
                    waituntil((results.letter_onscreen(k2,1))*1000+parameters.stim_dur);
                    %
                    cgfont('Arial', 80)
                    cgpencol(1,1,1)
                    cgtext('q',-20,0);
                    cgtext('p',20,0);%puts the letter onscreen
%                     cgtext(sprintf('%d back',k1,0,150));
                    results.letterqp_onscreen(k2,1)=cgflip(0,0,0);
                    waituntil((results.letterqp_onscreen(k2,1))*1000+parameters.ITI_qp);
                    %
                    results.randomtime(k2,1)=rand(1)*(parameters.ITI(2)-parameters.ITI(1))+parameters.ITI(1);
                    cgfont('Arial', 20)
                    cgpencol(1,1,1)
                    cgtext('+',0,0);
                    results.stimulus_interval(k2,1)=cgflip(0,0,0);
%                     readkeys
%                     disp('readkeys')
%                     waituntil((results.stimulus_interval(k2,1))*1000+parameters.ITI);
                    [k,reaction_time,n]=waitkeydown(results.randomtime(k2,1),[parameters.resp_button]);
                    waituntil(((results.stimulus_interval(k2,1))*1000+results.randomtime(k2,1)));
                    %
%                     [k,reaction_time,n]=getkeydown([parameters.resp_button]);
                    if n>0
                        if k(1)==52
                            state=0;break;
                        end
                        results.key_press(k2,1)=k(1);
                        results.RT(k2,1)=reaction_time(1)/1000-results.stimulus_interval(k2,1);
                    end
                    %
                    if k2==parameters.trials
                        state=3;
                    end
                end
                fprintf(s1,'f');
            case 3
                results.Hits=0; %detected x-back
                results.CRs=0; %correct rejection - detected incorrect letter
                results.FAs=0; %false alarm - responded when they shouldn't have
                results.Misses=0; %a hit classified as a miss
                parameters.trial_letter=parameters.numorder;
                for j3=1:parameters.trials  %goes from either 2 or 4:
                    if parameters.trial_letter(j3)=='p'
                        results.shudaprsd(j3,1)=1; %shows where the correct answers were
                    else
                        results.shudaprsd(j3,1)=0;
                    end
                end
                for k5=1:parameters.trials%could go from the second one...
                    % ommissions-any failure to respond is a big mistake
                    if results.key_press(k5,1)==0
                        if results.shudaprsd(k5,1)==0
                            results.FAs=results.FAs+1;
                        elseif results.shudaprsd(k5,1)==1
                            results.Misses=results.Misses+1;
                        end
                    else
                       %  CRs or misses  
                        if results.key_press(k5,1)==parameters.resp_button(1) && results.shudaprsd(k5,1)==1
                            results.Misses=results.Misses+1;
                        elseif results.key_press(k5,1)==parameters.resp_button(1) && results.shudaprsd(k5,1)==0
                            results.CRs=results.CRs+1;
                        % Hits or FAs
                        elseif results.key_press(k5,1)==parameters.resp_button(2) && results.shudaprsd(k5,1)==1
                            results.Hits=results.Hits+1;
                        elseif results.key_press(k5,1)==parameters.resp_button(2) && results.shudaprsd(k5,1)==0
                            results.FAs=results.FAs+1;
                        end 
                    end
                end
                results.HR=results.Hits/(results.Hits + results.Misses);
                results.FAR = results.FAs/(results.FAs + results.CRs);
                results.Z_HR = norminv(results.HR);
                results.Z_FAR= norminv(results.FAR);
                results.d=dprime(results.HR,results.FAR,results.HR+results.Misses,results.FAR+results.CRs);
                %
                cgpencol(1,1,1)
                cgfont('Arial', 20)
                cgtext(['p Press: ',num2str(results.Hits),'/',num2str(sum(results.shudaprsd(:,1)==1))],0,50)
                cgtext(['q Press: ',num2str(results.CRs),'/',num2str(sum(results.shudaprsd(:,1)==0))],0,25)
                cgtext(['Miss: ',num2str(sum(results.key_press(:,1)==0))],0,0)
                cgtext(['Accuracy: ' num2str((results.Hits+results.CRs)/length(results.shudaprsd)*100) '%'],0,-25)
                cgtext('Press space to continue',0,-50);
                cgflip(0,0,0);
                k=waitkeydown(inf,[52 71]);
                if k(1)==52
                    state=0;
                else
                    cgpencol(1,1,1)
                    cgfont('Arial', 20)
                    cgtext(['p Press: ',num2str(results.Hits),'/',num2str(sum(results.shudaprsd(:,1)==1))],0,50)
                    cgtext(['q Press: ',num2str(results.CRs),'/',num2str(sum(results.shudaprsd(:,1)==0))],0,25)
                    cgtext(['Miss: ',num2str(sum(results.key_press(:,1)==0))],0,0)
                    cgtext(['Accuracy: ' num2str((results.Hits+results.CRs)/length(results.shudaprsd)*100) '%'],0,-25)
                    cgtext('Wait',0,-50);
                    cgflip(0,0,0);
                    while 1
                        content='';
                        content=fscanf(s1);content=content(1:end-1);
                        if strcmpi(content,'z')
                            disp('start task  -> cannot start')
                        elseif strcmpi(content,'e')
                            disp('quit task')
                            state=-1;break;
                        elseif strcmpi(content,'d')
                            disp('start trial -> cannot start')
                        elseif strcmpi(content,'f')
                            disp('end trial')
                            state=0;break;
                        elseif strcmpi(content,'?')
                            fprintf(s1,'!');
                        end
                    end
                end
                %
                save(parameters.subj_code,'parameters','results');
                parameters.session=parameters.session+1;
                parameters.subj_code=[parameters.name '_' num2str(parameters.session)];
            otherwise
                disp('Error PL state')
                state=-1;
        end
    end
    %%
    eval(['cd ',current_path]);
    clear all;
