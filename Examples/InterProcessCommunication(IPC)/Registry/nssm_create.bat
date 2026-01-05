@echo off
nssm install IpcRegistryService "D:\Software\DEV\Work\AHK2\Examples\InterProcessCommunication(IPC)\IpcRegistry\IpcRegistryService.exe"
nssm set IpcRegistryService Objectname .\Jim Pmi$10707
nssm start IpcRegistryService