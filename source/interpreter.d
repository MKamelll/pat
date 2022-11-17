module interpreter;

import parseresult : ParseResult;
import visitor;

import std.process;
import std.stdio;

class Interpreter : Visitor
{
    private ParseResult mParseResult;
    private File mCurrStdin;
    private File mCurrStdout;
    private File mCurrStderr;
    private int mCurrStatus;
    this(ParseResult result)
    {
        mParseResult = result;
        mCurrStdin = stdin;
        mCurrStdout = stdout;
        mCurrStderr = stderr;
        mCurrStatus = 0;
    }

    void interpret()
    {
        mParseResult.accept(this);
    }

    void visit(ParseResult.Command command)
    {
        auto payload = command.processName() ~ command.args();
        auto pid = spawnProcess(payload, mCurrStdin, mCurrStdout, mCurrStderr);
        scope(exit) {
            mCurrStatus = wait(pid);
        }        
    }

    void visit(ParseResult.Pipe pipe)
    {
        auto p = std.process.pipe();

        mCurrStdout = p.writeEnd;
        pipe.leftCommand().accept(this);
        mCurrStdout = stdout;
        
        mCurrStdin = p.readEnd;
        pipe.rightCommand().accept(this);
        mCurrStdin = stdin;
    }

    void visit(ParseResult.And andCommand)
    {
        andCommand.leftCommand().accept(this);
        if (mCurrStatus == 0) andCommand.rightCommand().accept(this);
    }

    void visit(ParseResult.BackGroundProcess v)
    {

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
            auto f = new File(name, "w");
            if (f !is null) {
                mCurrStdout = *f;
            }
            lrRedirection.leftCommand().accept(this);
            mCurrStdout = stdout;
        }
    }

    void visit(ParseResult.RLRedirection rlRedirection)
    {
        if (ParseResult.Command command = cast(ParseResult.Command) rlRedirection.leftCommand()) {
            string name = command.processName();
            auto f = new File(name, "w");
            if (f !is null) {
                mCurrStdout = *f;
            }
            rlRedirection.rightCommand().accept(this);
            mCurrStdout = stdout;
        }
    }

    void visit(ParseResult.Sequence seqCommand)
    {
        seqCommand.leftCommand().accept(this);
        seqCommand.rightCommand().accept(this);
    }
}