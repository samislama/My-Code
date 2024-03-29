function import TotalCases
% This is the function for automating the Collect of the data
oldFolder = cd('data');
pwd
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  STEP 1: Collect Data : Coronavirus data
%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
currentDateYYYYMMDD = strrep(datestr(date, 26), '/', '');
% set the filenames
fileCSV = ['totalcases', currentDateYYYYMMDD, '.csv']; 
fileXLSX = ['totalcases', currentDateYYYYMMDD, '.xlsx']; 
% import data from <https://ourworldindata.org/coronavirus-source-data>
% download the 'totalcase.csv' file
tcFileCSV = websave(fileCSV,'C/Matlab.csv');
% read the CSV file, and then save it to XLSX format
TMPFILE = readtable(fileCSV);
writetable(TMPFILE,fileXLSX);
% we will write the results of parsing into the appropriate folder;
% in order to use the original Milan Batista's code, we put:
path = pwd;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%    STEP 2: Split the data for individual KAU     %%%
%%%      %%% Coronavirus data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Amin = 5;  % data les than Amin will be deleted from file begining
% get table - Coronavirus data
T = readtable(fileXLSX);
% get data
A =  T{:,2:end};
[nrow,ncol] = size(A);
% table column names
name = string(T.Properties.VariableNames);
name = name(2:end)';
% start date
date0 = datenum(T{1,1}); %datenum(txt{2,1},'dd.mm.yyyy'); %datenum('2019/12/31');
% end date
%date1 = date0 + nrow - 1;
%functions names
ffname = strings(ncol,1);
nn = 0;
for n = 1:ncol
    nname = name{n};
    if strcmp("",nname) 
        continue
    end
    nn = nn + 1;
    nname = strrep(nname,' ','_');
    nname = strrep(nname,'-','_');  
    nname = strrep(nname,'''','_');      
    nname = strrep(nname,'(','_');       
    nname = strrep(nname,')','_');      
    fname = sprintf('getData%s.m',nname);
    fid = fopen(fullfile(path,fname),'w');
    if fid < 0
        fprintf('***Fail to open %s\n',fname);
        continue
    end
    fprintf('%d/%d country %s ...\n',ncol,n,nname);
    ffname(nn) = nname;
    fprintf(fid,'function [country,C,date0] = getData%s()\n',nname);
    fprintf(fid,'%%GETDATA%s Coronavirus data for %s\n',upper(nname),nname);
    fprintf(fid,'%%  as reported by One World in Data\n');
    fprintf(fid,'%%     https://ourworldindata.org/coronavirus-source-data\n');
    fprintf(fid,'country = ''%s'';\n',strrep(name(n),' ','_'));
    fprintf(fid,'C = [\n');
    found = false;
    nday = 0;
    for m = 1:nrow
        if ~found && (isnan(A(m,n)) || A(m,n) == 0 || A(m,n) < Amin)
            nday = nday + 1;
            continue
        else
            found = true;
        end
        fprintf(fid,'  %9d %% %s\n',A(m,n),datestr(date0 + m - 1));
    end
    fprintf(fid,'%%<-------------- add new data here\n');    
    fprintf(fid,']'';\n');
    % start date
    fprintf(fid,'date0=datenum(''%s'');\n',datestr(date0 + nday)); 
    fprintf(fid,'end\n');
    fclose(fid);
    
    %generete driver rutine
    fname = 'runAll.m';
    fid = fopen(fullfile(path,fname),'w'); 
    if fid < 0
        fprintf('***Fail to open %s\n',fname);
        continue
    end
    fprintf(fid,'prn = ''off'';\n');
    fprintf(fid,'plt = ''on'';\n');
    for n = 1:nn
        fprintf(fid,'try\n');
        fprintf(fid,'  fitVirusCV19(@getData%s,''prn'',prn,''jpg'',plt)\n',...
            ffname(n));
        fprintf(fid,'end\n');
    end
    fclose(fid);
    
    cd(oldFolder)
end

