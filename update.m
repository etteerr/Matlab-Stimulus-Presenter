gitadrr = 'https://github.com/etteerr/Matlab-Stimulus-Presenter';
if ~exist('tmp','dir')    
    dos(sprintf('git\\cmd\\git.exe clone %s .\\tmp',gitadrr));
else
    dos(sprintf('git\\cmd\\git.exe pull %s .\\tmp',gitadrr)); 
end
copyfile('.\\tmp\*','.\\', 'f');
rmdir('.git','s');