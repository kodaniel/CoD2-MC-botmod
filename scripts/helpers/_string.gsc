format(text, values)
{
    newtext = "";
    for (i = 0; i < text.size; i++)
    {
        if (i < text.size - 2 && text[i] == "&" && text[i + 1] == "&")
        {
            placeholderNum = int(text[i + 2]) - 1;

            if (placeholderNum >= 0 && placeholderNum < values.size)
                newtext += values[placeholderNum];

            i += 2;
        }
        else
        {
            newtext += text[i];
        }
    }

    return newtext;
}