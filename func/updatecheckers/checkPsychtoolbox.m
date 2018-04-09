%     Copyright (C) 2016  Erwin Diepgrond
% 
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <http://www.gnu.org/licenses/>.
function [installed] = checkPsychtoolbox
%CHECKPSYCHTOOLBOX Summary of this function goes here
%   Checks if psychtoolbox is installed by using a hack (By relying on a
%   exception to be generated when Psychtoolbox function
%   PsychtoolboxVersion is not availible;
%   TODO:
%           -Make sure the exception is what it should be
%           Made function, Done: -Probably create a cleaner version with psychtoolbox version
%            check.
%           -Create a seperate 'installer' file that will unzip
%           Psychtoolbox. This will cutdown on copy time and will
%           ultimately reduce time usage when moving the installation.
%           Though it will prolong the installation of Psychtoolbox, it
%           should only occour once.
%           Done :-It might be userfriendly to ask before installing xD
ppath = addpath('Psychtoolbox');

%% Check svn
% C:\Program Files\SlikSvn\
% Only on windows
if ispc
    svnPath = 'C:\Program Files\SlikSvn\bin';
    svnExec = 'svn.exe';
    if ~exist(fullfile(svnPath, svnExec),'file')
        % svn missing
        status = installSvn;
        if status
            waitfor(errordlg(...
                'Failed to install slikSvn, download and install sliksvn to C:\Program Files\SlikSvn'));
        end
    else
        copyfile(svnPath, 'SVN');
    end
end      

%% CHeck gstreamer
if ispc
    status = checkGstreamer;
    if status
        waitfor(errordlg(...
            'Failed to install gstreamer, download and install gstreamer if required'));
    end  
end

%% Psychtoolbox
[doesExist, version] = psychtoolboxExists;
%targetVersion = ''%'Psychtoolbox-3.0.10';
if ispc
    % We are on windows
    targetDir = 'c:\\';
else
    targetDir = '~/';
end

if doesExist
    disp('Psychtoolbox detected:');
    disp(version);
    installed = true;
else
    installed = false;
   disp('No Psychtoolbox detected');
   
       %Psychtoolbox does not Exist! 
    %This calls for: DownloadPsychtoolbox!!
    websave('DownloadPsychtoolbox.m','https://raw.github.com/Psychtoolbox-3/Psychtoolbox-3/master/Psychtoolbox/DownloadPsychtoolbox.m')
    
    if exist('DownloadPsychtoolbox.m','file')
        %The installer exists, luckely!
        if strcmp(questdlg('Do you want to install Psychtoolbox now? (you need it to run experiments!)','Psychtoolbox','Yes','No','Yes'),'Yes')
            msgbox('Now installing Psychtoolbox. Watch the console, questions will be asked by the installer."  This can take a few minutes...','Warning, you need to do stuff');
            %run('Psychtoolbox\\SetupPsychtoolbox.m');
            v = ver('matlab');
            if ~isempty(v)
                v = v(1).Version; v = sscanf(v, '%i.%i.%i');
                if (v(1) < 7) || ((v(1) == 7) && (v(2) < 4))
                    errordlg(sprintf('Matlab version %i.%i not supported :(', v(1), v(2)), 'Unsupported matlab');
                    error('Matlab version %i.%i not supported :(', v(1), v(2));
                    %DownloadLegacyPsychtoolbox(targetDir);
                else
                    try
                        DownloadPsychtoolbox(targetDir);
                    catch e
                        error('Error while downloading psychtoolbox:\n%s\nGo to http://psychtoolbox.org/download/ and download the zip',e.message);
                    end
                end
            else
                waitfor(errordlg('Unable to determain matlab version. Please call for help'));
            end
            if psychtoolboxExists
                installed = true;
                waitfor(msgbox('Psychtoolbox succesfully installed. MatLab will restart.'));
                system('matlab -r start &'); exit;
            end
            
        else
            waitfor(msgbox('Psychtoolbox not installed. You can still create or edit experiments but you cannot run them','Note'))
        end
    end
end
path(ppath);
end

