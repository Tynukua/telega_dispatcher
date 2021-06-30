module telega_dispatcher.filters;

import std.meta:Alias;
import std.algorithm.searching:canFind;

import telega.telegram.basic;
import telega.telegram.inline;

interface Filter(T){
    bool check(T);
    Filter!T opBinary(string op)(Filter!T b ){
        static assert(["|", "&"].canFind(op));
        auto a = this;
        return new class Filter!T{
            bool check(T u){
                return mixin(`a.check(u)` ~ op ~op~  `b.check(u)`);
            }
        };
    }    
    Filter!T opUnary(string op)(){
        static assert(op == "~");
        auto a = this;
        return new class Filter!T{
            bool check(T u){
                return !a.check(u);
            }
        };
    }
}

//alias UpdateFilter = Filter!Update;
alias MessageFilter = Filter!Message;
interface EditedMessageFilter: MessageFilter{};
alias InlineQueryFilter = Filter!InlineQuery;
//alias ChosenInlineResultFilter = Filter!ChosenInlineResult;
alias CallbackQueryFilter = Filter!CallbackQuery;

