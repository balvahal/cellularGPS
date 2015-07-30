%%
% increase step group
function [sv] = p53CinemaManual_kybrd_e(sv)
sv.makecell.make;
%%
% user update
str = sprintf('Keyboard ''e''. New makecell %d',sv.makecell.pointer_makecell);
disp(str);
end