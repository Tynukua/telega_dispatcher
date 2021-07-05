import vibe.core.core : runApplication, runTask, disableDefaultSignalHandlers;
import vibe.core.log : setLogLevel, logInfo, LogLevel;
import std.process : environment;
import std.exception : enforce;
import telega.botapi:BotApi;
import telega.telegram.basic:Message;
import telega_dispatcher:Dispatcher;
import telega_dispatcher.filters;
import telega_dispatcher.builtin_filters;
import telega.telegram.basic : Update, getUpdates, sendMessage;
int main(string[] args)
{
    string botToken = environment.get("BOT_TOKEN");

    if (args.length > 1 && args[1] != null) {
        logInfo("Setting token from first argument");
        botToken = args[1];
    }

    enforce(botToken !is null, "Please provide bot token as a first argument or set BOT_TOKEN env variable");

    setLogLevel(LogLevel.diagnostic);
    auto bot = new BotApi(botToken);
    auto dp = new Dispatcher(bot);
    // using of ready filter
    dp.messageHandler(new CommandFilter("start", "help"), (Message m){
        bot.sendMessage(m.chat.id, 
                "Hi! I'm test bot for displaing telega_dispatcher!");
        });
    
    // bool operations under filters
    auto pingNotPong = new RegexFilter("ping") & ~ new RegexFilter("pong");
    dp.editedMessageHandler(pingNotPong,
    dp.messageHandler(pingNotPong, (Message m){
            bot.sendMessage(m.chat.id,"PingPong!!!");
        }));
    // using functions as filters
    dp.messageHandler((Message m)=> ( m.text.get.length>10), (Message m){
        bot.sendMessage(m.chat.id, "Hello, lox");
    });
    // creating of costum filter
    dp.editedMessageHandler(new class MessageFilter{
            bool check(Message m){
                return ! m.text.isNull;
            }
        }, (Message m){
                bot.sendMessage(m.chat.id, "new text: "~m.text.get);
        });

    
    runTask(&dp.runPolling);
    disableDefaultSignalHandlers();

    return runApplication();
}
