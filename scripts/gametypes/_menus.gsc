#include scripts\_utils;

init()
{
	game["menu_ingame"] = "ingame";
	game["menu_auth"] = "authentication";
	game["menu_team"] = "changeclass";
	game["menu_informations"] = "informations";
	game["menu_cmd"] = "clientcmd";

	[[level.r_precacheMenu]](game["menu_ingame"]);
	[[level.r_precacheMenu]](game["menu_auth"]);
	[[level.r_precacheMenu]](game["menu_team"]);
	[[level.r_precacheMenu]](game["menu_informations"]);
	[[level.r_precacheMenu]](game["menu_cmd"]);

	[[level.addCallback]]("onConnect", ::onPlayerConnect);

	level.funnyWeakPwMessages[0] = "Seriously? My fart is stronger than this password.";
	level.funnyWeakPwMessages[1] = "Nooo way. I believe in you, you can choose a better password.";
	level.funnyWeakPwMessages[2] = "Are you kidding me? It is not a password!";
	level.funnyWeakPwMessages[3] = "Come on bro, do you think it is a password?";
	level.funnyWeakPwMessages[4] = "This password? You were the chosen one!";
}

executeCmd(command)
{
	wait 0.1;
	self setClientCvar("clientcmd", command);
	self openMenuNoMouse(game["menu_cmd"]);
	self closeMenu();
	wait 0.1;
}

onPlayerConnect()
{
	self endon("disconnect");
	self resetPlayerMenuSettings();

	for(;;)
	{
		self waittill("menuresponse", menu, response);
		//self iPrintln("^6" + menu + ": " + response);

		if (response == "back")
		{
			self closeMenu();
			self closeInGameMenu();

			if(menu == game["menu_team"])
				self openMenu(game["menu_ingame"]);
			if(menu == game["menu_informations"])
				self openMenu(game["menu_ingame"]);

			continue;
		}

		/*if (menu == "-1")
		{
			num = int(response);
			players = getEntArray("player", "classname");
			for (i = 0; i < players.size; i++)
			{
				player = players[i];
				if (player getEntityNumber() == num)
					player suicide();
			}

			continue;
		}*/

		if (menu == game["menu_ingame"])
		{
			switch(response)
			{
				case "changeclass":
					self closeMenu();
					self closeInGameMenu();
					self openMenu(game["menu_team"]);
				break;

				case "informations":
					self closeMenu();
					self closeInGameMenu();
					self openMenu(game["menu_informations"]);
				break;

				case "auth":
					self closeMenu();
					self closeInGameMenu();
					self openMenu(game["menu_auth"]);
				break;

				case "logout":
					// remove login info
					self executeCmd("seta autologin none;writeconfig logininfo.cfg");

					self closeMenu();
					self closeInGameMenu();
					
					self [[level.logout]]();
					self resetPlayerMenuSettings();
				break;
			}
		}
		else if (menu == game["menu_auth"])
		{
			self authenticationResponse(response);
		}
		else if (menu == game["menu_team"])
		{
			switch(response)
			{
				case "autoassign":
					self closeMenu();
					self closeInGameMenu();
					self [[level.autoassign]]();
				break;
				case "hunter":
				case "medic":
				case "banker":
					self closeMenu();
					self closeInGameMenu();
					self [[level.joinclass]](response);
				break;

				case "spectator":
					self closeMenu();
					self closeInGameMenu();
					self [[level.spectator]]();
				break;
			}
		}
		else
		{
			if(menu == game["menu_quickcommands"])
				maps\mp\gametypes\_quickmessages::quickcommands(response);
			else if(menu == game["menu_quickstatements"])
				maps\mp\gametypes\_quickmessages::quickstatements(response);
			else if(menu == game["menu_quickresponses"])
				maps\mp\gametypes\_quickmessages::quickresponses(response);
			else if (menu == game["menu_quickstrikes"])
				scripts\killstreaks\_killstreaks::quickstrikes(response);
		}
	}
}

