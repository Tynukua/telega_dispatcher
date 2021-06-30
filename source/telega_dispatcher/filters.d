module telega_dispatcher.filters;

import std.meta:Alias;
import telega.telegram.basic;
import telega.telegram.inline;

interface Filter(T){
    bool check(T);
    Filter!T opBinary(string op)(Filter!T b ){
        static assert(op in ["|", "&"]);
        auto a = this;
        return new class Filter!T{
            bool check(T u){
                return mixin(`a.check(u)` ~ op ~op~  `b.check(u)`);
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

