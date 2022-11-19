import std.stdio;
import parser;
import interpreter;

import std.process;
import std.string;
import core.stdc.stdlib;

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
        
        if (isSigInt) {
            isSigInt = false;
            continue;
        }

        write(prompt ~ "> ");

        string line;
        if ((line = readln()) !is null) {
            line = line.strip();
            if (line == "exit") exit(0);
            if (line.length < 1) continue;
        } else {
            exit(0);
        }
        
        try {
            auto parser = new Parser(line);
            auto interpreter = new Interpreter(parser.parse());
            interpreter.interpret();
        } catch (Exception ex) {
            writeln(ex.msg);
        }
    }
}
