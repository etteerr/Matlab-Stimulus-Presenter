function gitUpdate()
%Updages Matlab-Stimulus-Presenter to the latest version
%  	using git
gitrepo = 'git@github.com/etteerr/Matlab-Stimulus-Presenter.git';
target = '.\temp';
gitexe = 'git\\bin\\git.exe';
if ~ispc
    errordlg('Error: Automatic updating on non-windows computers is not supported.\nGo to: %s', gitrepo);
    return
end
%% Check cd
try
    if ~strcmp([cd '\start.m'],which('start.m'))
        error('gitUpdate() must be run from the root directory where start.m is!');
    end
catch
    error('gitUpdate() must be run from the root directory where start.m is!');
end

%% Run git
% Command: git.exe clone [repo] [target]
fprintf('Running git command:\n');
fprintf([gitexe ' clone "' gitrepo '" ' target '\n']);
[status,cmdout] = dos([gitexe ' clone "' gitrepo '" ' target ''],'-echo');
end

