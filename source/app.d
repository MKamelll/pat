import std.stdio;
import parser;
import interpreter;
import std.process;
import std.string;
import core.stdc.stdlib;

void main()
{
    string userName;
    auto pipe = pipeProcess("whoami");
    foreach (line; pipe.stdout.byLine) userName ~= line;
    
    string hostName;
    pipe = pipeProcess("hostname");
    foreach (line; pipe.stdout.byLine) hostName ~= line;
    
    auto userInfo = userName ~ "@" ~ hostName;
    
    while (true) {
        write(userInfo ~ "> ");
        
        string line;
        if ((line = readln()) !is null) {
            line = line.strip();
            if (line == "exit") exit(0);
            if (line.length < 1) continue;
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
