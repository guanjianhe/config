@echo off
::编码要设置成gb2312
::注意等号两边不能有空格
set DIR="C:\Users\18085884\Desktop\STC8A8K64S4A12\Code"
"C:\Program Files (x86)\Dev-Cpp\AStyle\AStyle.exe" --options="C:\Program Files (x86)\Dev-Cpp\AStyle\AS.cfg" --recursive %DIR%\*.c,*.h
pause
