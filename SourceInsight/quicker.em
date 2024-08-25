
macro _tsGetTabSize()
{
	szTabSize = GetReg("TabSize")

	if (szTabSize != "")
	{
		tabSize = AsciiFromChar(szTabSize[0]) - AsciiFromChar("0")
	}
	else
	{
		spaces = Ask("How many spaces per tab for SpaceToTab converter?")
		SetReg("TabSize", spaces)
		tabSize = AsciiFromChar(spaces[0]) - AsciiFromChar("0")
	}

	return tabSize
}

macro AutoExpand()
{
	hwnd = GetCurrentWnd()

	if (hwnd == hNil)
	{
		stop
	}

	sel = GetWndSel(hwnd)

	if (sel.ichFirst == 0)
	{
		stop
	}

	hbuf = GetWndBuf(hwnd)

	szLine = GetBufLine(hbuf, sel.lnFirst)


	wordinfo = GetWordLeftOfIch(sel.ichFirst, szLine)
	ln = sel.lnFirst;

	chSpace = CharFromAscii(32)

	ich = 0
	
	while (szLine[ich] == chSpace)
	{
		ich = ich + 1
	}
	
	szLine = strmid(szLine, 0, ich)
	sel.lnFirst = sel.lnLast
	sel.ichFirst = wordinfo.ich
	sel.ichLim = wordinfo.ich

	if (wordinfo.szWord == "if" || wordinfo.szWord == "while")
	{
		SetBufSelText(hbuf, " (###)")
		InsBufLine(hbuf, ln + 1, "@szLine@" # "{")
		InsBufLine(hbuf, ln + 2, "@szLine@    " # "###")
		InsBufLine(hbuf, ln + 3, "@szLine@" # "}")
	}
	else if (wordinfo.szWord == "for")
	{
		SetBufSelText(hbuf, " (###; ###; ###)")
		InsBufLine(hbuf, ln + 1, "@szLine@" # "{")
		InsBufLine(hbuf, ln + 2, "@szLine@    " # "###")
		InsBufLine(hbuf, ln + 3, "@szLine@" # "}")
	}
	else if (wordinfo.szWord == "switch")
	{
		SetBufSelText(hbuf, " (###)")
		InsBufLine(hbuf, ln + 1, "@szLine@" # "{")
		InsBufLine(hbuf, ln + 2, "@szLine@    " # "case ###:")
		InsBufLine(hbuf, ln + 3, "@szLine@    " # "{")
		InsBufLine(hbuf, ln + 4, "@szLine@        " # "###")
		InsBufLine(hbuf, ln + 5, "@szLine@        " # "break;")
		InsBufLine(hbuf, ln + 6, "@szLine@    " # "}")
		InsBufLine(hbuf, ln + 7, "@szLine@    " # "default:")
		InsBufLine(hbuf, ln + 8, "@szLine@    " # "{")
		InsBufLine(hbuf, ln + 9, "@szLine@        " # "###")
		InsBufLine(hbuf, ln + 10, "@szLine@        " # "break;")
		InsBufLine(hbuf, ln + 11, "@szLine@    " # "}")
		InsBufLine(hbuf, ln + 12, "@szLine@" # "}")
	}
	else if (wordinfo.szWord == "do")
	{
		InsBufLine(hbuf, ln + 1, "@szLine@" # "{")
		InsBufLine(hbuf, ln + 2, "@szLine@    " # "###");
		InsBufLine(hbuf, ln + 3, "@szLine@" # "} while (###);")
	}
	else if (wordinfo.szWord == "case")
	{
		SetBufSelText(hbuf, " ###:")
		InsBufLine(hbuf, ln + 1, "@szLine@" # "{")
		InsBufLine(hbuf, ln + 2, "@szLine@    " # "###")
		InsBufLine(hbuf, ln + 3, "@szLine@    " # "break;")
		InsBufLine(hbuf, ln + 4, "@szLine@" # "}")
	}
	else if (wordinfo.szWord == "/**")
	{
		InsBufLine(hbuf, ln + 1, " * \@brief   " # "###")
		InsBufLine(hbuf, ln + 2, " * \@param   " # "###")
		InsBufLine(hbuf, ln + 3, " * \@note    " # "###")
		InsBufLine(hbuf, ln + 4, " * \@return  " # "###")
		InsBufLine(hbuf, ln + 5, " */")
	}
	else
	{
		stop
	}
	
	SetWndSel(hwnd, sel)
	LoadSearchPattern("###", true, false, false)
	Search_Forward
}


macro GetWordLeftOfIch(ich, sz)
{
	wordinfo = ""
	
	chTab = CharFromAscii(9)
	chSpace = CharFromAscii(32)

	ich = ich - 1
	
	if (ich >= 0)
	{
		while (sz[ich] == chSpace || sz[ich] == chTab)
		{
			ich = ich - 1
			
			if (ich < 0)
			{
				break;
			}
		}
	}
	
	ichLim = ich + 1;
	asciiA = AsciiFromChar("A")
	asciiZ = AsciiFromChar("Z")
	
	while (ich >= 0)
	{
		ch = toupper(sz[ich])
		asciiCh = AsciiFromChar(ch)
		
		if ((asciiCh < asciiA || asciiCh > asciiZ) && !IsNumber(ch) && (ch != "/" && ch != "*"))
		{
			break
		}
		
		ich = ich - 1;
	}
	
	ich = ich + 1
	wordinfo.szWord = strmid(sz, ich, ichLim)
	wordinfo.ich = ich
	wordinfo.ichLim = ichLim;
	
	return wordinfo
}



macro CommentBlock()
{
	hbuf = GetCurrentBuf();
	hwnd = GetCurrentWnd();

	sel = GetWndSel(hwnd);

	iLine = sel.lnFirst;
	
	while (iLine <= sel.lnLast)
	{
		szLine = GetBufLine(hbuf, iLine);
		szLine = cat("//	", szLine);
		PutBufLine(hbuf, iLine, szLine);
		iLine = iLine + 1;
	}

	if (sel.lnFirst == sel.lnLast)
	{
		tabSize = _tsGetTabSize() - 1;
		sel.ichFirst = sel.ichFirst + tabSize;
		sel.ichLim = sel.ichLim + tabSize;
	}
	
	SetWndSel(hwnd, sel);
}

macro UnCommentBlock()
{
	hbuf = GetCurrentBuf()
	hwnd = GetCurrentWnd()
	
	sel = GetWndSel(hwnd)
	iLine = sel.lnFirst
	chTab = CharFromAscii(9)


	tabSize = 0;
	while (iLine <= sel.lnLast)
	{
		szLine = GetBufLine(hbuf, iLine)
		len = strlen(szLine)
		szNewLine = ""
		
		if (len > 1)
		{
			if (szLine[0] == "/" && szLine[1] == "/")
			{
				if (len > 2)
				{
					if (szLine[2] == chTab)
					{
						tabSize = _tsGetTabSize() - 1
						szNewLine = strmid(szLine, 3, strlen(szLine))
					}
				}

				if (szNewLine == "")
				{
					szNewLine = strmid(szLine, 2, strlen(szLine))
					tabSize = 2
				}
				
				PutBufLine(hbuf, iLine, szNewLine)
			}
		}
		iLine = iLine + 1
	}

	if (sel.lnFirst == sel.lnLast)
	{
		sel.ichFirst = sel.ichFirst - tabSize
		sel.ichLim = sel.ichLim - tabSize
	}

	SetWndSel(hwnd, sel)
}
