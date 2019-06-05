% Take all the experiments and include them in the memdump
save('memdump');
gatherdata;



function gatherdata
    filenames = {};
    
    % Clear old memdumps
    delete('memdump*.mat');
    
    % Gather experiments & data (just all mat files)
    expfiles = dir('**/**/**/*.mat');
    for file=expfiles'
        file = fullfile(file.folder, file.name);
        file = file(length(cd)+2:end);
        filenames = [filenames; file];
    end
    
    % Gather all associated files
    code = dir('**/**/**/*.m');
    for file=code'
        file = fullfile(file.folder, file.name);
        file = file(length(cd)+2:end);
        filenames = [filenames; file];
    end
    
    % Gather matlab info
    data=struct;
    data.version = version;
    data.psychtoolboxVersion = PsychtoolboxVersion;
    data.dbstack = dbstack(0, '-completenames');
    save('version', 'data');
    
    % Save filenames
    save('filenames', 'filenames');
    
    % Append filenames    
    filenames = [filenames; 'version.mat'; 'filenames.mat'];
    
    % Zip
    name = sprintf('memdump_%s.dump',strrep(strrep(datestr(clock), ' ', '_'), ':', '-'));
    zip('tmp.zip', filenames);
    movefile('tmp.zip', name);
    
    % Cleanup
    delete version.mat filenames.mat memdump.mat
        
end