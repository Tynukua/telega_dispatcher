module telega_dispatcher.filters;

import std.meta:Alias;
import telega.telegram.basic;
import telega.telegram.inline;

interface Filter(T){
    bool check(T);
}

//alias UpdateFilter = Filter!Update;
alias MessageFilter = Filter!Message;
interface EditedMessageFilter: MessageFilter{};
alias InlineQueryFilter = Filter!InlineQuery;
//alias ChosenInlineResultFilter = Filter!ChosenInlineResult;
alias CallbackQueryFilter = Filter!CallbackQuery;

class TextFilter: MessageFilter, EditedMessageFilter, CallbackQueryFilter{
    string text;
    this(string text){
        this.text = text;
    }
    bool check(Message m){
        if (!m.text.isNull){
            if (m.text.get == text){
                return true;
            }
        }
        return false;
    }
    bool check(CallbackQuery c){
        return (c.data == text);
    }

}

class CommandFilter: MessageFilter{
    string[] cmds;
    this(string[] commands ...)
    {
        this.cmds = commands;
    }
    bool check(Message m){
        if(!m.entities.isNull){
            foreach(MessageEntity e; m.entities.get){
                if(e.type == MessageEntityType.BotCommand)
                {   
                    
                    const auto CMDSTART = (e.offset+1);
                    const auto CMDEND   = (e.offset + e.length);

                    ulong cmdEnd(){
                        ulong cmdEnd = 0;
                        foreach (l;m.text.get[CMDSTART..CMDEND]){
                            if(l == '@')
                                return cmdEnd;
                            cmdEnd++;
                        }              
                        return cmdEnd;      
                    }
                    auto cmdText = m.text.get[CMDSTART..cmdEnd+1];
                    import std.algorithm.searching:canFind;
                    if(cmds.canFind(cmdText))
                        return true;
                }
            }
        }
        return false;
    }
}




