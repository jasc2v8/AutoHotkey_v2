; RunAdminIPC v1.0.0.2

#Requires AutoHotkey v2+
#SingleInstance Off ; must allow multiple instances to work with shortcuts (Use Case #2)

#Include <NamedPipe>

class RunAdminIPC {

    PipeName := "RunAdminPipe"

    pipe := 0

    __New(PipeName:= "RunAdminPipe") {
        this.PipeName := PipeName
    }

    Send(CommandCSV) {
        this.pipe := NamedPipe(this.PipeName)
        this.pipe.Wait()
        this.pipe.Send(CommandCSV)
        this.pipe.Close()
    }

    Receive() {
        this.pipe := NamedPipe(this.PipeName)
        this.pipe.Create()
        reply:= this.pipe.Receive()
        this.pipe.Send(reply)
        this.pipe.Close()
        return reply
    }

    StartTask(TaskName:="RunAdmin") {
        cmd := Format('schtasks /run /tn "{}"', TaskName)
        r := RunWait(A_ComSpec ' /c ' cmd, , "Hide")
        if (r) 
            throw Error("Failed to run task: " TaskName)
    }

    ArrayToCSV(ParamsArray) {
        if (ParamsArray.Length = 0)
             return ""
        CSVString := ""       
        for Index, Value in ParamsArray {
            CurrentVal := String(Value)
            CSVString .= (Index = 1 ? "" : ",") . CurrentVal
        }
        return CSVString
    }

    ToCSV(Params*) {
        CSVString:= ""
        for index, item in Params {
            CSVString .= (index=Params.Length) ? item : item . ","
        }
        return CSVString
    }

    __Delete() {
        ;this.pipe.Close()
    }

}
