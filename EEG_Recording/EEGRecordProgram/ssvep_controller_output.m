function [sys,x0,str,ts] = ssvep_controller_output_20140326(t,x,u,flag,gaze_len,rest_len)
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

% global sobj
% s=serial('COM1','BaudRate',9600,'DataBits',8,'StopBits',1);
% set(s,'OutputBufferSize',512000);
% set(s,'InputBufferSize',512000);
% fopen(s);
% global tt s
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
    sys=mdlUpdate(t,x,u,gaze_len,rest_len);

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
sizes.NumDiscStates  = 6; % Median variable,
sizes.NumOutputs     = 2;
sizes.NumInputs      = 1; % freq_idx and pli_value
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
% ts  = [floor(0.1/Fs)/Fs 0];
% ts  = [floor(0.01/Fs)/Fs 0];
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
function sys=mdlUpdate(t,x,u,gaze_len,rest_len)

global s1
global Voice
global transfer_state

x(1)=u(1);
x(3)=0;
x(5)=0;
content='';
% x(2)=u(2)*pli_scalar;
% x(2) : tigger time
% x(3) : output
% x(4) : state
% x(5) : output (tcpip)
% x(6) : beep state
if (get(s1,'BytesAvailable')==0)
   %disp('none')
else    
    content=fscanf(s1);content=content(1:end-1);
    %disp(content)
end

%disp(transfer_state);
switch transfer_state
    case 0
        if strcmpi(content,'o')
            x(2)=t;
            x(6)=1;
            transfer_state=2;
            x(5)=1;
        else
            fprintf(s1,'o?');
        end
    case 1
        if strcmpi(content,'!')
            fprintf(s1,'z');
            fprintf(s1,'o?');
            transfer_state=0;
        else
            fprintf(s1,'?');
        end
    case 2
        if t>x(2)+x(6)
            sound(Voice(5).y,Voice(5).fs)
            x(6)=1;
            x(2)=t;
            transfer_state=3;
        end
    case 3
        if t>x(2)+x(6)
            sound(Voice(4).y,Voice(4).fs)
            x(6)=1;
            x(2)=t;
            transfer_state=4;
        end
    case 4
        if t>x(2)+x(6)
            sound(Voice(3).y,Voice(3).fs)
            x(6)=1;
            x(2)=t;
            transfer_state=5;
        end
    case 5
        if t>x(2)+x(6)
            sound(Voice(2).y,Voice(2).fs)
            x(6)=1;
            x(2)=t;
            transfer_state=6;
        end
    case 6
        if t>x(2)+x(6)
            sound(Voice(1).y,Voice(1).fs)
            x(6)=1;
            x(2)=t;
            transfer_state=7;
        end
    case 7
        if t>x(2)+x(6)
            sound(Voice(6).y,Voice(6).fs)
            x(6)=0;
            x(2)=t;
            transfer_state=8;
        end
    case 8
        if t>x(2)+x(6)
            fprintf(s1,'d');
            transfer_state=9;
            x(5)=2;
        end
    case 9
        if strcmpi(content,'f')
            x(5)=3;
            transfer_state=10;
        end
    case 10
        x(5)=4;
        %set_param(gcs,'SimulationCommand','stop');
end
% if x(1)>0
% %     charTable=['ABCDEFGHIJKLMNOP'];
% %     charTable=['AAAABBBBCCCCDDDD'];
% %     fwrite(s1,strcat(charTable(x(1)),num2str(x(2),'%.1f')),'char'); % detection result
% elseif x(1)<0 
%     fwrite(s1,'Z','char'); % start the experiment
% %     fwrite(s1,strcat('Z',num2str(x(2),'%d')),'char'); % start the experiment
%     x(2)=t;
%     x(3)=-1;
%     x(4)=100;
% else
%     if (x(4)==100)
%         if (t-x(2)>=rest_len)
%             x(3)=1;
%             x(2)=t;
%             x(4)=101;
%             x(6)=1;
%         end
%     elseif (x(4)==101)
% %         if (t-x(2)>=gaze_len) 
% %             x(5)=1;
% %         end
%         if ((x(6)==1) && (t-x(2)>=gaze_len))
%             %beep;
%             x(6)=0;
%         end
%         if (t-x(2)>=rest_len+gaze_len)
%             x(3)=1;
%             x(2)=t;
%             x(4)=101;
%             x(6)=1;
%         end
%     else
%             
%     end
% end
sys = [x];

% end mdlUpdate

%
%=============================================================================
% mdlOutputs
% Return the block outputs.
%=============================================================================
%
function sys=mdlOutputs(t,x,u)

sys = [x(3),x(5)];

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
