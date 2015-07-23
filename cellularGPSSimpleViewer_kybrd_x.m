%%
% increase step settings
function [sv] = cellularGPSSimpleViewer_kybrd_x(sv)
G = sv.smda_itinerary.order_group(sv.indG);
P = sv.smda_itinerary.order_position{G};
P = P(sv.indP);
S = sv.smda_itinerary.order_settings{P};
sv.indS = sv.indS + 1;
if sv.indS > length(S)
    sv.indS = length(S);
    return
end
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
str = sprintf('Keyboard ''x''. SETTINGS %d',P);
disp(str);
end