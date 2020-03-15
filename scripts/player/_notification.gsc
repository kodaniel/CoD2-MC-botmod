#include scripts\_utils;

init()
{
	[[level.addCallback]]("onConnect", ::RunOnConnect);
}

RunOnConnect()
{
	self endon("disconnect");

	for (;;)
	{
		self waittill("notification");

		while (self.notifies.size > 0)
			self.notifies[0] playHudAction();
	}
}

Notification(string, shader, sound)
{
	if (! isDefined(self.notifies))
		self.notifies = [];

	count = self.notifies.size;
	self.notifies[count] = spawnStruct();
	self.notifies[count].parent = self;

	if (isDefined(string))
	{
		self.notifies[count].str = newClientHudElem(self);
		self.notifies[count].str.x = 0;
		self.notifies[count].str.y = -96;
		self.notifies[count].str.alignX = "center";
		self.notifies[count].str.alignY = "middle";
		self.notifies[count].str.horzAlign = "center";
		self.notifies[count].str.vertAlign = "middle";
		self.notifies[count].str.foreground = 1;
		self.notifies[count].str setText(string);
		self.notifies[count].str.fontscale = 2;
		self.notifies[count].str.sort = 1;
		self.notifies[count].str.alpha = 0;
		self.notifies[count].str.color = (1,1,1);
		iconsize = 64;
	}
	else
	{
		iconsize = 96;
	}

	if (isDefined(shader) && shader != "")
	{
		self.notifies[count].img = newClientHudElem(self);
		self.notifies[count].img.x = 0;
		self.notifies[count].img.y = -160;
		self.notifies[count].img.alignX = "center";
		self.notifies[count].img.alignY = "middle";
		self.notifies[count].img.horzAlign = "center";
		self.notifies[count].img.vertAlign = "middle";
		self.notifies[count].img.foreground = 1;
		self.notifies[count].img setShader(shader, iconsize, iconsize);
		self.notifies[count].img.sort = 1;
		self.notifies[count].img.alpha = 0;
	}

	if (isDefined(sound) && sound != "")
	{
		self.notifies[count].snd = sound;
	}

	self notify("notification");
}

playHudAction()
{
	self.parent endon("disconnect");

	if (isDefined(self.str))
	{
		self.str fadeOverTime(0.5);
		self.str.alpha = 1;
	}
	if (isDefined(self.img))
	{
		self.img fadeOverTime(0.5);
		self.img.alpha = 1;
	}
	if (isDefined(self.snd))
	{
		self.parent playLocalSound(self.snd);
	}
	wait 2;

	if (isDefined(self.str))
	{
		self.str fadeOverTime(0.5);
		self.str.alpha = 0;
	}
	if (isDefined(self.img))
	{
		self.img fadeOverTime(0.5);
		self.img.alpha = 0;
	}
	wait 0.5;

	if (isDefined(self.str))
		self.str destroy();
	if (isDefined(self.img))
		self.img destroy();

	self.parent.notifies = array_remove(self.parent.notifies, self);
}