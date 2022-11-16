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
    this(ParseResult result)
    {
        mParseResult = result;
        mCurrStdin = stdin;
        mCurrStdout = stdout;
        mCurrStderr = stderr;
    }

    void interpret()
    {
        mParseResult.accept(this);
    }

    void visit(ParseResult.Command command)
    {
        auto payload = command.processName() ~ command.args();
        auto pid = spawnProcess(payload, mCurrStdin, mCurrStdout, mCurrStderr);
        scope(exit) wait(pid);        
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

    void visit(ParseResult.And v)
    {

    }

    void visit(ParseResult.BackGroundProcess v)
    {

    }

    void visit(ParseResult.Or v)
    {

    }
    
    void visit(ParseResult.LRRedirection v)
    {

    }


    void visit(ParseResult.RLRedirection v)
    {

    }

    void visit(ParseResult.Sequence v)
    {
        
    }
}