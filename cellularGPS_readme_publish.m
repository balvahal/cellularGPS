[mfilepath,~,~] = fileparts(mfilename('fullpath')); %finds the path to this script

publish(fullfile(mfilepath,'cellularGPS_readme.m'));

options_doc.codeToEvaluate = 'SuperMDA_database2CellProfilerCSV(fullfile(mfilepath,''testfiles'',''example_database.txt''),fullfile(''some'',''path'',''some'',''where''),fullfile(mfilepath,''testfiles''))';
options_doc.maxOutputLines = 0;
publish(fullfile(mfilepath,'SuperMDA_database2CellProfilerCSV.m'),options_doc);

clear('options_doc');
options_doc.codeToEvaluate = 'SuperMDA_grid_maker(mmhandle,''centroid'',[0,0,0],''number_of_images'',11)';
options_doc.maxOutputLines = 0;
publish(fullfile(mfilepath,'SuperMDA_grid_maker.m'),options_doc);