#include scripts\_utils;
#include scripts\helpers\_io;

/*
Status codes:
0 - request ok
1 - file does not exist
2 - file already exist
3 - authentication error
4 - user banned
5 - already logged in
6 - someone else is using this account
10 - validation error: username
11 - validation error: password
12 - validation error: weak password
20 - registration disabled
*/

/*
'<username>.dat' file structure:
<permisson>,<username>,<password>, // authentication
<scores>,<killscore>,<kills>,<deaths>,<survivedrounds>,<bosskills>, // game statistics
*/

init()
{
    level.asys_register_enabled = true;
    level.autoSaveMinTime = 10000; // must be at least 10 secs between two saves
    level.maxlevel = 60;

    [[level.addCallback]]("onConnect", ::onPlayerConnect);
    [[level.addCallback]]("onPlayerLogin", ::onPlayerLogin);
}

onPlayerConnect()
{
    self.account = [];
    self.account["lastSaveTime"] = 0;
    
    self resetStats();
}

onPlayerLogin()
{
    self endon("disconnect");
    self endon("player_logged_out");

    for (;;)
    {
        if (game["state"] == "intermission")
            break;
            
        if (self.isLogined && GetTime() - self.account["lastSaveTime"] >= level.autoSaveMinTime)
        {
            logPrint("ASYS;autosave;" + self.name + "\n");
            self saveStats();
        }

        wait 1;
    }
}

resetStats()
{
    self.isLogined = false;

    self.pers["login_username"] = "";
    self.pers["login_password"] = "";

    self.account["username"] = "";
    self.account["password"] = "";
    self.account["permission"] = 1;
    self.account["scores"] = 0;
    self.account["killscore"] = 0;
    self.account["kills"] = 0;
    self.account["deaths"] = 0;
    self.account["survived_rounds"] = 0;
    self.account["boss_kills"] = 0;
}

Login()
{
    if (self.isLogined)
        return 5;
    
    if (checkUserInUse())
        return 6;

    logPrint("ASYS;login;" + self.name + "\n");
    result = self loadStats();

    if (!result)
    {
        self.isLogined = true;
        self notify("player_logged_in");
    }

    return result;
}

Logout()
{
    if (!self.isLogined)
        return 5;
    
    logPrint("ASYS;logout;" + self.name + "\n");
    result = self saveStats();

    self.isLogined = false;
    self resetStats();

    self notify("player_logged_out");

    return result;
}

Register()
{
    if (!level.asys_register_enabled)
        return 20;

    if (self.isLogined)
        return 5;

    if (checkUserInUse())
        return 6;

    // validation
    if (self.pers["login_username"].size < 5)
        return 10;
    else if (self.pers["login_password"].size < 5)
        return 11;
    else if (isWeakPassword(self.pers["login_password"]))
        return 12;

    if (IsFileExist("users/" + self.pers["login_username"] + ".dat"))
        return 2;

    Append("allusers.dat", self.pers["login_username"]);

    logPrint("ASYS;register;" + self.name + "\n");
    
    self.account["username"] = self.pers["login_username"];
    self.account["password"] = self.pers["login_password"];

    result = self saveStats();

    if (!result)
    {
        self.isLogined = true;
        self notify("player_logged_in");
    }

    return result;
}

loadStats()
{
    logPrint("ASYS;load;" + self.name + "\n");
    t = ReadTable("users/" + self.pers["login_username"] + ".dat");

    // file exist?
    if (!isDefined(t) || !isDefined(t[0]) || !isDefined(t[1]))
        return 1;

    // authentication
    permission = int(t[0][0]); // 0 - banned, 1 - normal user, 2 - admin
    username = t[0][1];
    password = t[0][2];

    if (username != self.pers["login_username"] || password != self.pers["login_password"])
        return 3;

    if (permission == 0)
        return 4;
    
    self.account["username"] = username;
    self.account["password"] = password;
    self.account["permission"] = permission;
    self.account["scores"] = int(t[1][0]); // score, calculate the rank based on it
    self.account["killscore"] = int(t[1][1]);
    self.account["kills"] = int(t[1][2]);
    self.account["deaths"] = int(t[1][3]);
    self.account["survived_rounds"] = int(t[1][4]);
    self.account["boss_kills"] = int(t[1][5]);

    return 0;
}

saveStats()
{
    self.account["lastSaveTime"] = GetTime();

    t = [];
    t[0] = array(self.account["permission"], self.account["username"], self.account["password"]);
    t[1] = array(self.account["scores"], self.account["killscore"], self.account["kills"], self.account["deaths"], self.account["survived_rounds"], self.account["boss_kills"]);

    logPrint("ASYS;save;" + self.name + "\n");
    WriteTable("users/" + self.account["username"] + ".dat", t);

    return 0;
}

checkUserInUse()
{
    players = getAllPlayers();
    for (i = 0; i < players.size; i++)
    {
        if (players[i].isLogined && players[i].account["username"] == self.account["username"])
            return true;
    }
    return false;
}

isWeakPassword(password)
{
    switch (password)
    {
        case "12345":
        case "123456":
        case "1234567":
        case "12345678":
        case "123456789":
        case "asdas":
        case "asdasd":
        case "asdasdasd":
            return true;
    }
    return false;
}