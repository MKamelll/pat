module parseresult;
import std.conv;

abstract class ParseResult
{
    static class Command : ParseResult
    {
        private string mProcessName;
        private string[] mArgs;
        this(string psName, string[] args)
        {
            mProcessName = psName;
            mArgs = args;
        }

        override string toString()
        {
            return "Command(ps: '" ~ mProcessName ~ "', args: " ~ to!string(mArgs);
        }
    }

    static class Pipe : ParseResult
    {
        private Command mLeftCommand;
        private Command mRightCommand;
        this(Command lc, Command rc)
        {
            mLeftCommand = lc;
            mRightCommand = rc;
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
        private Command mRightCommand;
        this(Command lc, Command rc)
        {
            mLeftCommand = lc;
            mRightCommand = rc;
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
        private Command mRightCommand;
        this(Command lc, Command rc)
        {
            mLeftCommand = lc;
            mRightCommand = rc;
        }

        override string toString()
        {
            return "Or(left: " ~ mLeftCommand.toString()
                ~ ", right: " ~ mRightCommand.toString() ~ ")";
        }
    }

    static class BackGroundProcess : ParseResult
    {
        private Command mCommand;
        this(Command cmd)
        {
            mCommand = cmd;
        }

        override string toString()
        {
            return "BackGround(left: " ~ mCommand.toString() ~ ")";
        }
    }

    static class Redirection : ParseResult
    {
        private Command mInput;
        private Command mOutput;
        this(Command input, Command output)
        {
            mInput = input;
            mOutput = output;
        }
        
        override string toString()
        {
            return "Redirection(input: " ~ mInput.toString() ~ ", output: " ~ mOutput.toString() ~ ")";
        }
    }


    static class Sequence : ParseResult
    {
        private Command mLeftCommand;
        private Command mRightCommand;
        this(Command lc, Command rc)
        {
            mLeftCommand = lc;
            mRightCommand = rc;
        }

        override string toString()
        {
            return "Sequence(left: " ~ mLeftCommand.toString()
                ~ ", right: " ~ mRightCommand.toString() ~ ")";
        }
    }
}
