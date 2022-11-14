module interpreter;

import parseresult : ParseResult;

import std.process;
import std.stdio;

class Interpreter
{
    private ParseResult mParseResult;
    this(ParseResult result)
    {
        mParseResult = result;
    }

    void interpret()
    {
        return interpretCommand();
    }

    void interpretCommand()
    {
        if (ParseResult.Command command = cast(ParseResult.Command) mParseResult) {
            auto payload = command.processName() ~ command.args();
            auto pipes = pipeProcess(payload, Redirect.stdout | Redirect.stderr);
            foreach (line ; pipes.stdout.byLine) writeln(line);
            foreach (line; pipes.stderr.byLine) writeln(line);
            scope(exit) wait(pipes.pid);
        } else {
            return interpretPipe();
        }
        
    }

    void interpretPipe()
    {
        throw new Exception("Unimplemented");
    }
}