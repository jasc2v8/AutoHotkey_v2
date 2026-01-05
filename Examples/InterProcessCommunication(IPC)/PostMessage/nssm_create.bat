@echo off
nssm install SendMessageReceiver "D:\Software\DEV\Work\AHK2\Examples\InterProcessCommunication(IPC)\IpcPostMessage\SendMessageReceiverCopilot.exe"
nssm set SendMessageReceiver Objectname .\Jim Pmi$10707
nssm start SendMessageReceiver