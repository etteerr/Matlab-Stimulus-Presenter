function updateMSP()
%% Settings
% master
% development
% jonas
branch = 'master';

%% init
repo = ['https://github.com/etteerr/Matlab-Stimulus-Presenter/zipball/' branch];
versionRequest = ['https://api.github.com/repos/etteerr/Matlab-Stimulus-Presenter/commits/' branch];

%% Go
try
    %% Check
    fprintf('\n------------Checking for update---------\n');
    answer = webread(versionRequest);
    if (exist('version', 'file'))
        f = fopen('version');
        sha = fscanf(f, '%s');
        if strcmp(sha,answer.sha)
            fprintf('Matlab Stimulus presenter up to date.\n');
            fprintf('--------------------End-----------------\n');
            fclose(f);
            return;
        end
        fclose(f);
    end

    %% Download
    % Ask first!
    fprintf('Update available\n');
    if (strcmp('No',questdlg('Update available, do you want to update?','Update', 'Yes', 'No', 'No')))
        fprintf('Update cancled');
        fprintf('--------------------End-----------------\n');
        return;
    end
    
    % Accepted
    % Download
    fprintf('-------------Starting Update------------\n');
    fprintf('Downloading update.zip...\n');
    path = websave('update.zip', repo);
    
    % Extract
    fprintf('Extracting update...\n');
    if (exist('updatetmp','dir')==7)
        rmdir('updatetmp','s');
    end
    mkdir('updatetmp');
    unzip('update.zip','updatetmp');
    
    % Copy
    fprintf('Applying update...\n');
    dirname = dir('updatetmp');
    dirname = dirname(3).name;
    movefile(fullfile('updatetmp', dirname,'*'),'.', 'f');
    
    %Clean
    rmdir('updatetmp','s');
    delete('update.zip')

    %% Save version
    f = fopen('version','w');
    fprintf(f,answer.sha);
    fclose(f);
catch e
    errordlg(sprintf('Oops, something went wrong while patching!\n%s', e.message));
    try
        close(f);
        delete('version');
    catch b
    end
end

fprintf('-------------------Done-----------------\n');
end