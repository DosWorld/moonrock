DECLARE SUB MyPath ALIAS "_mypath" (s$)
DECLARE FUNCTION FFexist% ALIAS "_ffexist" (Filename$)

DECLARE FUNCTION SHR32& ALIAS "_shr32" (BYVAL Value&, BYVAL ShiftBy%)

DECLARE FUNCTION FarMalloc% ALIAS "_far_mem_alloc" (BYVAL Bytes%)
DECLARE FUNCTION FarMemFree% ALIAS "_far_mem_free" (BYVAL Segment%)
DECLARE FUNCTION CRC16% ALIAS "_crc16" (s$)
DECLARE FUNCTION SCRC16% ALIAS "_scrc16" (BYVAL Segment%, BYVAL Offset%)
DECLARE SUB MemCopy ALIAS "_mem_copy" (BYVAL SourceSeg%, BYVAL DestSeg%, BYVAL Bytes%)
DECLARE SUB MPut4 ALIAS "_mput4" (BYVAL Segment%, BYVAL Offset%, BYVAL Value&)
DECLARE FUNCTION MGet4& ALIAS "_mget4" (BYVAL Segment%, BYVAL Offset%)
DECLARE FUNCTION unique2% ALIAS "_unique" (s$)

DECLARE FUNCTION sinstr% ALIAS "_sinstr" (str1$, set1$)

CONST Ver$ = "{CUSTOM}"
CONST TRUE = -1
CONST FALSE = 0

CONST Code% = 1
CONST VarDef% = 2

CONST CodeSeg% = 1
CONST DataSeg% = 2
CONST StrConstSeg% = 3

CONST Near% = 0
CONST Far% = 1
CONST Huge% = 2

CONST MR% = 0
CONST QuickBASIC% = 1

CONST UnknownType% = 0
CONST IntByte% = 1
CONST IntWord% = 2
CONST IntDoubleWord% = 3
CONST StringType% = 4
CONST IntConst% = 5
CONST Label% = 6
CONST StrConst% = 7
CONST CmdType% = 8
CONST TermType% = 9
CONST Default% = 10
CONST NumFunc% = 11
CONST StrFunc% = 12
CONST UserFunc% = 13
CONST Num1Func% = 14
CONST BundleType% = 15
CONST Pointer% = 16
CONST PointerRef% = 17

CONST BMR% = 0
CONST BNull% = 1
CONST BPascal% = 2

CONST NestIfThen% = 1
CONST NestForNext% = 2
CONST NestWhileWend% = 3
CONST NestSelectCase% = 4

CONST Array% = 100
CONST IntByteArray% = 101
CONST IntWordArray% = 102
CONST IntDoubleWordArray% = 103
CONST StringTypeArray% = 104

COMMON SHARED validcommand$, validstrfunc$, validnumfunc$, validnum1func$

COMMON SHARED Term$, InclTerm$

COMMON SHARED SysPath$
COMMON SHARED FMin%, FMout%, FMvar%, FMdef%, FMcode%, FMsc%, FMstack%
COMMON SHARED errcount%, linecount%, warncount%
COMMON SHARED strconstcount%
COMMON SHARED StrTable$, LabelTable$, IntTable$, LibTable$, IntArrayTable$
COMMON SHARED LibVector$
COMMON SHARED intcount%, strcount%, labelcount%
COMMON SHARED bp$(), bpsp%(), bpt%(), bpar$(), bpart%(), bpterm$(), bpp%
COMMON SHARED bppr%()
COMMON SHARED infile$, outfile$, errfile$, libfile$
COMMON SHARED inline$
COMMON SHARED Pass%, WriteSource%, SwStr%, SwDebug%, SwTrace%, SwSingleStep%
COMMON SHARED Processor%, SwDOSX%, SwDPMI%, SwPartial%, SwMain%
COMMON SHARED SwCritical%, SwResume%, SwOpt%, SwDep%
COMMON SHARED stacksize%
COMMON SHARED fornextcnt%, fornextstack%(), fornextend$()
COMMON SHARED ForNextSP%, fornextvar$(), fornextt%()
COMMON SHARED IfThenCnt%, ElsePtr%(), IfThenSP%, IfThenStack%()
COMMON SHARED CaseListCnt%, CaseListSP%, CaseListStack%(), CaseListElse%()
COMMON SHARED CaseListPrecision%(), CaseListInCnt%(), CaseListVar$()
COMMON SHARED CaseListReload%(), CaseListArrVar$(), CaseListArrType%()
COMMON SHARED NestSP%, NestStack%()
COMMON SHARED WhileWendCnt%, WhileWendSP%, WhileWendStack%()
COMMON SHARED fb$(), sc$()
COMMON SHARED SwStr$
COMMON SHARED SourceType%
COMMON SHARED defaultstacksize%
COMMON SHARED outstream$, errhandler$
COMMON SHARED DataPtr&, StrSegSize&
COMMON SHARED errflag%
COMMON SHARED currentsub$, Sub$(), SubUsed%(), SubPtr%, updsub%
COMMON SHARED precision%, hiprecision%
COMMON SHARED f386$
COMMON SHARED Bundle$(), BundleSize%(), BundleDef$(), BundlePtr%
COMMON SHARED Def$

COMMON SHARED IncludeName$(), IncludePosi&(), IncludeLine%(), IncludeSP%
COMMON SHARED ProjList$, depname$

COMMON SHARED EXE%

COMMON SHARED lastivar1$, lastivar2$
COMMON SHARED lastsvar1$, lastsvar2$

COMMON SHARED FarDimList$, DimType$, DimBound$

COMMON SHARED vl&, vh&

COMMON SHARED SwFarCall%

COMMON SHARED LastValES$, BPval$

COMMON SHARED DataRefList$, StartupList$, StartupPMList$, CleanupList$

COMMON SHARED linefeed$

COMMON SHARED release%, freeflag%

COMMON SHARED ConstTable$

COMMON SHARED CommonList$

COMMON SHARED SubCounter%, SubFree$

COMMON SHARED tpath$

COMMON SHARED LocVarCount%, ArrayVarCount%

COMMON SHARED Language%

COMMON SHARED LastBP0$

COMMON SHARED PragmaSubNullStringCheck%

COMMON SHARED bpreg$

COMMON SHARED PtrTable$

COMMON SHARED rep.lastlinenum%, rep.lastsourcetype%

COMMON SHARED atexit%, buildcount&, PreserveFlag%, Preserve$(), PreserveCount%
COMMON SHARED PreserveList$

COMMON SHARED WriteMemManager%, InternalSub$, InternalNFunc$
COMMON SHARED LocalArray$
COMMON SHARED ESused%

COMMON SHARED TypePtr%, TypeName$(), TypeParm$()

COMMON SHARED ExternUsed%

Term$ = " <>=+-*/\(),[]"
InclTerm$ = "<>=+-*/\["

linefeed$ = CHR$(13) + CHR$(10)

bpreg$ = "bp"
atexit% = FALSE
ESused% = FALSE

