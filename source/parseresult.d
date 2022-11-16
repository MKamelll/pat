module parseresult;
import std.conv;
import visitor;

abstract class ParseResult
{
    abstract void accept(Visitor v);
    
    static class Command : ParseResult
    {
        private string mProcessName;
        private string[] mArgs;
        this(string psName, string[] args)
        {
            mProcessName = psName;
            mArgs = args;
        }

        string processName()
        {
            return mProcessName;
        }

        string[] args()
        {
            return mArgs;
        }

        override void accept(Visitor v)
        {
            v.visit(this);
        }

        override string toString()
        {
            return "Command(ps: '" ~ mProcessName ~ "', args: " ~ to!string(mArgs);
        }
    }

    static class Pipe : ParseResult
    {
        private Command mLeftCommand;
        private ParseResult mRightCommand;
        this(Command lc, ParseResult rc)
        {
            mLeftCommand = lc;
            mRightCommand = rc;
        }

        Command leftCommand()
        {
            return mLeftCommand;
        }

        ParseResult rightCommand()
        {
            return mRightCommand;
        }

        override void accept(Visitor v)
        {
            v.visit(this);
        }

        override string toString()
        {
            return "Pipe(left: " ~ mLeftCommand.toString()
                ~ ", right: " ~ mRightCommand.toString() ~ ")";
        }
    }


    static class And : ParseResult
    {
        private Command mLeftCommand;
        private ParseResult mRightCommand;
        this(Command lc, ParseResult rc)
        {
            mLeftCommand = lc;
            mRightCommand = rc;
        }
        
        override void accept(Visitor v)
        {
            v.visit(this);
        }

        override string toString()
        {
            return "And(left: " ~ mLeftCommand.toString()
                ~ ", right: " ~ mRightCommand.toString() ~ ")";
        }
    }

    static class Or : ParseResult
    {
        private Command mLeftCommand;
        private ParseResult mRightCommand;
        this(Command lc, ParseResult rc)
        {
            mLeftCommand = lc;
            mRightCommand = rc;
        }

        override void accept(Visitor v)
        {
            v.visit(this);
        }

        override string toString()
        {
            return "Or(left: " ~ mLeftCommand.toString()
                ~ ", right: " ~ mRightCommand.toString() ~ ")";
        }
    }

    static class BackGroundProcess : ParseResult
    {
        private ParseResult mCommand;
        this(ParseResult cmd)
        {
            mCommand = cmd;
        }

        override void accept(Visitor v)
        {
            v.visit(this);
        }

        override string toString()
        {
            return "BackGround(left: " ~ mCommand.toString() ~ ")";
        }
    }

    static class LRRedirection : ParseResult
    {
        private Command mInput;
        private ParseResult mOutput;
        this(Command input, ParseResult output)
        {
            mInput = input;
            mOutput = output;
        }

        override void accept(Visitor v)
        {
            v.visit(this);
        }
        
        override string toString()
        {
            return "LRRedirection(input: " ~ mInput.toString() ~ ", output: " ~ mOutput.toString() ~ ")";
        }
    }

    static class RLRedirection : ParseResult
    {
        private ParseResult mInput;
        private Command mOutput;
        this(ParseResult input, Command output)
        {
            mInput = input;
            mOutput = output;
        }

        override void accept(Visitor v)
        {
            v.visit(this);
        }
        
        override string toString()
        {
            return "RLRedirection(input: " ~ mInput.toString() ~ ", output: " ~ mOutput.toString() ~ ")";
        }
    }

    static class Sequence : ParseResult
    {
        private Command mLeftCommand;
        private ParseResult mRightCommand;
        this(Command lc, ParseResult rc)
        {
            mLeftCommand = lc;
            mRightCommand = rc;
        }

        override void accept(Visitor v)
        {
            v.visit(this);
        }

        override string toString()
        {
            return "Sequence(left: " ~ mLeftCommand.toString()
                ~ ", right: " ~ mRightCommand.toString() ~ ")";
        }
    }
}
