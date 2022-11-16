module parser;
import parseresult;
import std.conv;
import std.ascii;
import std.algorithm;

class Parser
{
    private string mSrc;
    private int mCurrIndex;
    private char[] mOperators;
    this(string src)
    {
        mSrc = src;
        mCurrIndex = 0;
        mOperators = ['|', '&', '>', '<', ';'];
    }

    bool isAtEnd()
    {
        return mCurrIndex >= mSrc.length;
    }

    void advance()
    {
        mCurrIndex++;
    }

    char curr()
    {
        return mSrc[mCurrIndex];
    }

    char prev()
    {
        return mSrc[mCurrIndex-1];
    }

    ParseResult parse()
    {
        auto ltCommand = parseCommand();

        if (!isAtEnd()) {
            switch (curr()) {
                case '|':
                {
                    advance();
                    if (!isAtEnd() && curr() == '|') {
                        advance();
                        auto rtCommand = parse();
                        return new ParseResult.Or(ltCommand, rtCommand);
                    }

                    auto rtCommand = parse();
                    return new ParseResult.Pipe(ltCommand, rtCommand);
                }
                case '&':
                {
                    advance();
                    if (!isAtEnd() && curr() == '&') {
                        advance();
                        auto rtCommand = parse();
                        return new ParseResult.And(ltCommand, rtCommand);
                    }

                    return new ParseResult.BackGroundProcess(ltCommand);
                }
                case '>':
                {
                    advance();
                    auto rtCommand = parse();
                    return new ParseResult.LRRedirection(ltCommand, rtCommand);
                }
                case '<':
                {
                    advance();
                    auto rtCommand = parse();
                    return new ParseResult.RLRedirection(rtCommand, ltCommand);
                }
                case ';':
                {
                    advance();
                    auto rtCommand = parse();
                    return new ParseResult.Sequence(ltCommand, rtCommand);
                }
                default: throw new Exception("Not recognized operator '" ~ to!string(curr()) ~ "'");
            }
        }

        return ltCommand;
    }

    ParseResult.Command parseCommand()
    {
        // get rid of starting white space
        while (curr() == ' ') advance();
        
        string psName;
        while (!isAtEnd()) {
            if (curr() == ' ') break;
            psName ~= curr();
            advance();           
        }

        // pass ' '
        advance();

        string[] args;
        string currArg;
        while (!isAtEnd()) {
            if (curr() == '\'' || curr() == '"') {
                advance();
                continue;
            }
            if (curr() == ' ') {
                args ~= currArg;
                currArg = "";
                advance();
                continue;
            }
            if (mOperators.canFind(curr())) break;

            currArg ~= curr();
            advance();
        }

        if (currArg.length > 0) args ~= currArg;

        return new ParseResult.Command(psName, args);
    }
}