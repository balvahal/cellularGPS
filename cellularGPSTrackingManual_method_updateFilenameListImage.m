function trackman = cellularGPSTrackingManual_method_updateFilenameListImage(trackman)
trackman.smda_databaseLogical = trackman.smda_database.group_number == trackman.indG &...
    trackman.smda_database.position_number == trackman.indP &...
    trackman.smda_database.settings_number == trackman.indS;
mytable = trackman.smda_database(trackman.smda_databaseLogical,:);
trackman.smda_databaseSubset = sortrows(mytable,{'timepoint'});
end