function [sys,x0,str,ts] = ssvep_controller_process_20140326(t,x,u,flag)
%SFUNTMPL General M-file S-function template
%   With M-file S-functions, you can define you own ordinary differential
%   equations (ODEs), discrete system equations, and/or just about
%   any type of algorithm to be used within a Simulink block diagram.
%
%   The general form of an M-File S-function syntax is:
%       [SYS,X0,STR,TS] = SFUNC(T,X,U,FLAG,P1,...,Pn)
%
%   What is returned by SFUNC at a given point in time, T, depends on the
%   value of the FLAG, the current state vector, X, and the current
%   input vector, U.
%
%   FLAG   RESULT             DESCRIPTION
%   -----  ------             --------------------------------------------
%   0      [SIZES,X0,STR,TS]  Initialization, return system sizes in SYS,
%                             initial state in X0, state ordering strings
%                             in STR, and sample times in TS.
%   1      DX                 Return continuous state derivatives in SYS.
%   2      DS                 Update discrete states SYS = X(n+1)
%   3      Y                  Return outputs in SYS.
%   4      TNEXT              Return next time hit for variable step sample
%                             time in SYS.
%   5                         Reserved for future (root finding).
%   9      []                 Termination, perform any cleanup SYS=[].
%
%
%   The state vectors, X and X0 consists of continuous states followed
%   by discrete states.
%
%   Optional parameters, P1,...,Pn can be provided to the S-function and
%   used during any FLAG operation.
%
%   When SFUNC is called with FLAG = 0, the following information
%   should be returned:
%
%      SYS(1) = Number of continuous states.
%      SYS(2) = Number of discrete states.
%      SYS(3) = Number of outputs.
%      SYS(4) = Number of inputs.
%               Any of the first four elements in SYS can be specified
%               as -1 indicating that they are dynamically sized. The
%               actual length for all other flags will be equal to the
%               length of the input, U.
%      SYS(5) = Reserved for root finding. Must be zero.
%      SYS(6) = Direct feedthrough flag (1=yes, 0=no). The s-function
%               has direct feedthrough if U is used during the FLAG=3
%               call. Setting this to 0 is akin to making a promise that
%               U will not be used during FLAG=3. If you break the promise
%               then unpredictable results will occur.
%      SYS(7) = Number of sample times. This is the number of rows in TS.
%
%
%      X0     = Initial state conditions or [] if no states.
%
%      STR    = State ordering strings which is generally specified as [].
%
%      TS     = An m-by-2 matrix containing the sample time
%               (period, offset) information. Where m = number of sample
%               times. The ordering of the sample times must be:
%
%               TS = [0      0,      : Continuous sample time.
%                     0      1,      : Continuous, but fixed in minor step
%                                      sample time.
%                     PERIOD OFFSET, : Discrete sample time where
%                                      PERIOD > 0 & OFFSET < PERIOD.
%                     -2     0];     : Variable step discrete sample time
%                                      where FLAG=4 is used to get time of
%                                      next hit.
%
%               There can be more than one sample time providing
%               they are ordered such that they are monotonically
%               increasing. Only the needed sample times should be
%               specified in TS. When specifying than one
%               sample time, you must check for sample hits explicitly by
%               seeing if
%                  abs(round((T-OFFSET)/PERIOD) - (T-OFFSET)/PERIOD)
%               is within a specified tolerance, generally 1e-8. This
%               tolerance is dependent upon your model's sampling times
%               and simulation time.
%
%               You can also specify that the sample time of the S-function
%               is inherited from the driving block. For functions which
%               change during minor steps, this is done by
%               specifying SYS(7) = 1 and TS = [-1 0]. For functions which
%               are held during minor steps, this is done by specifying
%               SYS(7) = 1 and TS = [-1 1].

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.18 $

%
% The following outlines the general structure of an S-function.
%

