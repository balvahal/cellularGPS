function [sv] = p53CinemaManual_kybrd_backslash(sv)
if sv.makecellBool
    sv.makecellBool = false;
    %%%
    % user update
    str = sprintf('Keyboard ''backslash''. Tracking OFF');
    disp(str);
else
    sv.makecellBool = true;
    %%%
    % user update
    str = sprintf('Keyboard ''backslash''. Tracking ON');
    disp(str);
end
end