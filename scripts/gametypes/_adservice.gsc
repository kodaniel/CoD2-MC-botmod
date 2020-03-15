#include scripts\_utils;

init()
{
    level.adEnabled = cvarDef("int", "ad_enable", 1, 0, 1); // advertisements are enabled or not
    level.adDelay = cvarDef("int", "ad_delay", 5, 0, 999); // delay between two ads
    level.adMaxMessages = cvarDef("int", "ad_maxmessages", 10, 0, 999); // maximum number of messages

    if (!level.adEnabled)
        return;

    level thread LoopAds();
}

LoopAds()
{
    for (i = 1; i <= level.adMaxMessages; i++)
        cvarDef("string", "ad_message" + i, "");

    while (true)
    {
        for (i = 1; i <= level.adMaxMessages; i++)
        {
            adMessage = getCvar("ad_message" + i);

            iPrintln(adMessage);

            wait level.adDelay;
        }

        if (level.adDelay < 5)
            wait 5;
        else
            wait level.adDelay;
    }
}