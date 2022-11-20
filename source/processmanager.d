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
    pid_t mStartedPid;
    int mCurrStatus;
    bool mDetached;
    this(ParseResult.Command command, bool isDetached = false)
    {
        mCommand = command;
        mDetached = isDetached;
        mCurrStatus = 0;
    }

    int status()
    {
        return mCurrStatus;
    }

    int exec()
    {
        pid_t ppid = getpid();
        pid_t cpid = fork();
        if (cpid == -1) throw new Exception("Couldn't fork a process");
        
        signal(SIGTTOU, SIG_IGN);
        signal(SIGTTIN, SIG_IGN);

        if (cpid == 0) {
            setpgid(0, 0);
            if (!mDetached) tcsetpgrp(0, getpid());
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
        } else if (cpid > 0) {
            mStartedPid = cpid;
        }
        
        setpgid(cpid, cpid);
        if (!mDetached) tcsetpgrp(0, cpid);

        if (!mDetached) waitpid(cpid, &mCurrStatus, 0);

        if (!mDetached) tcsetpgrp(0, ppid);
        
        return mStartedPid;
    }
}