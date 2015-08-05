function [sv] = p53CinemaManual_kybrd_p(sv)
sv.scrollTimerIndex = sv.scrollTimerIndex + 1;
if sv.scrollTimerIndex == 7
    stop(sv.scrollTimer);
    str = sprintf('Speed stopped');
    disp(str);
    return
elseif sv.scrollTimerIndex > length(sv.scrollTimerArray)
    sv.scrollTimerIndex = length(sv.scrollTimerArray);
end
stop(sv.scrollTimer);
sv.scrollTimer.Period = sv.scrollTimerArray(sv.scrollTimerIndex);
start(sv.scrollTimer);
%%
% user update
str = sprintf('Speed up: %d',sv.scrollTimerIndex-7);
disp(str);
end