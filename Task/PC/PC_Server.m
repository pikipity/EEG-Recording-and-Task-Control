clear;clc;
%% Read Parameters
[ParameterName,ParameterValue]=textread('PC_Server.Para','%s %s','commentstyle','matlab');
for i=1:length(ParameterName)
    eval(strcat('parameters.',strtrim(ParameterName{i}),'=',strtrim(ParameterValue{i}),';'));
end
%% Generate Path
parameters.Task_Data_Path=cell(1,length(parameters.Task_List));
for i=1:length(parameters.Task_List)
    parameters.Task_Data_Path{i}=strcat(parameters.Main_Path,'\',parameters.Data_Folder,'\',parameters.Task_List{i});
end
parameters.Task_Source_Path=cell(1,length(parameters.Task_List));
for i=1:length(parameters.Task_List)
    parameters.Task_Source_Path{i}=strcat(parameters.Main_Path,'\',parameters.Task_Folder,'\',parameters.Task_List{i});
end
parameters.Voice_Path=[parameters.Main_Path,'\',parameters.Voice_Path];
parameters.Library_Path=[parameters.Main_Path,'\',parameters.Library_Path];
%% Init
state=0;
addpath([parameters.Main_Path,'\PC'])
addpath(genpath(parameters.Library_Path));
cd ..
%% Main
while 1
    switch state
        case -1
            % Quit State
            try
                fprintf(s1,'q');
                fclose(s1);
                disp('Quit')
            catch err
                disp('Quit. But there is not s1')
            end
            break;
        case 0
            % read transfered subject information
            disp('Wait Sub Info')
            content='';
            try
                content=fscanf(s1);content=content(1:end-1);
            catch err
                s1=tcpip(parameters.IP,4000, 'NetworkRole', 'Server');
                set(s1,'InputBufferSize',256);
                fopen(s1);
                content=fscanf(s1);content=content(1:end-1);
            end
            % content format:
            %   1. 'task:task_name:sub:sub_name:day:day_num': go to task
            %   2. 'q': quit
            if isempty(content)
            elseif strcmpi(content,'0')
                fprintf(s1,'0');
            elseif strcmpi(content,'q')
                state=-1;
            elseif ischar(content)
                splitresult=regexp(content,':','split');
                if length(splitresult)==6
                    if strcmpi(splitresult{1},'task') && strcmpi(splitresult{3},'sub') && strcmpi(splitresult{5},'day')
                        subinfo.task=splitresult{2};
                        subinfo.name=splitresult{4};
                        subinfo.day=splitresult{6};
                        state=1;
                    else
                        disp('Content Format Error3')
                    end
                else
                    disp('Content Format Error2')
                end
            else
                disp('Content Format Error1')
            end
        case 1
            % create data storage location
            task_ind=strmatch(subinfo.task,parameters.Task_List);
            if isempty(task_ind)
                disp('Task Name Error!')
                state=0;
            else
                disp('Generate Data Path')
                data_path=strcat(parameters.Task_Data_Path{task_ind},'\',subinfo.name,'\D',subinfo.day);
                if ~exist(data_path)
                    disp('Data Store Location does not exist. Create it. Run Task.')
                    mkdir(data_path);
                    copyfile(strcat(parameters.Task_Source_Path{task_ind},'\*'),strcat(data_path,'\'));
                else
                    disp('Data Store Location exists. Existed Data will be removed. Run Task.');
                end
                % delete un-required files
                fidin1=fopen([data_path,'\','FileList']);
                i=0;
                while ~feof(fidin1)
                    tline=fgetl(fidin1);
                    i=i+1;
                    requiredfile{i}=tline;
                end
                fclose(fidin1);
                listing=dir(data_path);
                for i=1:length(listing)
                    if isempty(strmatch(listing(i).name,requiredfile)) && isempty(strmatch(listing(i).name,{'.','..','FileList'}))
                        delete([data_path,'\',listing(i).name])
                    end
                end
                %
                state=2;
            end
        case 2
            %Run Task
            %generate main run file
            old_task_main_file=strcat(parameters.Task_Source_Path{task_ind},'\',parameters.Task_Run_File{task_ind},'.m');
            new_task_main_file=strcat(data_path,'\',parameters.Task_Run_File{task_ind},'_',subinfo.name,'_D',subinfo.day,'.m');
            if exist(strcat(data_path,'\',parameters.Task_Run_File{task_ind},'.m'))
                delete(strcat(data_path,'\',parameters.Task_Run_File{task_ind},'.m'));
            end
            fidin1=fopen(old_task_main_file,'r+');
            i=0;
            while ~feof(fidin1)
                tline=fgetl(fidin1);
                i=i+1;
                newline{i}=tline;
                if i==1
                    splitresult=regexp(tline,'(','split');
                    newline{i}=[splitresult{1},'_',subinfo.name,'_D',subinfo.day,'(',splitresult{2}];
                end
            end
            fclose(fidin1);
            fidout1=fopen(new_task_main_file,'w+');
            for j=1:i-1
                fprintf(fidout1,'%s\n',newline{j});
            end
            fclose(fidout1);
            %add all file in library
            addpath(genpath(data_path));
            %run main file
            % z: start task
            % e: quit task
            % d: start trial
            % f: end trial
            eval(strcat(parameters.Task_Run_File{task_ind},'_',subinfo.name,'_D',subinfo.day,'(s1,subinfo,data_path);'));
            rmpath(genpath(data_path));
            state=0;
        otherwise
            % Error State
            disp('Error State! Program Quit!');
            try
                fclose(s1);
                disp('Quit')
            catch err
                disp('Quit. But there is not s1')
            end
            break;
    end
end

rmpath([parameters.Main_Path,'\PC'])
rmpath(genpath(parameters.Library_Path));