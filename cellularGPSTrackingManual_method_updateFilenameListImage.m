function trackman = cellularGPSTrackingManual_method_updateFilenameListImage(trackman)
trackman.filenameListImageLogical = trackman.smda_database.group_number == trackman.indG &...
    trackman.smda_database.position_number == trackman.indP &...
    trackman.smda_database.settings_number == trackman.indS;
mytable = trackman.smda_database(trackman.filenameListImage,:);
trackman.filenameListImageTable = sortrows(mytable,{'timepoint'});
end