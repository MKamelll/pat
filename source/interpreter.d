module interpreter;

import parseresult : ParseResult;
import visitor;
import processmanager;
import processconfig;

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
    private ProcessConfig mProcessConfig;
    this(ParseResult result)
    {
        mParseResult = result;
        mProcessConfig = new ProcessConfig();
        mProcessConfig.setCurrStdin(stdin.fileno());
        mProcessConfig.setCurrStdout(stdout.fileno());
        mProcessConfig.setCurrStderr(stderr.fileno());
        mProcessConfig.setDetached(ProcessConfig.Detached.NO);
        mProcessConfig.setPipe(ProcessConfig.Pipe.NO);
    }

    void interpret()
    {
        mParseResult.accept(this);
    }

    void visit(ParseResult.Command command)
    {
        auto psm = new ProcessManager(command, mProcessConfig);
        psm.exec();
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

        mProcessConfig.setCurrStdout(p[wrtiteEnd]);
        pipeCommand.leftCommand().accept(this);
        mProcessConfig.setCurrStdout(stdout.fileno());
        
        mProcessConfig.setPipe(ProcessConfig.Pipe.YES);
        mProcessConfig.setCurrStdin(p[readEnd]);
        pipeCommand.rightCommand().accept(this);
        mProcessConfig.setCurrStdin(stdin.fileno());
        mProcessConfig.setPipe(ProcessConfig.Pipe.NO);
    }

    void visit(ParseResult.And andCommand)
    {
        andCommand.leftCommand().accept(this);
        if (mProcessConfig.currStatus == 0) andCommand.rightCommand().accept(this);
    }

    void visit(ParseResult.BackGroundProcess command)
    {
        mProcessConfig.setDetached(ProcessConfig.Detached.YES);
        command.leftCommand().accept(this);
        
        writeln("Started '" ~ to!string(mProcessConfig.id) ~ "' in the background");
        
        mProcessConfig.setDetached(ProcessConfig.Detached.NO);
        if (!command.rightCommand().isNull) command.rightCommand().get().accept(this);
    }

    void visit(ParseResult.Or orCommand)
    {
        orCommand.leftCommand().accept(this);
        if (mProcessConfig.currStatus != 0) orCommand.rightCommand().accept(this);
    }
    
    void visit(ParseResult.LRRedirection lrRedirection)
    {
        if (ParseResult.Command command = cast(ParseResult.Command) lrRedirection.rightCommand()) {
            string name = command.processName();
            FILE * fp = fopen(toStringz(name), "w");
            scope (exit) fclose(fp);
            if (fp !is null) {
                mProcessConfig.setCurrStdout(fileno(fp));
            }
            lrRedirection.leftCommand().accept(this);
            mProcessConfig.setCurrStdout(stdout.fileno());
        }
    }

    void visit(ParseResult.RLRedirection rlRedirection)
    {
        if (ParseResult.Command command = cast(ParseResult.Command) rlRedirection.leftCommand()) {
            string name = command.processName();
            FILE * fp = fopen(toStringz(name), "w");
            scope (exit) fclose(fp);
            if (fp !is null) {
                mProcessConfig.setCurrStdout(fileno(fp));
            }
            rlRedirection.rightCommand().accept(this);
            mProcessConfig.setCurrStdout(stdout.fileno());
        }
    }

    void visit(ParseResult.Sequence seqCommand)
    {
        seqCommand.leftCommand().accept(this);
        if (!seqCommand.rightCommand().isNull) seqCommand.rightCommand().get().accept(this);
    }
}