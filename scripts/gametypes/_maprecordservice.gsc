#include scripts\_utils;
#include scripts\helpers\_io;

init()
{
    /*
    File structure:
    <mapname1>,<maxround1>,<difficulty1>,<time1>,<kills1>,<rounds1>,
    <mapname2>,<maxround2>,<difficulty2>,<time2>,<kills2>,<rounds2>,
    */

    level.recordsFileName = "records.csv";
}

CheckRecord()
{
    currentMap = getCvar("mapname");
    maxRounds = level.roundslimit;
    difficulty = level.difficulty;

    currentStats = array(game["time"], game["aiKillCount"], game["roundsplayed"]);
    record = GetMapRecords(currentMap, maxRounds, difficulty);
    if (isDefined(record))
    {
        recordStats = array(int(record[3]), int(record[4]), int(record[5]));
    }
    else
    {
        recordStats = array(0, 0, 0);
    }

    SaveMapRecords(currentMap, maxrounds, difficulty, currentStats, recordStats);

    PrintRecords(array("^1New time record:", "^1New kill record:", "^1New round record:"), currentStats, recordStats);
}

GetMapRecords(currentMap, maxrounds, difficulty)
{
    recordsTable = ReadTable(level.recordsFileName);

    for (i = 0; i < recordsTable.size; i++)
    {
        if (recordsTable[i][0] == currentMap && int(recordsTable[i][1]) == maxrounds && int(recordsTable[i][2]) == difficulty)
            return recordsTable[i];
    }

    return;
}

SaveMapRecords(currentMap, maxrounds, difficulty, currentStats, recordStats)
{
    hasRecord = false;
    for (i = 0; i < currentStats.size; i++)
    {
        if (currentStats[i] > recordStats[i])
        {
            recordStats[i] = currentStats[i];
            hasRecord = true;
        }
    }

    if (!hasRecord)
        return;

    recordsTable = ReadTable(level.recordsFileName);
    alreadyHasRecord = false;

    if (!isDefined(recordsTable))
        recordsTable = [];

    for (i = 0; i < recordsTable.size; i++)
    {
        if (recordsTable[i][0] == currentMap && int(recordsTable[i][1]) == maxrounds && int(recordsTable[i][2]) == difficulty)
        {
            recordsTable[i][3] = recordStats[0];
            recordsTable[i][4] = recordStats[1];
            recordsTable[i][5] = recordStats[2];

            alreadyHasRecord = true;
        }
    }

    if (!alreadyHasRecord)
    {
        i = recordsTable.size;
        recordsTable[i][0] = currentMap;
        recordsTable[i][1] = maxrounds;
        recordsTable[i][2] = difficulty;
        recordsTable[i][3] = recordStats[0];
        recordsTable[i][4] = recordStats[1];
        recordsTable[i][5] = recordStats[2];
    }

    WriteTable(level.recordsFileName, recordsTable);
}

PrintRecords(labels, currentStats, recordStats)
{
    hasRecord = false;
    for (i = 0; i < labels.size; i++)
    {
        if (currentStats[i] > recordStats[i])
        {
            iPrintlnBold(labels[i] + " " + currentStats[i]);
            hasRecord = true;
        }
    }
}