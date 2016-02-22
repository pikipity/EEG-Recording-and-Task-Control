global s1;
global currentpath;
global parameters;
fprintf(s1,'f');
cd(parameters.EEGRecord_Path);
rmpath(strcat(parameters.Main_Path,'\Laptop'))
rmpath(genpath(parameters.EEGRecord_Path));
%rmpath(genpath(parameters.Baseline_Path));
