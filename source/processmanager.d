module processmanager;

import parseresult;

import std.string;
import std.stdio;
import core.sys.posix.unistd;
import core.sys.posix.sys.wait;
import core.stdc.errno;

class ProcessManager
{
    ParseResult.Command mCommand;
    pid_t mCurrentPid;
    int mCurrStatus;
    bool mDetached;
    this(ParseResult.Command command, bool isDetached = false)
    {
        mCommand = command;
        mDetached = isDetached;
    }

    int exec()
    {
        pid_t ppid = getpid();
        pid_t cpid = fork();
        if (cpid == -1) throw new Exception("Couldn't fork a process");
        mCurrentPid = cpid;
        
        signal(SIGTTOU, SIG_IGN);
        signal(SIGTTIN, SIG_IGN);

        if (cpid == 0) {
            setpgid(0, 0);
            tcsetpgrp(0, getpid());
            auto psName = mCommand.processName().toStringz();
            immutable(char)*[] args;
            args ~= psName;
            foreach (arg; mCommand.args())
            {
                args ~= arg.toStringz();
            }
            args ~= null;
            execvp(psName, args.ptr);
            perror(psName);
            _exit(errno());
        }
        
        setpgid(cpid, cpid);
        tcsetpgrp(0, cpid);

        waitpid(cpid, &mCurrStatus, 0);

        tcsetpgrp(0, ppid);
        
        return mCurrStatus;
    }
}