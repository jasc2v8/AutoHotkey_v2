@echo off
nssm install FileMapService "D:\Software\DEV\Work\AHK2\Examples\InterProcessCommunication(IPC)\IpcNamedSharedMemory\FileMapService.exe"
nssm set FileMapService Objectname .\Jim Pmi$10707
nssm start FileMapService