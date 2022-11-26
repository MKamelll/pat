module processmanager;

import parseresult;
import processconfig;

import std.string;
import std.stdio;
import core.sys.posix.unistd;
import core.sys.posix.sys.wait;
import core.stdc.errno;

class ProcessManager
{
    private ParseResult.Command mCommand;
    private ProcessConfig mProcessConfig;
    private int mCurrStatus;
    this(ParseResult.Command command, ProcessConfig psConfig)
    {
        mCommand = command;
        mProcessConfig = psConfig;
    }

    void exec()
    {
        pid_t ppid = getpid();
        pid_t cpid = fork();
        if (cpid == -1) throw new Exception("Couldn't fork a process");
        
        signal(SIGTTOU, SIG_IGN);
        signal(SIGTTIN, SIG_IGN);

        if (cpid == 0) {
            if (mProcessConfig.currStdout != stdout.fileno()) {
                dup2(mProcessConfig.currStdout, STDOUT_FILENO);
                close(mProcessConfig.currStdout);
            }

            if (mProcessConfig.currStdin != stdin.fileno()) {
                dup2(mProcessConfig.currStdin, STDIN_FILENO);
                close(mProcessConfig.currStdin);
            }

            if (mProcessConfig.pipe == mProcessConfig.Pipe.NO) {
                setpgid(0, 0);
            } else {
                setpgid(0, mProcessConfig.id);
            }
            if (mProcessConfig.detached == ProcessConfig.Detached.NO) {
                if (mProcessConfig.pipe == mProcessConfig.Pipe.NO) {
                    tcsetpgrp(0, getpid());
                } else {
                    tcsetpgrp(0, mProcessConfig.id);
                }
            }
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

        if (cpid > 0 && mProcessConfig.pipe == ProcessConfig.Pipe.NO) mProcessConfig.setId(cpid);

        if (mProcessConfig.currStdout != stdout.fileno()) {
            close(mProcessConfig.currStdout);
        }

        if (mProcessConfig.currStdin != stdin.fileno()) {
            close(mProcessConfig.currStdin);
        }

        if (mProcessConfig.pipe == ProcessConfig.Pipe.NO) {
            setpgid(cpid, cpid);
        } else {
            setpgid(cpid, mProcessConfig.id);
        }

        if (mProcessConfig.detached == ProcessConfig.Detached.NO) {
            if (mProcessConfig.pipe == ProcessConfig.Pipe.NO) {
                tcsetpgrp(0, cpid);
            } else {
                tcsetpgrp(0, mProcessConfig.id);
            }
        }

        if (mProcessConfig.detached == ProcessConfig.Detached.NO) 
        {
            waitpid(cpid, &mCurrStatus, 0);
            mProcessConfig.setCurrStatus(mCurrStatus);
        }

        if (mProcessConfig.detached == ProcessConfig.Detached.NO) tcsetpgrp(0, ppid);
    }
}