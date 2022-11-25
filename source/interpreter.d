module interpreter;

import parseresult : ParseResult;
import visitor;
import processmanager;

import std.process;
import std.stdio;
import std.conv;
import std.string;

import core.sys.posix.signal;
import core.sys.posix.unistd;
import core.sys.posix.stdio : fileno;

class Interpreter : Visitor
{
    private ParseResult mParseResult;
    private int mCurrStdin;
    private int mCurrStdout;
    private int mCurrStderr;
    private int mCurrStatus;
    private bool mDetached;
    private pid_t mStartedPid;
    this(ParseResult result)
    {
        mParseResult = result;
        mCurrStdin = stdin.fileno();
        mCurrStdout = stdout.fileno();
        mCurrStderr = stderr.fileno();
        mCurrStatus = 0;
        mDetached = false;
    }

    void interpret()
    {
        mParseResult.accept(this);
    }

    void visit(ParseResult.Command command)
    {
        auto psm = new ProcessManager(command, mCurrStdin, mCurrStdout, mCurrStderr, mDetached);
        mStartedPid = psm.exec();
        if (!mDetached) mCurrStatus = psm.status();
    }

    void visit(ParseResult.Pipe pipeCommand)
    {
        int readEnd = 0;
        int wrtiteEnd = 1;
        int[2] p;
        if (pipe(p) == -1) throw new Exception("Couldn't start a pipe");
        scope (exit) {
            close(p[readEnd]);
            close(p[wrtiteEnd]);
        }

        mCurrStdout = p[wrtiteEnd];
        pipeCommand.leftCommand().accept(this);
        mCurrStdout = stdout.fileno();
        
        mCurrStdin = p[readEnd];
        pipeCommand.rightCommand().accept(this);
        mCurrStdin = stdin.fileno();
    }

    void visit(ParseResult.And andCommand)
    {
        andCommand.leftCommand().accept(this);
        if (mCurrStatus == 0) andCommand.rightCommand().accept(this);
    }

    void visit(ParseResult.BackGroundProcess command)
    {
        mDetached = true;
        command.leftCommand().accept(this);
        writeln("Started '" ~ to!string(mStartedPid) ~ "' in the background");
        mDetached = false;
        if (!command.rightCommand().isNull) command.rightCommand().get().accept(this);
    }

    void visit(ParseResult.Or orCommand)
    {
        orCommand.leftCommand().accept(this);
        if (mCurrStatus != 0) orCommand.rightCommand().accept(this);
    }
    
    void visit(ParseResult.LRRedirection lrRedirection)
    {
        if (ParseResult.Command command = cast(ParseResult.Command) lrRedirection.rightCommand()) {
            string name = command.processName();
            FILE * fp = fopen(toStringz(name), "w");
            scope (exit) fclose(fp);
            if (fp !is null) {
                mCurrStdout = fileno(fp);
            }
            lrRedirection.leftCommand().accept(this);
            mCurrStdout = stdout.fileno();
        }
    }

    void visit(ParseResult.RLRedirection rlRedirection)
    {
        if (ParseResult.Command command = cast(ParseResult.Command) rlRedirection.leftCommand()) {
            string name = command.processName();
            FILE * fp = fopen(toStringz(name), "w");
            scope (exit) fclose(fp);
            if (fp !is null) {
                mCurrStdout = fileno(fp);
            }
            rlRedirection.rightCommand().accept(this);
            mCurrStdout = stdout.fileno();
        }
    }

    void visit(ParseResult.Sequence seqCommand)
    {
        seqCommand.leftCommand().accept(this);
        if (!seqCommand.rightCommand().isNull) seqCommand.rightCommand().get().accept(this);
    }
}