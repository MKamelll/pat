module processmanager;

import parseresult;

import std.string;
import std.stdio;
import core.sys.posix.unistd;
import core.sys.posix.sys.wait;
import core.stdc.errno;

class ProcessManager
{
    private ParseResult.Command mCommand;
    private pid_t mStartedPid;
    private int mCurrStatus;
    private bool mDetached;
    private int mCurrStdin;
    private int mCurrStdout;
    private int mCurrStderr;
    this(ParseResult.Command command,
        int stdIn, int stdOut, int stdErr, bool isDetached = false)
    {
        mCommand = command;
        mCurrStatus = 0;
        mCurrStdin = stdIn;
        mCurrStdout = stdOut;
        mCurrStderr = stdErr;
        mDetached = isDetached;
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
            if (mCurrStdout != stdout.fileno()) {
                dup2(mCurrStdout, STDOUT_FILENO);
                close(mCurrStdout);
            }

            if (mCurrStdin != stdin.fileno()) {
                dup2(mCurrStdin, STDIN_FILENO);
                close(mCurrStdin);
            }

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

        if (mCurrStdout != stdout.fileno()) {
            close(mCurrStdout);
        }

        if (mCurrStdin != stdin.fileno()) {
            close(mCurrStdin);
        }
        
        setpgid(cpid, cpid);
        if (!mDetached) tcsetpgrp(0, cpid);

        if (!mDetached) waitpid(cpid, &mCurrStatus, 0);

        if (!mDetached) tcsetpgrp(0, ppid);
        
        return mStartedPid;
    }
}