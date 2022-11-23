module lexer;

import std.conv;
import std.algorithm;
import std.array;
import std.typecons;

enum TokenType
{
    COMMAND, OR, AND, PIPE, BACKGROUNDPROCESS, COLON, LRREDIRECTION, RLREDIRECTION
}

class Token
{
    private TokenType mType;
    private string mLexeme;
    private Nullable!(string[]) mArgs;
    this (TokenType type, string lexeme)
    {
        mType = type;
        mLexeme = lexeme;
    }

    this (TokenType type, string lexeme, string[] args)
    {
        mType = type;
        mLexeme = lexeme;
        mArgs = args.nullable;
    }

    TokenType type()
    {
        return mType;
    }

    string lexeme()
    {
        return mLexeme;
    }

    string[] args()
    {
        if (!mArgs.isNull) {
            return mArgs.get;
        }

        throw new Exception("Trying to get args of a token '" ~ mLexeme ~ "' that doesn't support args");
    }

    override string toString()
    {
        if (!mArgs.isNull) {
            return "Token(type: " ~ to!string(mType) ~ ", lexeme: '"
                ~ mLexeme ~ "', args: " ~ to!string(mArgs.get) ~ ")";
        }
        return "Token(type: " ~ to!string(mType) ~ ", lexeme: '" ~ mLexeme ~ "')";
    }
}

class Lexer
{
    private string mSrc;
    private int mCurrIndex;
    private Token[] mTokens;
    private char[] mOperators;
    this(string src)
    {
        mSrc = src;
        mCurrIndex = 0;
        mTokens = [];
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

    Token[] tokenize()
    {
        getCommand();

        if (!isAtEnd()) {
            switch (curr()) {
                case '|':
                {
                    advance();
                    if (!isAtEnd() && curr() == '|') {
                        advance();
                        mTokens ~= new Token(TokenType.OR, "||");
                        advance();
                        return tokenize();
                    }

                    mTokens ~= new Token(TokenType.PIPE, "|");
                    advance();
                    return tokenize();
                }
                case '&':
                {
                    advance();
                    if (!isAtEnd() && curr() == '&') {
                        advance();
                        mTokens ~= new Token(TokenType.AND, "&&");
                        advance();
                        return tokenize();
                    }
                    
                    mTokens ~= new Token(TokenType.BACKGROUNDPROCESS, "&");
                    advance();
                    return tokenize();
                }
                case '>':
                {
                    advance();
                    mTokens ~= new Token(TokenType.LRREDIRECTION, ">");
                    return tokenize();
                }
                case '<':
                {
                    advance();
                    mTokens ~= new Token(TokenType.RLREDIRECTION, "<");
                    return tokenize();
                }
                case ';':
                {
                    advance();
                    mTokens ~= new Token(TokenType.COLON, ";");
                    return tokenize();
                }
                default: throw new Exception("Not recognized operator '" ~ to!string(curr()) ~ "'");
            }
        }

        return mTokens;
    }

    void getCommand()
    {
        // get rid of starting white space
        while (!isAtEnd() && curr() == ' ') advance();
        
        string psName;
        while (!isAtEnd()) {
            if (mOperators.canFind(curr())) break;
            if (curr() == ' ') break;
            psName ~= curr();
            advance();           
        }

        // pass ' '
        if (!isAtEnd() && curr() == ' ') advance();

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

        if (psName.length > 0) mTokens ~= new Token(TokenType.COMMAND, psName, args);
    }

}