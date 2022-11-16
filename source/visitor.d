module visitor;

import parseresult;

interface Visitor
{
    void visit(ParseResult.Command v);
    void visit(ParseResult.Pipe v);
    void visit(ParseResult.And v);
    void visit(ParseResult.BackGroundProcess v);
    void visit(ParseResult.Or v);
    void visit(ParseResult.LRRedirection v);
    void visit(ParseResult.RLRedirection v);
    void visit(ParseResult.Sequence v);
}