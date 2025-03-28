#include <sourcemod>

#define VOTETYPE_LENGTH 50
#define FORMATTEDTIME_LENGTH 50

ConVar g_cvExtendLevelTimeLimit;

public Plugin myinfo = {
    name = "TF2 Extend Level Time Limit",
    author = "Eric Zhang",
    description = "Disable extend level vote until a certain amount of time is left in map.",
    version = "1.0",
    url = "https://ericaftereric.top"
}

public void OnPluginStart() {
    g_cvExtendLevelTimeLimit = CreateConVar("sv_vote_issue_extendlevel_timelimit", "300", "Minimum amount of remaining time on the map can players call an extend level vote (in seconds).");
    AddCommandListener(HandleCallVote, "callvote");
    AutoExecConfig(true);
}

void FormatSeconds(int time, char[] formattedTime, int maxlen) {
    int minutes = (time / 60) % 60;
    int seconds = time % 60;
    char minutesText[8] = "minutes", secondsText[8] = "seconds";

    if (minutes == 1) {
        minutesText = "minute";
    }
    if (seconds == 1) {
        secondsText = "second";
    }

    if (minutes == 0) {
       Format(formattedTime, maxlen, "%d %s", seconds, secondsText);
    } else {
        if (seconds != 0) {
            Format(formattedTime, maxlen, "%d %s %d %s", minutes, minutesText, seconds, secondsText);
        } else {
            Format(formattedTime, maxlen, "%d %s", minutes, minutesText);
        }
    }
}

public Action HandleCallVote(int client, const char[] command, int argc) {
    char voteType[VOTETYPE_LENGTH];

    GetCmdArg(1, voteType, sizeof(voteType));

    if (StrEqual(voteType, "extendlevel", false)) {
        int timeleft;
        if (GetMapTimeLeft(timeleft)) {
            if (timeleft < 0) {
                PrintToChat(client, "Map time limit is infinite.");
                return Plugin_Handled;
            }
            if (timeleft > g_cvExtendLevelTimeLimit.IntValue) {
                char formattedTime[FORMATTEDTIME_LENGTH];
                FormatSeconds(g_cvExtendLevelTimeLimit.IntValue, formattedTime, sizeof(formattedTime));
                PrintToChat(client, "You must wait until the map timer has %s or less time left to call an extend level vote.", formattedTime);
                return Plugin_Handled;
            } else {
                return Plugin_Continue;
            }
        } else {
            return Plugin_Continue;
        }
    } else {
        return Plugin_Continue;
    }
}