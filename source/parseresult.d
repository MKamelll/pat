module parseresult;

import visitor;

import std.conv;
import std.typecons;

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
            return "Command(ps: '" ~ mProcessName ~ "', args: " ~ to!string(mArgs) ~ ")";
        }
    }

    static class Pipe : ParseResult
    {
        private ParseResult mLeftCommand;
        private ParseResult mRightCommand;

        this(ParseResult lc, ParseResult rc)
        {
            mLeftCommand = lc;
            mRightCommand = rc;
        }

        ParseResult leftCommand()
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
        private ParseResult mLeftCommand;
        private ParseResult mRightCommand;

        this(ParseResult lc, ParseResult rc)
        {
            mLeftCommand = lc;
            mRightCommand = rc;
        }

        ParseResult leftCommand()
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
            return "And(left: " ~ mLeftCommand.toString()
                ~ ", right: " ~ mRightCommand.toString() ~ ")";
        }
    }

    static class Or : ParseResult
    {
        private ParseResult mLeftCommand;
        private ParseResult mRightCommand;

        this(ParseResult lc, ParseResult rc)
        {
            mLeftCommand = lc;
            mRightCommand = rc;
        }

        ParseResult leftCommand()
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
            return "Or(left: " ~ mLeftCommand.toString()
                ~ ", right: " ~ mRightCommand.toString() ~ ")";
        }
    }

    static class BackGroundProcess : ParseResult
    {
        private ParseResult mLeftCommand;
        private Nullable!ParseResult mRightCommand;

        this(ParseResult lc, ParseResult rc)
        {
            mLeftCommand = cast(ParseResult.Command) lc;
            mRightCommand = rc;
        }

        this(ParseResult lc)
        {
            mLeftCommand = lc;
        }

        ParseResult leftCommand()
        {
            return  mLeftCommand;
        }

        Nullable!ParseResult rightCommand()
        {
            return mRightCommand;
        }

        override void accept(Visitor v)
        {
            v.visit(this);
        }

        override string toString()
        {
            if (!mRightCommand.isNull) {
                return "BackGround(left: " ~ mLeftCommand.toString()
                    ~ ", right: " ~ mRightCommand.get().toString() ~ ")";
            }
            return "BackGround(left: " ~ mLeftCommand.toString() ~ ")";
        }
    }

    static class LRRedirection : ParseResult
    {
        private ParseResult mInput;
        private ParseResult mOutput;

        this(ParseResult input, ParseResult output)
        {
            mInput = input;
            mOutput = output;
        }

        ParseResult leftCommand()
        {
            return mInput;
        }

        ParseResult rightCommand()
        {
            return mOutput;
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
        private ParseResult mOutput;
        private ParseResult mInput;

        this(ParseResult output, ParseResult input)
        {
            mOutput = output;
            mInput = input;
        }

        ParseResult leftCommand()
        {
            return mInput;
        }

        ParseResult rightCommand()
        {
            return mOutput;
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
        private ParseResult mLeftCommand;
        private Nullable!ParseResult mRightCommand;

        this(ParseResult lc, ParseResult rc)
        {
            mLeftCommand = cast(ParseResult.Command) lc;
            mRightCommand = rc.nullable;
        }

        this(ParseResult lc)
        {
            mLeftCommand = cast(ParseResult.Command) lc;
        }

        ParseResult leftCommand()
        {
            return mLeftCommand;
        }

        Nullable!ParseResult rightCommand()
        {
            return mRightCommand;
        }

        override void accept(Visitor v)
        {
            v.visit(this);
        }

        override string toString()
        {
            if (!mRightCommand.isNull) {
                return "Sequence(left: " ~ mLeftCommand.toString() ~ ", right: " ~ mRightCommand.toString() ~ ")";
            }

            return "Sequence(left: " ~ mLeftCommand.toString() ~ ")";
        }
    }
}
