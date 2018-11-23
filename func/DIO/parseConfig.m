function [devname channels] = parseConfig( file )
%PARSECONFIG Parses a config file for dio channels and returns the result

devname = '';
channels = {};
porttype = '';

% Channel:
% struct:
%     .direction
%     .name
%     .id


if ~exist(file,'file')
    warning('File not found: %s', file);
    return
end

try
    hfile = fopen(file); % for reading (default)
catch e
    warning('Unable to open file %s\n%s',file,e.message);
    return
end

%% Read config
tline = fgetl(hfile);

while ischar(tline)
    origi = tline;
    % Remove comments
    tline = strsplit(tline,'#');
    tline = tline{1};
    if length(tline) ~= 0
            % Pure comments have length 0

        % Parse
        res = strsplit(tline,':');
        if length(res) ~= 2
            warning('Invalid config file: %s',file);
            devname = '';
            channels = {};
            channelNames = {};
            fprintf(origi);
            return
        end
        cmd = res{1};
        set = res{2};

        if strcmp(cmd,'dev')
            devname = set;
        elseif strcmp(cmd,'porttype')
            porttype = set;
        else
            % Else its a port!
            if strcmp(porttype, '')
                warning('Port type not specified before the ports: %s', file);
            end
            % Channel:
            % struct:
            %     .direction
            %     .name
            %     .id
            port = struct;
            port.name = cmd;
            port.id = set;
            port.direction = porttype;
            channels = [channels {port}];
        end
    end
    tline = fgetl(hfile);
end


end

