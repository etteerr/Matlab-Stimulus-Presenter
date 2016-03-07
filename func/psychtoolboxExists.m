function [ bool,version, e ] = psychtoolboxExists
%PSYCHTOOLBOXEXISTS Checks if psychtoolbox exists (is installed)
%   The function PsychtoolboxVersion is available if it is. If not...
%   errors!
%   This function returns true if Psychtoolbox works, false if it doesnt.
%   the error is passed back as second variable if you want to know what
%   happend.
e = 0;
version = 0;
try
    version = PsychtoolboxVersion;
    bool = true;
catch e
    bool = false;
end

end