switch flag,

    %%%%%%%%%%%%%%%%%%
    % Initialization %
    %%%%%%%%%%%%%%%%%%
    case 0,
        [sys,x0,str,ts]=mdlInitializeSizes();

        %%%%%%%%%%%%%%%
        % Derivatives %
        %%%%%%%%%%%%%%%
    case 1,
        sys=mdlDerivatives(t,x,u);

        %%%%%%%%%%
        % Update %
        %%%%%%%%%%
    case 2,
        sys=mdlUpdate(t,x,u);
        %%%%%%%%%%%
        % Outputs %
        %%%%%%%%%%%
    case 3,
        sys=mdlOutputs(t,x,u);

        %%%%%%%%%%%%%%%%%%%%%%%
        % GetTimeOfNextVarHit %
        %%%%%%%%%%%%%%%%%%%%%%%
    case 4,
        sys=mdlGetTimeOfNextVarHit(t,x,u);

        %%%%%%%%%%%%%
        % Terminate %
        %%%%%%%%%%%%%
    case 9,
        sys=mdlTerminate(t,x,u);

        %%%%%%%%%%%%%%%%%%%%
        % Unexpected flags %
        %%%%%%%%%%%%%%%%%%%%
    otherwise
        error(['Unhandled flag = ',num2str(flag)]);

end

% end sfuntmpl

%
%=============================================================================
% mdlInitializeSizes
% Return the sizes, initial conditions, and sample times for the S-function.
%=============================================================================
%
function [sys,x0,str,ts]=mdlInitializeSizes()
% call simsizes for a sizes structure, fill it in and convert it to a
% sizes array.
%
% Note that in this example, the values are hard coded.  This is not a
% recommended practice as the characteristics of the block are typically
% defined by the S-function parameters.
%

sizes = simsizes;

sizes.NumContStates  = 0;
sizes.NumDiscStates  = 6; %
sizes.NumOutputs     = 1;
sizes.NumInputs      = 1; % 4 channel
sizes.DirFeedthrough = 0;
sizes.NumSampleTimes = 1;   % at least one sample time is needed

sys = simsizes(sizes);

%
% initialize the initial conditions
%
x0  = 0;

%
% str is always an empty matrix
%
str = [];

%
% initialize the array of sample times
%
ts  = [-1 0];

% end mdlInitializeSizes

%
%=============================================================================
% mdlDerivatives
% Return the derivatives for the continuous states.
%=============================================================================
%
function sys=mdlDerivatives(t,x,u)

sys = [];

% end mdlDerivatives

%
%=============================================================================
% mdlUpdate
% Handle discrete state updates, sample time hits, and major time step
% requirements.
%=============================================================================
%
function sys=mdlUpdate(t,x,u)
global mystate 
% x(1):                   buffer pointer
% x(2):                   consecutive time(ct) 
% x(3):                   starting_point
% x(4):                   sampling point
% x(5):                   freq_idx
% x(6):                   ph_idx

freq_idx=0;
% ph_idx=0;
x(4)=x(4)+1;
switch mystate
    case 'start'
        if t>0
            x(3)=1;                % receive the sync. signal
%             trig_t=t;
        end
        if (x(3)>=1)
            x(3)=x(3)+1;
            if (x(3)>1)               
                mystate='sample';
                x(2)=1;x(1)=1;
                x(3)=1;
                freq_idx=-1;
            end
%             freq_idx=-2;
        end
%         if (u(channelNum+1)>2000 & x(4)>(rest_len-Fs))
%             mystate='sample';
% %             x_shift=zeros(1,length(x_sh));
%             x(2)=1;x(1)=1;
%             x(3)=x(4);
% %             freq_idx=-2;
%         end
    case 'sample'
