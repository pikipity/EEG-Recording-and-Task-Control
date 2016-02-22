% SAMPLE1  - Visual presentation of words at a constant rate
config_display
%this is equivalent to:
%config_display(1, 1, [0 0 0], [1 1 1], 'Helvetica', 50, 4, 0)

% Specifiy data file to be 'sample1.dat;
config_data( 'sample1.dat' );

start_cogent;

for i = 1:countdatarows
   
   % Get word from data
   word = getdata( i, 1 );
   
   % Clear display buffer 1
   clearpict( 1 );
   
   % Draw word in display buffer 1
   preparestring( word, 1 );
   
   % Copy display buffer 1 to screen
   drawpict( 1 );
   
   % Wait for 1000ms
   wait( 1000 );
   
   % Clear screen
   drawpict( 2 );  
   
   % Wait for 1000ms
   wait( 1000 );
   
end

% Finish with blank screen
drawpict( 2 )
stop_cogent;