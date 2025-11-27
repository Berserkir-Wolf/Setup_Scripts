On the original computer:
1) Open administrative terminal.
2) Create the folder for the script to export to - something like C:\WiFI. From terminal, this would be "mkdir C:\WiFi".
3) Copy the scripts from the NAS to the WiFi folder you just created.
4) CD to the WiFi directory (CD C:\WiFi).
5) Run the export (.\ExportAll.bat).
5a) If this step fails, allow scripts to run for this session (Set-ExecutionPolicy bypass -Scope Process).
6) Answer "y" or "yes".
7) Close the terminal.
8) Copy the "WiFi" folder to the new computer.

On the new computer:
1) Open administrative terminal.
2) CD to the WiFi directory (CD C:\WiFi).
3) Run the import (.\ImportAll.bat).
3a) If this step fails, allow scripts to run for this session (Set-ExecutionPolicy bypass -Scope Process).
4) Answer "y" or "yes".
5) Close the terminal.
6) Delete the WiFi folder.