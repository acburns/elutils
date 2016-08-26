function ip = get_ip()

%% 
if ispc
    [r,p]=system('ipconfig /all')
elseif ismac
    [r,p] = system('ifconfig');
    ind = strfind(p,'inet ');
    indshift = 5;
else
    [r,p] = system('ifconfig');
    ind = strfind(p,'inet addr:');
    indshift = 10;
end
%%
ipind = 1;
for ix = 1:numel(ind)
    thisip = strtrim(strtok(p(ind(ix)+indshift:ind(ix)+indshift+15),' '));
    if ~strcmp(thisip, {'127.0.0.1','127.0.1.1'})
        IP{ipind} = thisip;
    end
end

if numel(IP)>1
    fprintf(2,'GOt multiple IPs returning first');
end

ip = IP{1};