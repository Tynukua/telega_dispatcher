module telega_dispatcher.builtin_filters;

import telega;

import telega_dispatcher.filters;

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

class RegexFilter: MessageFilter,EditedMessageFilter,CallbackQueryFilter{
    import std.regex;
    Regex!char regexp;
    // TODO: matchCache
    this(string regexp){
       this.regexp = regex(regexp );
    }
    bool check(Message m){
        if (m.text.isNull) return false;
        return !(matchFirst(m.text.get, regexp).empty) ;      
    }
    bool check(CallbackQuery c){
        return !(matchFirst(c.data, regexp).empty) ;      
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