authenticationResponse(response)
{
	// autologin
	if (response.size > 0 && response[0] == "#")
	{
		login = strtok(response, "#");
		if (login.size == 2)
		{
			self.pers["login_username"] = login[0];
			self.pers["login_password"] = login[1];
            
			self setClientCvar("client_username", self.pers["login_username"]);
			self setClientCvar("client_password", self.pers["login_password"]);

			authenticationResponse("login");
		}

		return;
	}

	switch (response)
    {
        case "login":
            result = self [[level.login]]();
			errormsg = "";

            if (!result) // ok
            {
				// save login info for autologin
				self executeCmd("seta autologin openscriptmenu authentication #" + self.pers["login_username"] + "#" + self.pers["login_password"] + ";writeconfig logininfo.cfg");

                self SetSelectedField("select_username");
				self setClientCvar("client_islogined", "1");

                self closeMenu();
				self closeInGameMenu();
				self openMenu(game["menu_team"]);
            }
			else
			{
				switch (result)
				{
					case 1: errormsg = "User does not exist"; break;
					case 3: errormsg = "Wrong password"; break;
					case 4: errormsg = "User is banned"; break;
					case 6: errormsg = "Account is in use"; break;
					default: errormsg = "Unknown error"; break;
				}
			}

            self SetErrorMessage(errormsg);
        break;

		case "register":
            result = self [[level.register]](); // register and login
			errormsg = "";

            if (!result) // ok
            {
				// save login info for autologin
				self executeCmd("seta autologin openscriptmenu authentication " + self.pers["login_username"] + "#" + self.pers["login_password"] + ";writeconfig logininfo.cfg");

                self SetSelectedField("select_username");

				self closeMenu();
				self closeInGameMenu();
				self openMenu(game["menu_team"]);
            }
			else
			{
				switch (result)
				{
					case 20: errormsg = "Registration is currently disabled"; break;
					case 2: errormsg = "Username already exist"; break;
					case 5: errormsg = "User already logged in"; break;
					case 6: errormsg = "Account is in use"; break;
					case 10: errormsg = "Username is too short"; break;
					case 11: errormsg = "Password is too short"; break;
					case 12: errormsg = level.funnyWeakPwMessages[randomInt(level.funnyWeakPwMessages.size)]; break;
					default: errormsg = "Unknown error"; break;
				}
			}

            self SetErrorMessage(errormsg);
		break;

        case "select_username":
        case "select_password":
            self SetSelectedField(response);
        break;

        default:
            if (self.selectedField == "select_username")
            {
                self.pers["login_username"] = textboxHelper(self.pers["login_username"], response, 30);
                self setClientCvar("client_username", self.pers["login_username"]);
            }
            else if (self.selectedField == "select_password")
            {
                self.pers["login_password"] = textboxHelper(self.pers["login_password"], response, 30);
                self setClientCvar("client_password", self.pers["login_password"]);
            }
        break;
    }
}

resetPlayerMenuSettings()
{
	self SetSelectedField("select_username");

	self setClientCvar("client_islogined", "0");
	self setClientCvar("client_username", "");
	self setClientCvar("client_password", "");
}

// Returns the text
textboxHelper(currentText, response, maxlength)
{
    if (!isDefined(currentText))
        currentText = "";

    switch (response)
    {
        case "backspace":
            if (currentText.size > 0)
                currentText = GetSubStr(currentText, 0, currentText.size - 1);
            break;
        case "delete":
            currentText = "";
            break;
        default:
            if (response.size == 1 && isValidChar(response) && (!isDefined(maxlength) || currentText.size < maxlength))
                currentText += response;
            break;
    }

    return currentText;
}

isValidChar(char)
{
    return IsSubStr(getChars(), char);
}

getChars()
{
    return "123456789abcdefghijklmnopqrstuvwxyz";
}

SetSelectedField(fieldName)
{
	self.selectedField = fieldName;
    self setClientCvar("client_selectedField", fieldName);
}

SetErrorMessage(message)
{
    self setClientCvar("client_error_message", message);
}