function status = installSvn(showWaitbar)
%INSTALLSVN Downloads and installs svn client: silksvn
%   The installer is downloaded and exectued
%% Init
status = -1;
if nargin == 0
    showWaitbar = 1;
end

if showWaitbar
    h = waitbar(0, 'Downloading svn');
end

%% Download client
svnzip = 'svn.zip';

disp('Downloading svn client...');
try
    websave(svnzip, 'https://sliksvn.com/pub/Slik-Subversion-1.9.7-x64.zip')
catch e
   return; 
end

%% Extracting svn
disp('Extracting svn client...')
if showWaitbar
    waitbar(0,h, 'Extracting svn...');
end

try
    unzip(svnzip)
catch e
    disp failed
    if showWaitbar
        close(h);
    end
    return
end

%% Find extracted installer
installer = dir('Slik*');
if isempty(installer)
    disp failed
    if showWaitbar
        close(h);
    end
    return
end

%% Install parameters
disp('Installing svn client...')
if showWaitbar
    waitbar(0,h, 'Installing svn...');
end
installer = fullfile(cd,   installer(1).name);
log = fullfile(cd, 'svn-install.log');
%installdir = fullfile(cd, 'svn-tmp');

%% install msi
command = sprintf('msiexec /i "%s" /passive /norestart /L* "%s"', installer, log);
if system(command)
    disp failed
    if showWaitbar
        close(h);
    end
    return
end

%% Clean
disp('Cleaning up...');
if showWaitbar
    waitbar(0,h, 'Cleaning up...');
end
delete(log);
delete(installer);
delete(svnzip);

if showWaitbar
    close(h);
end

%% Set status succesfull
status = 0;
end

