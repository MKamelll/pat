module processconfig;

import core.sys.posix.unistd;
import std.algorithm;

private pid_t[] mBgProcesses = [];

class ProcessConfig
{
    enum Detached { YES, NO }
    enum Pipe { YES, NO }

    private pid_t mId;
    private int mCurrStdin;
    private int mCurrStdout;
    private int mCurrStderr;
    private int mCurrStatus;
    private Detached isDetached;
    private Pipe isPipe;

    void setId(pid_t currId)
    {
        mId = currId;
    }

    void setCurrStdin(int currStdin)
    {
        mCurrStdin = currStdin;
    }

    void setCurrStdout(int currStdout)
    {
        mCurrStdout = currStdout;
    }

    void setCurrStderr(int currStderr)
    {
        mCurrStderr = currStderr;
    }

    void setDetached(Detached state)
    {
        isDetached = state;
    }

    void setPipe(Pipe state)
    {
        isPipe = state;
    }

    void setCurrStatus(int currStatus)
    {
        mCurrStatus = currStatus;
    }

    void addBackgroundProcess(pid_t pid)
    {
        mBgProcesses ~= pid;
    }

    void removeBackgroundProcess(ulong index)
    {
        mBgProcesses.remove(index);
    }

    bool findBackgroundProcess(pid_t pid)
    {
        return mBgProcesses.canFind(pid);
    }

    ///////////////////////////////////////

    pid_t id()
    {
        return mId;
    }

    int currStdin()
    {
        return mCurrStdin;
    }

    int currStdout()
    {
        return mCurrStdout;
    }

    int currStderr()
    {
        return mCurrStderr;
    }

    Detached detached()
    {
        return isDetached;
    }

    Pipe pipe()
    {
        return isPipe;
    }

    int currStatus()
    {
        return mCurrStatus;
    }

    pid_t[] bgProcesses()
    {
        return mBgProcesses;
    }
}