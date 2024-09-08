






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
	else if (wordinfo.szWord == "default")
	{
		SetBufSelText(hbuf, ":")
		InsBufLine(hbuf, ln + 1, "@szLine@" # "{")
		InsBufLine(hbuf, ln + 2, "@szLine@    " # "###")
		InsBufLine(hbuf, ln + 3, "@szLine@    " # "break;")
		InsBufLine(hbuf, ln + 4, "@szLine@" # "}")
	}
	else if (wordinfo.szWord == "/**")
	{
		InsBufLine(hbuf, ln + 1, " * \@brief   " # "###")
		InsBufLine(hbuf, ln + 2, " * \@param   " # "###")
		InsBufLine(hbuf, ln + 4, " * \@return  " # "###")
		InsBufLine(hbuf, ln + 5, " */")
	}
	else if (wordinfo.szWord == "hfh")
	{
		offset = ln
		SysTime = GetSysTime(1)
		sz0=SysTime.Year
		sz1=SysTime.month
		sz3=SysTime.day
		szTime = "@sz0@/@sz1@/@sz3@"

		InsBufLine(hbuf, offset++, "/**")
		InsBufLine(hbuf, offset++, " * \@file			" # "###")
		InsBufLine(hbuf, offset++, " * \@brief			" # "###")
		InsBufLine(hbuf, offset++, " * \@details			" # "###")
		InsBufLine(hbuf, offset++, " * \@author			guanjianhe")
		InsBufLine(hbuf, offset++, " * \@version			V1.0.0")
		InsBufLine(hbuf, offset++, " * \@date			@szTime@")
		InsBufLine(hbuf, offset++, " * \@copyright		Copyright(c) 2023 Slenergy Technology (A.H.), All Rights Reserved.")
		InsBufLine(hbuf, offset++, " *******************************************************************************************")
		InsBufLine(hbuf, offset++, " * \@par 修改日志:")
		InsBufLine(hbuf, offset++, " * <table>")
		InsBufLine(hbuf, offset++, " * <tr><th>Date				<th>Version			<th>Author		<th>Description")
		InsBufLine(hbuf, offset++, " * <tr><td>@szTime@			<td>V1.0.0			<td>guanjianhe	<th>初始版本")
		InsBufLine(hbuf, offset++, " * </table>")
		InsBufLine(hbuf, offset++, " *")
		InsBufLine(hbuf, offset++, " *******************************************************************************************")
		InsBufLine(hbuf, offset++, " * \@par 示例:")
		InsBufLine(hbuf, offset++, " * \@code")
		InsBufLine(hbuf, offset++, " * 暂无")
		InsBufLine(hbuf, offset++, " * \@endcode 示例:")
		InsBufLine(hbuf, offset++, " */")
	
	}
	else if (wordinfo.szWord == "cfh")
	{
	
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
