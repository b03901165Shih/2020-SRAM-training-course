%clear;
SYS = 512;
N = 512;
input_path = 'sram_input_test';
gold_path = 'sram_output_test';
write2File = true;

X = single(randn(16,64));

%% Write out
if(write2File)
    % Write file
    fileID = fopen(input_path,'w');
    for j = 1:64
        for i = 1:16
            fprintf(fileID,'%s',char(dec2hex(typecast(single(X(i,j)),'uint32'),8)-'0' + 48));
        end
        fprintf(fileID,'\n');
    end
    fclose(fileID);
end


%% write out

if(write2File)
    % Write file
    fileID = fopen(gold_path,'w');
    for j = 64:-1:1
        for i = 1:16
            fprintf(fileID,'%s',char(dec2hex(typecast(single(X(i,j)),'uint32'),8)-'0' + 48));
        end
        fprintf(fileID,'\n');
    end
    fclose(fileID);
end
