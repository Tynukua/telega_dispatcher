import vibe.core.core : runApplication, runTask, disableDefaultSignalHandlers;
import vibe.core.log : setLogLevel, logInfo, LogLevel;
import std.process : environment;
import std.exception : enforce;
import telega.botapi:BotApi;
import telega.telegram.basic:Message;
import telega_dispatcher:Dispatcher,TextFilter,EditedMessageFilter,CommandFilter,RegexFilter;
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
    auto pingNotPong = new RegexFilter("ping") & ~ new RegexFilter("pong");
    dp.messageHandlers[pingNotPong] = (Message m){
            bot.sendMessage(m.chat.id,"PingPong!!!");
        };
    // creating of costum filter
    dp.editedMessageHandlers[new class EditedMessageFilter{
            bool check(Message m){
                return ! m.text.isNull;
            }
        }] = (Message m){
                bot.sendMessage(m.chat.id, "new text: "~m.text);
        };
    dp.messageHandlers[new CommandFilter("start", "help")] = (Message m){
        bot.sendMessage(m.chat.id, 
                "Hi! I'm test bot for displaing telega_dispatcher!");
    }
    ;

    runTask(&dp.runPolling);
    disableDefaultSignalHandlers();

    return runApplication();
}
