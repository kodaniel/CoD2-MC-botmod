#include scripts\_utils;

IsFileExist(file)
{
    fhandler = openFile(file, "read");

    if (fhandler != -1)
    {
        closefile(fhandler);
        return true;
    }
    else
    {
        return false;
    }
}

Write(file, content)
{
	f = openFile(file, "write");

	if (f == -1)
	{
		_logError(f, "[Write()] Could not open file. <file:" + file + ">");
		return;
	}

	_logError(fPrintln(f, content), "[Write()] Could not write file. <file:" + file + ">");
	_logError(closeFile(f), "[Write()] Could not close file. <file:" + file + ">");
}

WriteTable(file, table)
{
	content = "";
	for (i = 0; i < table.size; i++)
	{
		content += join(",", table[i]);

		if (i < table.size - 1)
			content += ",\n";
	}
	
	f = openFile(file, "write");
	if (f == -1)
	{
		_logError(f, "[WriteTable()] Could not open file. <file:" + file + ">");
		return;
	}

	_logError(fPrintln(f, content), "[WriteTable()] Could not write file. <file:" + file + ">");
	_logError(closeFile(f), "[WriteTable()] Could not close file. <file:" + file + ">");
}

Append(file, content)
{
	f = openFile(file, "append");

	if (f == -1)
	{
		_logError(f, "[Append()] Could not open file. <file:" + file + ">");
		return;
	}

	_logError(fPrintln(f, content), "[Append()] Could not write file. <file:" + file + ">");
	_logError(closeFile(f), "[Append()] Could not close file. <file:" + file + ">");
}

Read(file)
{
	f = openFile(file, "read");

	if (f == -1)
	{
		return;
	}

	size = fReadln(f);

	array = [];
	for (i = 0; i < size; i++)
		array[i] = fGetArg(f, i);

	_logError(closeFile(f), "[Read()] Could not close file. <file:" + file + ">");

	return array;
}

ReadIndex(file, index)
{
	f = openFile(file, "read");

	if (f == -1)
	{
		return;
	}

	fReadln(f);
	ret = fGetArg(f, index);
	_logError(closeFile(f), "[ReadIndex()] Could not close file. <file:" + file + ", index:" + index + ">");

	return ret;
}

ReadRows(file)
{
	rows = [];
	f = openFile(file, "read");

	if (f != -1)
	{
		while (fReadln(f) > 0)
		{
			_row = fGetArg(f, 0);
			rows[ rows.size ] = _row;
		}

		_logError(closeFile(f), "[ReadRows()] Could not close file. <file:" + file + ">");
	}
	return rows;
}

ReadTable(file)
{
    rows = [];
    i = 0;

    f = openFile(file, "read");

	if (f == -1) // file does not exist
		return;

    while (1)
    {
        argumentsCount = fReadln(f);

        if (argumentsCount < 0)
            break;

        rows[i] = [];

        for (j = 0; j < argumentsCount; j++)
            rows[i][j] = fGetArg(f, j);

        i++;
    }

    _logError(closeFile(f), "[ReadTable()] Could not close file. <file:" + file + ">");

    return rows;
}

_logError(r, msg)
{
	if (r == -1)
	{
		logPrint("FILE ERROR " + msg + "\n");
	}
}