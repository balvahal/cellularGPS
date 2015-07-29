function [sv] = p53CinemaManual_kybrd_o(sv)
sv.scrollTimerIndex = sv.scrollTimerIndex - 1;
if sv.scrollTimerIndex <= 1
    sv.scrollTimerIndex = 1;
    stop(sv.scrollTimer);
    
    str = sprintf('Speed stopped');
    disp(str);
    return
end
stop(sv.scrollTimer);
sv.scrollTimer.Period = sv.scrollTimerArray(sv.scrollTimerIndex);
start(sv.scrollTimer);
%%
% user update
str = sprintf('Speed down: %d',sv.scrollTimerIndex);
disp(str);
end