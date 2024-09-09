
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
        offset = ln + 1
        SetBufSelText(hbuf, " (###)")
        InsBufLine(hbuf, offset++, "@szLine@" # "{")
        InsBufLine(hbuf, offset++, "@szLine@    " # "###")
        InsBufLine(hbuf, offset++, "@szLine@" # "}")
    }
    else if (wordinfo.szWord == "for")
    {
        offset = ln + 1
        SetBufSelText(hbuf, " (###; ###; ###)")
        InsBufLine(hbuf, offset++, "@szLine@" # "{")
        InsBufLine(hbuf, offset++, "@szLine@    " # "###")
        InsBufLine(hbuf, offset++, "@szLine@" # "}")
    }
    else if (wordinfo.szWord == "switch")
    {
        InsertSwitch(hbuf, ln, szLine)
    }
    else if (wordinfo.szWord == "cpp")
    {
        InsertCPP(hbuf, ln)
    }
    else if (wordinfo.szWord == "do")
    {
        offset = ln + 1
        InsBufLine(hbuf, offset++, "@szLine@" # "{")
        InsBufLine(hbuf, offset++, "@szLine@    " # "###");
        InsBufLine(hbuf, offset++, "@szLine@" # "} while (###);")
    }
    else if (wordinfo.szWord == "case")
    {
        InsertCase(hbuf, ln, szLine)
    }
    else if (wordinfo.szWord == "default")
    {
        InsertDefault(hbuf, ln, szLine)
    }
    else if (wordinfo.szWord == "/**")
    {
        offset = ln + 1
        InsBufLine(hbuf, offset++, " * \@brief   " # "###")
        InsBufLine(hbuf, offset++, " * \@param   " # "###")
        InsBufLine(hbuf, offset++, " * \@return  " # "###")
        InsBufLine(hbuf, offset++, " */")
    }
    else if (wordinfo.szWord == "hfh")
    {
        InsertHFileHeader(hbuf, ln)
    }
    else if (wordinfo.szWord == "cfh")
    {
        InsertCFileHeader(hbuf, ln)

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

macro GetFileNameExt(sz)
{
    i = 1
    j = 0
    szName = sz
    iLen = strlen(sz)

    if(iLen == 0)
        return ""
    
    while( i <= iLen)
    {
        if(sz[iLen-i] == ".")
        {
            j = iLen-i 
            szExt = strmid(sz,j + 1,iLen)
            return szExt
        }
        
        i = i + 1
    }
    return ""
}

macro GetFileNameNoExt(sz)
{
    i = 1
    szName = sz
    iLen = strlen(sz)
    j = iLen

    if(iLen == 0)
        return ""

    while( i <= iLen)
    {
        if(sz[iLen-i] == ".")
        {
            j = iLen-i 
        }

        if( sz[iLen-i] == "\\" )
        {
            szName = strmid(sz,iLen-i+1,j)
            return szName
        }

        i = i + 1

    }
    
    szName = strmid(sz,0,j)
    return szName
}

macro GetFileName(sz)
{
    i = 1
    szName = sz
    iLen = strlen(sz)
    
    if(iLen == 0)
        return ""
        
    while( i <= iLen)
    {
        if(sz[iLen-i] == "\\")
        {
            szName = strmid(sz,iLen-i+1,iLen)
            break
        }
        
        i = i + 1
    }
    
    return szName
}

macro InsertCase(hbuf, ln, szLine)
{
    offset = ln + 1
    SetBufSelText(hbuf, " ###:")
    InsBufLine(hbuf, offset++, "@szLine@" # "{")
    InsBufLine(hbuf, offset++, "@szLine@    " # "###")
    InsBufLine(hbuf, offset++, "@szLine@    " # "break;")
    InsBufLine(hbuf, offset++, "@szLine@" # "}")
}

macro InsertDefault(hbuf, ln, szLine)
{
    offset = ln + 1
    SetBufSelText(hbuf, ":")
    InsBufLine(hbuf, offset++, "@szLine@" # "{")
    InsBufLine(hbuf, offset++, "@szLine@    " # "###")
    InsBufLine(hbuf, offset++, "@szLine@    " # "break;")
    InsBufLine(hbuf, offset++, "@szLine@" # "}")
}

macro InsertSwitch(hbuf, ln, szLine)
{
    offset = ln + 1
    SetBufSelText(hbuf, " (###)")
    InsBufLine(hbuf, offset++, "@szLine@" # "{")
    InsBufLine(hbuf, offset++, "@szLine@    " # "case ###:")
    InsBufLine(hbuf, offset++, "@szLine@    " # "{")
    InsBufLine(hbuf, offset++, "@szLine@        " # "###")
    InsBufLine(hbuf, offset++, "@szLine@        " # "break;")
    InsBufLine(hbuf, offset++, "@szLine@    " # "}")
    InsBufLine(hbuf, offset++, "@szLine@    " # "default:")
    InsBufLine(hbuf, offset++, "@szLine@    " # "{")
    InsBufLine(hbuf, offset++, "@szLine@        " # "###")
    InsBufLine(hbuf, offset++, "@szLine@        " # "break;")
    InsBufLine(hbuf, offset++, "@szLine@    " # "}")
    InsBufLine(hbuf, offset++, "@szLine@" # "}")
}

macro InsertHFileHeader(hbuf, ln)
{
    DelBufLine(hbuf, ln)
    offset = ln
    SysTime = GetSysTime(1)
    sz0=SysTime.Year
    sz1=SysTime.month
    sz3=SysTime.day
    szTime = "@sz0@/@sz1@/@sz3@"
    szTmp = GetFileName(GetBufName(hbuf))

    InsBufLine(hbuf, offset++, "/**")
    InsBufLine(hbuf, offset++, "  ******************************************************************************")
    InsBufLine(hbuf, offset++, "  * \@file      @szTmp@")
    InsBufLine(hbuf, offset++, "  * \@author    guanjianhe")
    InsBufLine(hbuf, offset++, "  * \@brief     " # "###")
    InsBufLine(hbuf, offset++, "  ******************************************************************************")
    InsBufLine(hbuf, offset++, "  * \@attention")
    InsBufLine(hbuf, offset++, "  *")
    InsBufLine(hbuf, offset++, "  * Copyright (c) 2023 Slenergy Technology (A.H.)")
    InsBufLine(hbuf, offset++, "  * All rights reserved.")
    InsBufLine(hbuf, offset++, "  *")
    InsBufLine(hbuf, offset++, "  ******************************************************************************")
    InsBufLine(hbuf, offset++, "  */")
    InsBufLine(hbuf, offset++, "")
    InsBufLine(hbuf, offset++, "")
    InsBufLine(hbuf, offset++, "/* Define to prevent recursive inclusion -------------------------------------*/")
    InsBufLine(hbuf, offset++, "/* Includes ------------------------------------------------------------------*/")
    InsBufLine(hbuf, offset++, "/* Exported macro ------------------------------------------------------------*/")
    InsBufLine(hbuf, offset++, "/* Exported constants --------------------------------------------------------*/")
    InsBufLine(hbuf, offset++, "/* Exported types ------------------------------------------------------------*/")
    InsBufLine(hbuf, offset++, "/* Exported functions --------------------------------------------------------*/")
}

macro InsertCFileHeader(hbuf, ln)
{
    DelBufLine(hbuf, ln)
    offset = ln
    SysTime = GetSysTime(1)
    sz0=SysTime.Year
    sz1=SysTime.month
    sz3=SysTime.day
    szTime = "@sz0@/@sz1@/@sz3@"
    szTmp = GetFileName(GetBufName(hbuf))

    InsBufLine(hbuf, offset++, "/**")
    InsBufLine(hbuf, offset++, "  ******************************************************************************")
    InsBufLine(hbuf, offset++, "  * \@file      @szTmp@")
    InsBufLine(hbuf, offset++, "  * \@author    guanjianhe")
    InsBufLine(hbuf, offset++, "  * \@brief     " # "###")
    InsBufLine(hbuf, offset++, "  ******************************************************************************")
    InsBufLine(hbuf, offset++, "  * \@attention")
    InsBufLine(hbuf, offset++, "  *")
    InsBufLine(hbuf, offset++, "  * Copyright (c) 2023 Slenergy Technology (A.H.)")
    InsBufLine(hbuf, offset++, "  * All rights reserved.")
    InsBufLine(hbuf, offset++, "  *")
    InsBufLine(hbuf, offset++, "  ******************************************************************************")
    InsBufLine(hbuf, offset++, "  */")
    InsBufLine(hbuf, offset++, "")
    InsBufLine(hbuf, offset++, "")
    InsBufLine(hbuf, offset++, "/* Includes ------------------------------------------------------------------*/")
    InsBufLine(hbuf, offset++, "/* Private macros ------------------------------------------------------------*/")
    InsBufLine(hbuf, offset++, "/* Private constants ---------------------------------------------------------*/")
    InsBufLine(hbuf, offset++, "/* Private types -------------------------------------------------------------*/")
    InsBufLine(hbuf, offset++, "/* Private variables ---------------------------------------------------------*/")
    InsBufLine(hbuf, offset++, "/* Import function prototypes ------------------------------------------------*/")
    InsBufLine(hbuf, offset++, "/* Exported variables --------------------------------------------------------*/")
    InsBufLine(hbuf, offset++, "/* Private function prototypes -----------------------------------------------*/")
    InsBufLine(hbuf, offset++, "/* Exported functions --------------------------------------------------------*/")
    InsBufLine(hbuf, offset++, "/* Private functions ---------------------------------------------------------*/")
}

macro InsertCPP(hbuf, ln)
{
    DelBufLine(hbuf, ln)
    InsBufLine(hbuf, ln, "")
    InsBufLine(hbuf, ln, "#endif /* __cplusplus */")
    InsBufLine(hbuf, ln, "extern \"C\"{")
    InsBufLine(hbuf, ln, "#ifdef __cplusplus")
    InsBufLine(hbuf, ln, "")

    iTotalLn = GetBufLineCount (hbuf)
    InsBufLine(hbuf, iTotalLn, "")
    InsBufLine(hbuf, iTotalLn, "#endif /* __cplusplus */")
    InsBufLine(hbuf, iTotalLn, "}")
    InsBufLine(hbuf, iTotalLn, "#ifdef __cplusplus")
    InsBufLine(hbuf, iTotalLn, "")
}

//取出字符串左端的空格和tab
macro TrimLeft(szLine)
{
    nLen = strlen(szLine)
    
    if(nLen == 0)
    {
        return szLine
    }

    nIdx = 0

    while( nIdx < nLen )
    {
        if( ( szLine[nIdx] != " ") && (szLine[nIdx] != "\t") )
        {
            break
        }
        
        nIdx = nIdx + 1
    }

    return strmid(szLine,nIdx,nLen)
}

//取出字符串右端的空格和tab
macro TrimRight(szLine)
{
    nLen = strlen(szLine)
    
    if(nLen == 0)
    {
        return szLine
    }

    nIdx = nLen
    
    while( nIdx > 0 )
    {
        nIdx = nIdx - 1
        
        if( ( szLine[nIdx] != " ") && (szLine[nIdx] != "\t") )
        {
            break
        }
    }
    
    return strmid(szLine,0,nIdx+1)
}


macro TrimString(szLine)
{
    szLine = TrimLeft(szLine)
    szLIne = TrimRight(szLine)
    return szLine
}


