import std.stdio;
import parser;

void main()
{
	string src1 = "youtube-dl -g 'https://www.youtube.com/watch?v=nDbeqj-1XOo'";
    string src2 = "youtube-dl -g 'https://www.youtube.com/watch?v=nDbeqj-1XOo' | vlc";
    string src3 = "youtube-dl -g 'https://www.youtube.com/watch?v=nDbeqj-1XOo' && neofetch";
    string src4 = "youtube-dl -g 'https://www.youtube.com/watch?v=nDbeqj-1XOo' &";
    string src5 = "youtube-dl -g 'https://www.youtube.com/watch?v=nDbeqj-1XOo' > out.txt";
    string src6 = "out.txt < youtube-dl -g 'https://www.youtube.com/watch?v=nDbeqj-1XOo'";
    auto parser = new Parser(src6);
    writeln(parser.parse());
}
