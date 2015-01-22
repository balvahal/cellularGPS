[mfilepath,~,~] = fileparts(mfilename('fullpath')); %finds the path to this script
if ~isdir(fullfile(mfilepath,'matlab_file_exchange'))
    mkdir(fullfile(mfilepath,'matlab_file_exchange'));
end

%% Download files from the MATLAB FILE EXCHANGE
% # LAPJV - Jonker-Volgenant Algorithm for Linear Assignment Problem
% # json_parser - the preferred JSON parser of twitty
% # MUNKRES - Hungarian Algorithm for linear assignment problems
%%% LAPJV
%
filename = fullfile(mfilepath,'matlab_file_exchange','LAPJV.zip');
url = 'http://www.mathworks.com/matlabcentral/fileexchange/submissions/26836/v/15/download/zip';
websave(filename,url);
unzip(fullfile(mfilepath,'matlab_file_exchange','LAPJV.zip'),...
    fullfile(mfilepath,'matlab_file_exchange','LAPJV')...
    );
delete(filename);
%%% json_parser
%
filename = fullfile(mfilepath,'matlab_file_exchange','json_parser.zip');
url = 'http://www.mathworks.com/matlabcentral/fileexchange/submissions/20565/v/3/download/zip';
websave(filename,url);
unzip(fullfile(mfilepath,'matlab_file_exchange','json_parser.zip'),...
    fullfile(mfilepath,'matlab_file_exchange','json_parser')...
    );
delete(filename);
%%% MUNKRES
%
filename = fullfile(mfilepath,'matlab_file_exchange','MUNKRES.zip');
url = 'http://www.mathworks.com/matlabcentral/fileexchange/submissions/20652/v/5/download/zip';
websave(filename,url);
unzip(fullfile(mfilepath,'matlab_file_exchange','MUNKRES.zip'),...
    fullfile(mfilepath,'matlab_file_exchange','MUNKRES')...
    );
delete(filename);