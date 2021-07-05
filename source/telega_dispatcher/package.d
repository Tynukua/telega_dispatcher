module telega_dispatcher;

import std.typecons;

import telega:BotApi;
import vibe.core.log: logInfo;
import telega.telegram.basic:Update,Message;


public import telega_dispatcher.filters;
public import telega_dispatcher.builtin_filters;
class Dispatcher{
    BotApi bot;
    this(BotApi bot){
        this.bot = bot;
    }
    void delegate(Message)[MessageFilter] messageHandlers;
    void delegate(Message)[MessageFilter] editedMessageHandlers;
    void delegate(Message)[MessageFilter] postHandlers;
    void delegate(Message)[MessageFilter] editedPostHandlers;

    void runPolling(){
        import telega.telegram.basic : Update, getUpdates, sendMessage;
        import std.algorithm.iteration : filter, each;
        import std.algorithm.comparison : max;
        int offset = -1;
        while (true)
        {
            bot.getUpdates(offset)
                .each!((Update u) {
                    offset = max(offset, u.id) + 1;
                    try{
                        runUpdate(u);
                    }
                    catch(Throwable e){
                        e.toString.logInfo;
                        // TODO: make exception handling;
                    }
                });
        }
    
    } 

    static foreach (handlerName, filterType_delegateType; [
            "messageHandler":       ["MessageFilter", "Message"],
            "editedMessageHandler": ["MessageFilter", "Message"],
            "postHandler":          ["MessageFilter", "Message"],
            "editedPostHandler":    ["MessageFilter", "Message"]]){
        mixin(`auto ` ~ handlerName~ "("~ filterType_delegateType[0]~ ` filter, void delegate(` ~filterType_delegateType[1]~ `) handler){
            `~ handlerName~`s[filter] = handler;
            return handler;    
        }`);  
        mixin(`auto ` ~ handlerName~ `(bool delegate(`~ filterType_delegateType[1]~`) filter, void delegate(` ~filterType_delegateType[1]~ `) handler){
            `~ handlerName~`s[ new FunctionFilter!(`~filterType_delegateType[1]~`, `~filterType_delegateType[0]~`)(filter)] = handler;
            return handler;
            }`);  
    }
    void runUpdate(Update u){
         static foreach(updateFieldName,handlerContainerName; [
             "message":          "messageHandlers",
             "edited_message":   "editedMessageHandlers",
             "channel_post":             "postHandlers",
             "edited_channel_post":      "editedPostHandlers"]){
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
    }    
            
}
