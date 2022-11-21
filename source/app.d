import std.stdio;
import parser;
import interpreter;

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
            if (strcmp(line, "exit") == 0) exit(0);
            if (strlen(line) < 1) continue;
            add_history(line);
        } else {
            exit(0);
        }
        
        try {
            auto parser = new Parser(to!string(line));
            auto interpreter = new Interpreter(parser.parse());
            interpreter.interpret();
        } catch (Exception ex) {
            writeln(ex.msg);
        } finally {
            free(line);
        }
    }
}
