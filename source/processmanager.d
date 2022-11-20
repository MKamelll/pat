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
    private File mCurrStdin;
    private File mCurrStdout;
    private File mCurrStderr;
    this(ParseResult.Command command,
        File stdIn, File stdOut, File stdErr, bool isDetached = false)
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
            if (mCurrStdout != stdout) {
                dup2(mCurrStdout.fileno(), STDOUT_FILENO);
                close(mCurrStdout.fileno());
            }

            if (mCurrStdin != stdin) {
                dup2(mCurrStdin.fileno(), STDIN_FILENO);
                close(mCurrStdin.fileno());
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

        if (mCurrStdout != stdout) {
            close(mCurrStdout.fileno());
        }

        if (mCurrStdin != stdin) {
            close(mCurrStdin.fileno());
        }
        
        setpgid(cpid, cpid);
        if (!mDetached) tcsetpgrp(0, cpid);

        if (!mDetached) waitpid(cpid, &mCurrStatus, 0);

        if (!mDetached) tcsetpgrp(0, ppid);
        
        return mStartedPid;
    }
}