%         if (x(4)-x(3)>gaze_len)
% %             x_shift=zeros(1,length(x_sh));
%             x(2)=1;
%             x(1)=1;
%             mystate='start';
%         else
%             ybuffer(1:channelNum,x(1))=u([1:channelNum]);
%             ybuffer(channelNum+1,x(1))=u(channelNum+1);            
% 
%             if (x(1)>=buf_len)
% %                 x_com0=(fft(ybuffer(ch-1,:),Nfft));
%                 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                 % Calculate the CCA coefficient
%                 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                 [d1 d2 d3]=size(y_ref);
%                 for k=1:length(stim_freq)
%                     ref_temp=reshape(y_ref(k,:,:),d2,d3);
%                     [A,B,r,U,V]=canoncorr(ybuffer(1:channelNum,:)',ref_temp);
%                     cc(k)=r(1);
% %                     if k==4
% %                         cc(k)=cc(k)+1;
% %                     end
%                 end
% %                 [A,B,r,U,V]=canoncorr(ybuffer(1:4,:)',y_ref1);
% %                 cc(1)=r(1);
% %                 [A,B,r,U,V]=canoncorr(ybuffer(1:4,:)',y_ref2);
% %                 cc(2)=r(1);
% %                 [A,B,r,U,V]=canoncorr(ybuffer(1:4,:)',y_ref3);
% %                 cc(3)=r(1);
% %                 [A,B,r,U,V]=canoncorr(ybuffer(1:4,:)',y_ref4);
% %                 cc(4)=r(1);
% %                 [A,B,r,U,V]=canoncorr(ybuffer(1:4,:)',y_ref5);
% %                 cc(5)=r(1);
% %                 [A,B,r,U,V]=canoncorr(ybuffer(1:4,:)',y_ref6);
% %                 cc(6)=r(1);
% %                 [A,B,r,U,V]=canoncorr(ybuffer(1:4,:)',y_ref7);
% %                 cc(7)=r(1);
% %                 [A,B,r,U,V]=canoncorr(ybuffer',y_ref8);
% %                 cc(8)=r(1);
%                 
% %                 cca_idx(x(2),:)=(cc==max(cc));                               
%                 cca_idx(x(2),:)=cc;   
%                 if (x(2)==ct_no)
%                     [cc_max,cc_idx]=max(cca_idx');
%                     [cc_times,cc_most]=max(histc(cc_idx,[1:length(stim_freq)]));
% %                     cc_times
%                     if cc_times>ct_no*0.5
%                         if mean(cc_max(find(cc_idx==cc_most)))>0.2
%                             freq_idx=cc_most;                            
% %                             cc_idx
%                         end
%                     end 
%                 end
% %                 trig_label=find(ybuffer(5,:)>2000,1);
%                 trig_label=floor(Fs*0.2);
%                 ybuffer(:,1:buf_len-trig_label)=ybuffer(:,trig_label+1:end);
% %                 ytrig(1:buf_len-trig_label)  =ytrig(trig_label+1:end);
%                 x(1)=buf_len-trig_label;
%                 x(2)=x(2)+1;
%             end
%             x(1)=x(1)+1;
%         end
%     case 'wait'
%         ct=1;
%         yp=1;
%         state='start';

    otherwise

end
x(5)=freq_idx;





sys = [x];

% end mdlUpdate

%
%=============================================================================
% mdlOutputs
% Return the block outputs.
%=============================================================================
%
function sys=mdlOutputs(t,x,u)

sys = [x(5)];

% end mdlOutputs

%
%=============================================================================
% mdlGetTimeOfNextVarHit
% Return the time of the next hit for this block.  Note that the result is
% absolute time.  Note that this function is only used when you specify a
% variable discrete-time sample time [-2 0] in the sample time array in
% mdlInitializeSizes.
%=============================================================================
%
function sys=mdlGetTimeOfNextVarHit(t,x,u)

sampleTime = 1;    %  Example, set the next hit to be one second later.
sys = t + sampleTime;

% end mdlGetTimeOfNextVarHit

%
%=============================================================================
% mdlTerminate
% Perform any end of simulation tasks.
%=============================================================================
%
function sys=mdlTerminate(t,x,u)

sys = [];

% end mdlTerminate
