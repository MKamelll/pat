import std.stdio;
import parser;
import interpreter;

void main()
{
	string src1 = "youtube-dl -g 'https://www.youtube.com/watch?v=nDbeqj-1XOo'";
    string src2 = "youtube-dl -gx 'https://soundcloud.com/aofathy/3alameen' | xargs vlc";
    string src3 = "youtube-dl -g 'https://www.youtube.com/watch?v=nDbeqj-1XOo' && neofetch";
    string src4 = "youtube-dl -g 'https://www.youtube.com/watch?v=nDbeqj-1XOo' &";
    string src5 = "youtube-dl -g 'https://www.youtube.com/watch?v=nDbeqj-1XOo' > out.txt";
    string src6 = "out.txt < youtube-dl -g 'https://www.youtube.com/watch?v=nDbeqj-1XOo'";
    string src7 = "youtube-dl -g 'https://www.youtube.com/watch?v=nDbeqj-1XOo' ; neofetch";
    string src8 = "neofetch";
    string src9 = "gcc";
    string src10 = "echo 'hello' | wc -l";
    string src11 = "echo 'hello' | grep --color=always 'he' | wc -l | xargs echo 'Number of lines is: '";
    auto parser = new Parser(src2);
    auto interpreter = new Interpreter(parser.parse());
    interpreter.interpret();
}
