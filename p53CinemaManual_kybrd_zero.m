function [sv] = p53CinemaManual_kybrd_zero(sv)
if strcmp(sv.scrollTimer.Running,'on')
    stop(sv.scrollTimer);
    sv.scrollTimerIndex = 1;
end
%%
% user update
str = sprintf('scrolling stopped');
disp(str);
end