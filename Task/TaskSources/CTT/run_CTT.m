function run_CTT(s1,subinfo,data_path)
    disp(s1);
    disp(['Run CTT for subject ',subinfo.name,' at Day ',subinfo.day,' in ',data_path]);
    current_path=cd;
    eval(['cd ',data_path]);
    %%
    import java.awt.Robot; 
    import java.awt.event.*;
    robot = Robot;
    %open program
    system(['java -Xms512M -Xmx1024M -jar ',data_path,'\TracePoint.jar &']);
    for i=1:3
        disp(['wait ',num2str(i),' s'])
        pause(1)
    end
    robot.keyPress(java.awt.event.KeyEvent.VK_TAB)
    robot.keyRelease(java.awt.event.KeyEvent.VK_TAB)
    pause(0.1)
    for i=subinfo.name
        eval(['robot.keyPress(java.awt.event.KeyEvent.VK_',upper(i),')']);
        eval(['robot.keyRelease(java.awt.event.KeyEvent.VK_',upper(i),')']);
        %pause(0.1)
    end
    pause(0.1)
    robot.keyPress(java.awt.event.KeyEvent.VK_TAB)
    robot.keyRelease(java.awt.event.KeyEvent.VK_TAB)
    pause(0.1)
    robot.keyPress(java.awt.event.KeyEvent.VK_TAB)
    robot.keyRelease(java.awt.event.KeyEvent.VK_TAB)
    %
    while 1
        content='';
        content=fscanf(s1);content=content(1:end-1);
         % z: start task
         % e: quit task
         % d: start trial
         % f: end trial
        if strcmpi(content,'z')
            disp('start task')
            robot.keyPress(java.awt.event.KeyEvent.VK_ENTER)
            robot.keyRelease(java.awt.event.KeyEvent.VK_ENTER)
        elseif strcmpi(content,'e')
            disp('quit task')
            robot.keyPress(java.awt.event.KeyEvent.VK_CONTROL)
            robot.keyPress(java.awt.event.KeyEvent.VK_Q)
            robot.keyRelease(java.awt.event.KeyEvent.VK_Q)
            robot.keyRelease(java.awt.event.KeyEvent.VK_CONTROL)
            break;
        elseif strcmpi(content,'d')
            disp('start trial')
            robot.mousePress(InputEvent.BUTTON1_MASK)
            robot.mouseRelease(InputEvent.BUTTON1_MASK)
        elseif strcmpi(content,'f')
            disp('end trial')
            robot.mousePress(InputEvent.BUTTON1_MASK)
            robot.mouseRelease(InputEvent.BUTTON1_MASK)
        elseif strcmpi(content,'?')
            fprintf(s1,'!');
        elseif strcmpi(content,'o?')
            fprintf(s1,'o');
        end
    end
    %%
    eval(['cd ',current_path]);
end

