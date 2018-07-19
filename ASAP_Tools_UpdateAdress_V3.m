function ASAP_Tools_UpdateAdress
% 读取当前文件夹的ASAP2和编译后的map文件，更新ASAP2文件的地址值
% ASAP文件后缀必须是.a2l
% MAP文件后缀必须是.map
%% 获取当前文件夹里的ASAP和map文件
A2l_File = dir('*.a2l');
A2l_File = A2l_File.name;
Map_File = dir('*.map');
Map_File = struct2cell(Map_File);
Map_File = Map_File(1,:);
%% 将参数映射存储到map文件中
for j = 1:length(Map_File)
    MAPFileString = fileread(Map_File{j});
end
pairs = regexp(MAPFileString,'\n0x([0-9a-fA-F])+\s+0x[0-9a-fA-F]+\s+[0-9]+\s+[gl]\s+(\S*)\s','tokens');
for j = 1 : length(pairs)                                   
    if isempty(regexp(pairs{j}{2},'(\S*)\.\d*','tokens'))
        
    else
        temp = regexp(pairs{j}{2},'(\S*)\.\d*','tokens');
        pairs{j}{2} = temp{:}{:};
    end
end
 MAPFileHash = containers.Map;
 Fid_full_par = fopen('full_par.txt','w');%建立所有参数列表文件指针
for i = 1:length(pairs)
    fprintf(Fid_full_par,'%s\n',pairs{i}{2});%打印所有参数到文件
    MAPFileHash(pairs{i}{2}) = pairs{i}{1};
end
%% 打印MAP里面的参数列表,用于调试
% Fid_keys = fopen('keys.txt','w');%建立所以keys列表文件指针
% a=keys(MAPFileHash);
% for i = 1:length(a)
%     fprintf(Fid_keys,'%s\n',a{i});
% end
%% 
Fid_a2l=fopen(A2l_File,'r+');
Fid_updatelist = fopen('updatelist.txt','w');
Fid_Nupdatelist = fopen('Nupdatelist.txt','w');
newline=fgetl(Fid_a2l);
while ~feof(Fid_a2l)
    while isempty(regexp(newline,'(\/begin\s\MEASUREMENT\s(\S*))|(\/begin\s\CHARACTERISTIC\s(\S*))','tokens', 'once'))
        newline=fgetl(Fid_a2l);
        if feof(Fid_a2l)
            fclose('all');
            return
        end
    end
        Symbol_Name=(regexp(newline,'(\S*)\s*$|(\S*)\s*""$','tokens'));
        Symbol_Name = Symbol_Name{1,1}{1,1};
        if isKey(MAPFileHash,Symbol_Name) 
            Symbol_Address=MAPFileHash(Symbol_Name);    
            while isempty(regexp(newline,'0x([0-9a-fA-F]{8})','match'))
                  newline=fgetl(Fid_a2l);
            end
            symbol_Address_length=length(newline)-strfind(newline,'0x')+1;
            fseek(Fid_a2l,-symbol_Address_length,'cof');
            fprintf(Fid_a2l,'%s',Symbol_Address);
            fprintf(Fid_updatelist,'%s\n',Symbol_Name);
            newline=fgetl(Fid_a2l);
        elseif isKey(MAPFileHash,lower(Symbol_Name))
            Symbol_Address=MAPFileHash(lower(Symbol_Name));    
            while isempty(regexp(newline,'0x([0-9a-fA-F]{8})','match'))
                  newline=fgetl(Fid_a2l);
            end
            symbol_Address_length=length(newline)-strfind(newline,'0x')+1;
            fseek(Fid_a2l,-symbol_Address_length,'cof');
            fprintf(Fid_a2l,'%s',Symbol_Address);
            fprintf(Fid_updatelist,'%s\n',Symbol_Name);
            newline=fgetl(Fid_a2l);
        else
            newline=fgetl(Fid_a2l);
            fprintf(Fid_Nupdatelist,'%s\n',Symbol_Name);   
        end
   newline=fgetl(Fid_a2l); 
end
fclose('all');
