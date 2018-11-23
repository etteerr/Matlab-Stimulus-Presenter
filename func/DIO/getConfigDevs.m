function [ DioDevices ] = getConfigDevs( input_args )
%GETCONFIGDEVS Reads out all the config files and returns
% configured devices and their channels regardless of if they are online
% Returns DioDevices:
% STruct
%     .name = device name (eg. USB-9500)
%     .channels = {...}
%
% Channels contains
% struct:
%     .direction (OutputOnly, InputOnly, Bidirectional) (from config)
%     .name (Name specified in config)
%     .id   (ID given by daq)
configDirs = { '';...
    'func/DIO'...
    };
%% Load config
DioDevices = struct;
iter=0;
for i=1:length(configDirs)
    cdir = configDirs{i};
    files = dir(fullfile(cdir,'*.conf'));
    if length(files) > 0
        for file=files
            try
                [devname channels ] = parseConfig(fullfile(cdir,file.name));
                if ~strcmp(devname, '')
                    iter = iter + 1;
                    DioDevices(iter).name = devname;
                    DioDevices(iter).channels = channels;
                    %fprintf('Found config for %s\n', devname);
                end
            catch e
                warning('Invalid DIO config: %s',file.name);
            end
        end
    end
end

end

