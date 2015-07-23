%%
% decrease step position
function [sv] = cellularGPSSimpleViewer_kybrd_a(sv)
sv.indP = sv.indP - 1;
if sv.indP < 1
    sv.indP = 1;
    return
end
G = sv.smda_itinerary.order_group(sv.indG);
P = sv.smda_itinerary.order_position{G};
P = P(sv.indP);
S = sv.smda_itinerary.order_settings{P};
S = S(sv.indS);
smda_databaseLogical = sv.smda_database.group_number == G...
    & sv.smda_database.position_number == P...
    & sv.smda_database.settings_number == S;
mytable = sv.smda_database(smda_databaseLogical,:);
sv.tblRegister = sortrows(mytable,{'timepoint'});
if sv.indT > height(sv.tblRegister)
    sv.indT = height(sv.tblRegister);
end

sv.update_mainImage;
%%
% user update
str = sprintf('Keyboard ''a''. POSITION %d',P);
disp(str);
end