[mfilepath,~,~] = fileparts(mfilename('fullpath')); %finds the path to this script
p53 = p53CinemaManual;
p53.moviePath = mfilepath;
p53.initialize;