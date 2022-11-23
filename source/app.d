import std.stdio;
import parser;
import interpreter;
import lexer;

import std.process;
import std.string;
import core.stdc.stdlib;
import core.stdc.string;
import std.string;
import std.conv;

extern (C) {
    char * readline(const char *);
    void add_history(const char*);
}

alias readLine = readline;
alias addHistory = add_history;

string getPrompt()
{
    string userName;
    auto pipe = pipeProcess("whoami");
    foreach (line; pipe.stdout.byLine) userName ~= line;
    
    string hostName;
    pipe = pipeProcess("hostname");
    foreach (line; pipe.stdout.byLine) hostName ~= line;
    
    return userName ~ "@" ~ hostName;
}

void main()
{
    string prompt = getPrompt();

    while (true) {

        char * line;
        if ((line = readLine(toStringz(prompt ~ "> "))) !is null) {
            if (strcmp(line, "exit") == 0) { 
                if (line !is null) free(line);
                return;
            }
            if (strlen(line) < 1) continue;
            add_history(line);
        } else {
            return;
        }
        
        try {
            auto lex = new Lexer(to!string(line));
            auto parser = new Parser(lex.tokenize());
            auto interpreter = new Interpreter(parser.parse());
            interpreter.interpret();
        } catch (Exception ex) {
            writeln(ex.msg);
        } finally {
            if (line !is null) free(line);
        }
    }
}
