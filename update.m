if ~exist('tmp','dir')
    
    dos('git\\cmd\\git.exe clone https://github.com/etteerr/Matlab-Stimulus-Presenter .\\tmp');
else
    dos('git\\cmd\\git.exe pull https://github.com/etteerr/Matlab-Stimulus-Presenter .\\tmp'); 
end
copyfile('.\\tmp\*','.\\', 'f');