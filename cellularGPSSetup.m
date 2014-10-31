[mfilepath,~,~] = fileparts(mfilename('fullpath')); %finds the path to this script
if ~isdir(fullfile(mfilepath,'matlab_file_exchange'))
    mkdir(fullfile(mfilepath,'matlab_file_exchange'));
end

%% Download files from the MATLAB FILE EXCHANGE
% # LAPJV - Jonker-Volgenant Algorithm for Linear Assignment Problem
% # JSONlab - a toolbox to encode/decode JSON files in MATLAB/Octave
% # MUNKRES - Hungarian Algorithm for linear assignment problems
%%% LAPJV
%
filename = fullfile(mfilepath,'matlab_file_exchange','LAPJV.zip');
url = 'http://www.mathworks.com/matlabcentral/fileexchange/downloads/17255';
websave(filename,url);
unzip(fullfile(mfilepath,'matlab_file_exchange','LAPJV.zip'),...
    fullfile(mfilepath,'matlab_file_exchange','LAPJV')...
    );
delete(filename);
%%% JSONlab
%
filename = fullfile(mfilepath,'matlab_file_exchange','JSONlab.zip');
url = 'http://www.mathworks.com/matlabcentral/fileexchange/downloads/58936';
websave(filename,url);
unzip(fullfile(mfilepath,'matlab_file_exchange','JSONlab.zip'),...
    fullfile(mfilepath,'matlab_file_exchange','JSONlab')...
    );
delete(filename);
%%% MUNKRES
%
filename = fullfile(mfilepath,'matlab_file_exchange','MUNKRES.zip');
url = 'http://www.mathworks.com/matlabcentral/fileexchange/downloads/12382';
websave(filename,url);
unzip(fullfile(mfilepath,'matlab_file_exchange','MUNKRES.zip'),...
    fullfile(mfilepath,'matlab_file_exchange','MUNKRES')...
    );
delete(filename);