module telega_dispatcher;

import std.typecons;

import telega:BotApi;
import telega.telegram.basic:Update,Message;


public import telega_dispatcher.filters;
class Dispatcher{
    BotApi bot;
    this(BotApi bot){
        this.bot = bot;
    }
    void delegate(Message)[MessageFilter] messageHandlers;
    void delegate(Message)[EditedMessageFilter] editedMessageHandlers;
    void delegate(Message)[MessageFilter] postHandlers;
    void delegate(Message)[EditedMessageFilter] editedPostHandlers;

    void runPolling(){
        import telega.telegram.basic : Update, getUpdates, sendMessage;
        import std.algorithm.iteration : filter, each;
        import std.algorithm.comparison : max;
        int offset;
        while (true)
        {
            bot.getUpdates(offset)
                .each!((Update u) {
                    offset = max(offset, u.id) + 1;
                    static foreach(updateFieldName,handlerContainerName; [
                        "message":          "messageHandlers",
                        "edited_message":   "editedMessageHandlers",
                        ]){
                            {
                                auto updateField = __traits(
                                        getMember, u, updateFieldName);
                                auto handlerContainer = __traits(
                                        getMember, this, handlerContainerName);
                                if(!updateField.isNull){
                                    foreach(filter,handler; handlerContainer){
                                        if (filter.check(updateField.get)){
                                            handler(updateField.get);
                                            return;
                                            }
                                    }
                                }
                            }
                        }
                });
        }
    
    }        
            
}
