module parser;

import parseresult;
import lexer;

import std.conv;
import std.ascii;
import std.algorithm;
import std.typecons;
import std.stdio;

enum Associativity
{
    LEFT, RIGHT
}

struct OpInfo
{
    Associativity assoc;
    int precdence;
}

class Parser
{
    private Token[] mTokens;
    private int mCurrIndex;
    this(Token[] tokens)
    {
        mTokens = tokens;
        mCurrIndex = 0;
    }

    bool isAtEnd()
    {
        return mCurrIndex >= mTokens.length;
    }

    void advance()
    {
        mCurrIndex++;
    }

    Token curr()
    {
        return mTokens[mCurrIndex];
    }

    Token prev()
    {
        return mTokens[mCurrIndex-1];
    }

    OpInfo getOpInfo(string op)
    {
        switch (op)
        {
            case "|": return OpInfo(Associativity.LEFT, 2);
            case "||": return OpInfo(Associativity.LEFT, 2);
            case "&": return OpInfo(Associativity.LEFT, 1);
            case "&&": return OpInfo(Associativity.LEFT, 2);
            case ";": return OpInfo(Associativity.LEFT, 2);
            case "<": return OpInfo(Associativity.LEFT, 2);
            case ">": return OpInfo(Associativity.LEFT, 2);
            default: break; 
        }

        throw new Exception("Operator '" ~ op ~ "' is not supported");
    }

    ParseResult parse()
    {
        return _parse().get();
    }

    Nullable!ParseResult _parse(int minPrecedence = 0) {
        auto ltCommand = parseCommand();

        while (!isAtEnd()) {
            auto op = curr().lexeme();
            auto opInfo = getOpInfo(op);

            if (opInfo.precdence < minPrecedence) break;

            int nextMinPrec = opInfo.assoc == Associativity.LEFT ? opInfo.precdence + 1 : opInfo.precdence;
            
            advance();
            auto rtCommand = _parse(nextMinPrec);

            switch (op) {
                case "|": 
                {
                    if (rtCommand.isNull) throw new Exception("Expected a command after '" ~ op ~ "'");
                    ltCommand = new ParseResult.Pipe(ltCommand.get, rtCommand.get); break;
                }
                case "||":
                {
                    if (rtCommand.isNull) throw new Exception("Expected a command after '" ~ op ~ "'");
                    ltCommand = new ParseResult.Or(ltCommand.get, rtCommand.get); break;
                }
                case "&&":
                {
                    if (rtCommand.isNull) throw new Exception("Expected a command after '" ~ op ~ "'");
                    ltCommand = new ParseResult.And(ltCommand.get, rtCommand.get); break;
                }
                case "&":
                {
                    if (rtCommand.isNull) {
                        ltCommand = new ParseResult.BackGroundProcess(ltCommand.get); break;
                    }
                    ltCommand = new ParseResult.BackGroundProcess(ltCommand.get, rtCommand.get); break;
                }
                case ";":
                {
                    if (rtCommand.isNull) {
                        ltCommand = new ParseResult.Sequence(ltCommand.get); break;
                    }

                    ltCommand = new ParseResult.Sequence(ltCommand.get, rtCommand.get); break;
                }
                case "<":
                {   
                    if (rtCommand.isNull) throw new Exception("Expected a command after '" ~ op ~ "'");
                    ltCommand = new ParseResult.RLRedirection(ltCommand.get, rtCommand.get); break;
                }
                case ">":
                {
                    if (rtCommand.isNull) throw new Exception("Expected a command after '" ~ op ~ "'");
                    ltCommand = new ParseResult.LRRedirection(ltCommand.get, rtCommand.get); break;
                }
                default: break;
            } 
        }

        return ltCommand;
    }

    Nullable!ParseResult parseCommand()
    {
        if (isAtEnd()) return Nullable!ParseResult.init;
        if (curr().type() == TokenType.COMMAND) {
            ParseResult command = new ParseResult.Command(curr().lexeme(), curr().args().get());
            advance();
            return command.nullable;
        }

        throw new Exception("Expected type command instead got '" ~ curr().lexeme() ~ "'");
    }
}