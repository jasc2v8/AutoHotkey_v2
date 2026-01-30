
#Include <NamedPipe>

class RunAdminIPC {

    PipeName := ""

    pipe := 0

    __New(PipeName:= "RunAdminPipe") {
        this.PipeName:= PipeName
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

    __Delete() {
        ;this.pipe.Close()
    }

}
