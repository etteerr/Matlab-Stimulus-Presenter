function status = checkGstreamer(showWaitbar)
%CHECKGSTREAMER Summary of this function goes here
%   when changing check:
%   - install msi section for feature names
%   - Download client for version download
%% Init
status = -1;
if nargin == 0
    showWaitbar = 1;
end

%% CHeck gstreamer install
try
	[~, res] = system('set GSTREAMER_1_0_ROOT_X86_64');

	if isempty(strfind(res, 'not defined'))

		status = 0;
		return;
	end
catch e
	disp(e.message);
	waitfor(errordlg('Cannot check for gstreamer. Please do a manual install of Gstreamer if it is not installed'));

    status = 0;
    return;
end
%% Install

if showWaitbar
    h = waitbar(0, 'Downloading gstreamer... (may take a while!)');
end

%% Download client
gstreamermsi = 'gstreamer.msi';

disp('Downloading gstreamer client... (may take a while!)');
try
    websave(gstreamermsi, 'https://gstreamer.freedesktop.org/data/pkg/windows/1.14.0.1/gstreamer-1.0-x86_64-1.14.0.1.msi')
catch e
   return; 
end

%% Find extracted installer
installer = gstreamermsi;

%% Install parameters
disp('Installing gstreamer client...')
if showWaitbar
    waitbar(0,h, 'Installing gstreamer...');
end
log = fullfile(cd, 'gstreamer-install.log');
%installdir = fullfile(cd, 'gstreamer-tmp');

%% install msi
command = sprintf([...
    'msiexec /i "%s" /passive /norestart /L* "%s" '...
    'ADDLOCAL='...
    '_gstreamer_1.0_core,'...
    '_gstreamer_1.0_system,'...
    '_gstreamer_1.0_playback,'...
    '_gstreamer_1.0_codecs,'...
    '_gstreamer_1.0_effects,'...
    '_gstreamer_1.0_net,'...
    '_gstreamer_1.0_visualizers,'...
    '_gstreamer_1.0_codecs_gpl,'...
    '_gstreamer_1.0_codecs_restricted,'...
    '_gstreamer_1.0_libav,'...
    '_gstreamer_1.0_dvd'...
    ], installer, log);
[status, out] = system(command);
if status
    disp failed
    if showWaitbar
        close(h);
    end
    disp(out);
    return
end

%% Clean
disp('Cleaning up...');
if showWaitbar
    waitbar(0,h, 'Cleaning up...');
end
delete(log);
delete(installer);

if showWaitbar
    close(h);
end

%% Set status succesfull
status = 0;

%% notify
waitfor(msgbox('gstreamer won''t be detected until matlab is restarted.'));
end


