import std.stdio;
import parser;
import interpreter;

void main()
{
	string src1 = "youtube-dl -g 'https://www.youtube.com/watch?v=nDbeqj-1XOo'";
    string src2 = "youtube-dl -g 'https://www.youtube.com/watch?v=nDbeqj-1XOo' | vlc";
    string src3 = "youtube-dl -g 'https://www.youtube.com/watch?v=nDbeqj-1XOo' && neofetch";
    string src4 = "youtube-dl -g 'https://www.youtube.com/watch?v=nDbeqj-1XOo' &";
    string src5 = "youtube-dl -g 'https://www.youtube.com/watch?v=nDbeqj-1XOo' > out.txt";
    string src6 = "out.txt < youtube-dl -g 'https://www.youtube.com/watch?v=nDbeqj-1XOo'";
    string src7 = "youtube-dl -g 'https://www.youtube.com/watch?v=nDbeqj-1XOo' ; neofetch";
    string src8 = "neofetch";
    string src9 = "gcc";
    auto parser = new Parser(src8);
    auto interpreter = new Interpreter(parser.parse());
    interpreter.interpret();
}
