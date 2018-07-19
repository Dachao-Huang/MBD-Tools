import re , os ,sys
files = 0
current_path = os.getcwd()
current_file = os.listdir(current_path)
pattern = re.compile('\) (\/vobs[^\s]+)@@')
for C_code_file in current_file:
    if os.path.splitext(C_code_file)[1] =='.c':
        f_code_file = C_code_file;
if f_code_file == False:
    print('need put the c code file in the folder')
    sys.exit()
p_code = open (f_code_file,'r',encoding ='UTF-8')
currunt_line = p_code.readline()

while p_code.tell() < os.path.getsize(f_code_file):
    while pattern.findall(currunt_line) ==[]:
        currunt_line = p_code.readline()
    new_file = pattern.findall(currunt_line)
    print('creat new split code file',new_file[0])
    new_file_path = os.path.split(new_file[0])
    os.makedirs(new_file_path[0],exist_ok = True)
    new_file = open(new_file[0],'w',encoding='UTF-8')
    files+=1
    currunt_line = p_code.readline()
    currunt_line = p_code.readline()
    while pattern.findall(currunt_line) ==[]:
        new_file.write(currunt_line)
        currunt_line = p_code.readline()
        if currunt_line =='':
            break
new_file.close()
print('number of files ',files)