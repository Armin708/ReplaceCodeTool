codeunit 50250 "Transform AL Files"
{

    // OnRun Trigger
    trigger OnRun()
    var
        FilesTemp: Record "Name/Value Buffer" temporary;
        ProgressDialog: Dialog;
        FilesProcessed: Integer;
        FilesToProcess: Integer;

    begin

        InitiliseDefaultValues();

        // FilesTemp ID     -> PK
        // FilesTemp Name   -> Full Path
        // FilesTemp Value  -> File Name
        Clear(FilesTemp);
        FileMgmt.GetServerDirectoryFilesList(FilesTemp, FolderToProcess);
        if FilesTemp.IsEmpty() then
            Error(Error001);

        FilesToProcess := FilesTemp.Count();
        Clear(ProgressDialog);
        ProgressDialog.Open('Files Processing: #1##### of #2#####');
        ProgressDialog.Update(1, 0);
        ProgressDialog.Update(2, FilesToProcess);

        FilesTemp.FindSet();
        repeat

            FilesProcessed += 1;
            ProgressDialog.Update(1, FilesProcessed);
            ProcessALFile(FilesTemp.Name, FilesTemp.Value);

        until FilesTemp.Next() = 0;

        ProgressDialog.Close();

        // End Message
        Message('Done!');

    end;
    // Global Varables
    var

        FileMgmt: Codeunit "File Management";
        RegexPatterns: Dictionary of [Text, Text];
        ReplacePatterns: Dictionary of [Text, Text];
        Error001: Label 'No files Found!';
        ExportFolder: Text;
        FolderToProcess: Text;
        simpleUserID: Text;

    local procedure InitiliseDefaultValues()
    begin

        simpleUserID := LowerCase(UserId);
        simpleUserID := simpleUserID.Replace('004GROUP\', '');

        FolderToProcess := '\\navprocess\DATASHARES\Testsystem\' + simpleUserID + '\To Navision\Old';
        ExportFolder := '\\navprocess\DATASHARES\Testsystem\' + simpleUserID + '\To Navision\New\';

        if not FileMgmt.ServerDirectoryExists(ExportFolder) then
            FileMgmt.ServerCreateDirectory(ExportFolder);

        if FileMgmt.IsServerDirectoryEmpty(FolderToProcess) then
            Error(Error001);

        // Add all the rules needed

        // "Table 5" zu "table 5"
        RegexPatterns.Add('LookupPageID = ', 'table $1');

        // "TableExtension 5" zu "tableextension 5"
        RegexPatterns.Add('\bTableExtension (\d+)\b', 'tableextension $1');

        // "XmlPort 5" zu "xmlport 5"
        RegexPatterns.Add('\bXmlPort (\d+)\b', 'xmlport $1');

        // "Report 5" zu "report 5"
        RegexPatterns.Add('\bReport (\d+)\b', 'report $1');

        // "PageExtension 5" zu "pageextension 5"
        RegexPatterns.Add('\bPageExtension (\d+)\b', 'pageextension $1');

        // "Query 5" zu "query 5"
        RegexPatterns.Add('\bQuery (\d+)\b', 'query $1');


        // 'LookupPageID = ' to 'LookupPageId = '
        ReplacePatterns.Add('LookupPageID = ', 'LookupPageId = ');
        // 'DrillDownPageID = ' to 'DrillDownPageId = '
        ReplacePatterns.Add('DrillDownPageID = ', 'DrillDownPageId = ');
        // ': label '' to ': Label ''
        ReplacePatterns.Add(': label ''', ': Label ''');
        // 'ROUND(' to 'Round('
        ReplacePatterns.Add('ROUND(', 'Round(');
        // '.SetCurrentkey(' to '.SetCurrentKey('
        ReplacePatterns.Add('.SetCurrentkey(', '.SetCurrentKey(');
        // ';RecordID)' to ';RecordId)'
        ReplacePatterns.Add(';RecordID)', ';RecordId)');
        // ' CreateDatetime(' to ' CreateDateTime('
        ReplacePatterns.Add(' CreateDatetime(', ' CreateDateTime(');
        // ': dotnet ' to ': DotNet '
        ReplacePatterns.Add(': dotnet ', ': DotNet ');
        // ' := Today;' to ' := Today();'
        ReplacePatterns.Add(' := Today;', ' := Today();');
        // ' := Time;' to ' := Time();'
        ReplacePatterns.Add(' := Time;', ' := Time();');
        // '.SetTableview(' to '.SetTableView('
        ReplacePatterns.Add('.SetTableview(', '.SetTableView(');
        // '; COMPANYNAME)' to '; CompanyName())'
        ReplacePatterns.Add('; COMPANYNAME)', '; CompanyName())');
        // ':= COMPANYNAME;' to ':= CompanyName();'
        ReplacePatterns.Add(':= COMPANYNAME;', ':= CompanyName();');
        // ' MOD ' to ' mod '
        ReplacePatterns.Add(' MOD ', ' mod ');
        // 'area(content)' to 'area(Content)'
        ReplacePatterns.Add('area(content)', 'area(Content)');
        // ', COMPANYNAME, ' to ', CompanyName(), '
        ReplacePatterns.Add(', COMPANYNAME, ', ', CompanyName(), ');
        // 'area(rolecenter)' to 'area(RoleCenter)'
        ReplacePatterns.Add('area(rolecenter)', 'area(RoleCenter)');
        // ' RunObject = Page ' to ' RunObject = page '
        ReplacePatterns.Add(' RunObject = Page ', ' RunObject = page ');
        // ' DIV ' to ' div '
        ReplacePatterns.Add(' DIV ', ' div ');
        // ' COMPANYNAME ' to ' CompanyName() '
        ReplacePatterns.Add(' COMPANYNAME ', ' CompanyName() ');
        // '(COMPANYNAME)' to '(CompanyName())'
        ReplacePatterns.Add('(COMPANYNAME)', '(CompanyName())');
        // ', COMPANYNAME)' to ', CompanyName())'
        ReplacePatterns.Add(', COMPANYNAME)', ', CompanyName())');
        // 'Lowercase(' to 'LowerCase('
        ReplacePatterns.Add('Lowercase(', 'LowerCase(');
        // 'CreateDatetime(' to 'CreateDateTime('
        ReplacePatterns.Add('CreateDatetime(', 'CreateDateTime(');
        // ', UserId,' to ', UserId(),'
        ReplacePatterns.Add(', UserId,', ', UserId(),');
        // ' := UserId;' to ' := UserId();'
        ReplacePatterns.Add(' := UserId;', ' := UserId();');
        // '; RecordID)' to '; RecordId)'
        ReplacePatterns.Add('; RecordID)', '; RecordId)');
        // 'GuiAllowed' to 'GuiAllowed()'
        ReplacePatterns.Add('GuiAllowed', 'GuiAllowed()');
        // ' := COMPANYNAME' to ' := CompanyName()'
        ReplacePatterns.Add(' := COMPANYNAME', ' := CompanyName()');
        // ' := CurrentDatetime;' to ' := CurrentDateTime();'
        ReplacePatterns.Add(' := CurrentDatetime;', ' := CurrentDateTime();');
        // ':= Dt2Date(' to ':= DT2Date('
        ReplacePatterns.Add(':= Dt2Date(', ':= DT2Date(');
        // ': RecordID;' to ': RecordId;'
        ReplacePatterns.Add(': RecordID;', ': RecordId;');
        // ':= Date2dmy(' to ':= Date2DMY('
        ReplacePatterns.Add(':= Date2dmy(', ':= Date2DMY(');
        // 'Format(Today,' to 'Format(Today(),'
        ReplacePatterns.Add('Format(Today,', 'Format(Today(),');
        // '; UserId)' to '; UserId())'
        ReplacePatterns.Add('; UserId)', '; UserId())');
        // '.CreateOutstream(' to '.CreateOutStream('
        ReplacePatterns.Add('.CreateOutstream(', '.CreateOutStream(');
        // 'Permissions = TableData' to 'Permissions = tabledata'
        ReplacePatterns.Add('Permissions = TableData', 'Permissions = tabledata');
        // '.GetRangemax(' to '.GetRangeMax('
        ReplacePatterns.Add('.GetRangemax(', '.GetRangeMax(');
        // ', Today);' to ', Today());'
        ReplacePatterns.Add(', Today);', ', Today());');
        // 'CurrReport.Newpage();' to 'CurrReport.NewpPage();'
        ReplacePatterns.Add('CurrReport.Newpage();', 'CurrReport.NewpPage();');
        // '.Hasvalue ' to '.HasValue '
        ReplacePatterns.Add('.Hasvalue ', '.HasValue ');
        // '.SetAutocalcFields(' to '.SetAutoCalcFields('
        ReplacePatterns.Add('.SetAutocalcFields(', '.SetAutoCalcFields(');
        // 'StringBuilder.ToString;' to 'StringBuilder.ToString();'
        ReplacePatterns.Add('StringBuilder.ToString;', 'StringBuilder.ToString();');
        // '"object type"::' to '"Object Type"::'
        ReplacePatterns.Add('"object type"::', '"Object Type"::');
        // '"cell type"::' to '"Cell Type"::'
        ReplacePatterns.Add('"cell type"::', '"Cell Type"::');
        // '"document type"::' to '"Document Type"::'
        ReplacePatterns.Add('"document type"::', '"Document Type"::');
        // '"account type"::' to '"Account Type"::'
        ReplacePatterns.Add('"account type"::', '"Account Type"::');
        // '"application status"::' to '"Application Status"::'
        ReplacePatterns.Add('"application status"::', '"Application Status"::');
        // '"applies-to doc. type"::' to '"Applies-to Doc. Type"::'
        ReplacePatterns.Add('"applies-to doc. type"::', '"Applies-to Doc. Type"::');
        // '"bal. account type"::' to '"Bal. Account Type"::'
        ReplacePatterns.Add('"bal. account type"::', '"Bal. Account Type"::');
        // '"income/balance"::' to '"Income/Balance"::'
        ReplacePatterns.Add('"income/balance"::', '"Income/Balance"::');
        // '"gen. posting type"::' to '"Gen. Posting Type"::'
        ReplacePatterns.Add('"gen. posting type"::', '"Gen. Posting Type"::');
        // '"vat calculation type"::' to '"VAT Calculation Type"::'
        ReplacePatterns.Add('"vat calculation type"::', '"VAT Calculation Type"::');
        // '"entry type"::' to '"Entry Type"::'
        ReplacePatterns.Add('"entry type"::', '"Entry Type"::');
        // '"ledger entry status"::' to '"Ledger Entry Status"::'
        ReplacePatterns.Add('"ledger entry status"::', '"Ledger Entry Status"::');
        // '."sales type"::' to '."Sales Type"::'
        ReplacePatterns.Add('."sales type"::', '."Sales Type"::');
        // ' CurrentDatetime ' to ' CurrentDateTime() '
        ReplacePatterns.Add(' CurrentDatetime ', ' CurrentDateTime() ');
        // '."action type"::' to '."Action Type"::'
        ReplacePatterns.Add('."action type"::', '."Action Type"::');
        // '."sorting method"::' to '."Sorting Method"::'
        ReplacePatterns.Add('."sorting method"::', '."Sorting Method"::');
        // '."destination type"::' to '."Destination Type"::'
        ReplacePatterns.Add('."destination type"::', '."Destination Type"::');
        // 'COMPANYNAME <>' to 'CompanyName() <>'
        ReplacePatterns.Add('COMPANYNAME <>', 'CompanyName() <>');
        // 'Format(Time,' to 'Format(Time(),'
        ReplacePatterns.Add('Format(Time,', 'Format(Time(),');
        // '"logistic status"::' to '"Logistic Status"::'
        ReplacePatterns.Add('"logistic status"::', '"Logistic Status"::');
        // ', Today,' to ', Today(),'
        ReplacePatterns.Add(', Today,', ', Today(),');
        // '"purchase method"::' to '"Purchase Method"::'
        ReplacePatterns.Add('"purchase method"::', '"Purchase Method"::');
        // 'GetLastErrorText;' to 'GetLastErrorText();'
        ReplacePatterns.Add('GetLastErrorText;', 'GetLastErrorText();');
        // '"item ledger entry type"::' to '"Item Ledger Entry Type"::'
        ReplacePatterns.Add('"item ledger entry type"::', '"Item Ledger Entry Type"::');
        // '.Newpage();' to '.NewPage();'
        ReplacePatterns.Add('.Newpage();', '.NewPage();');
        // '"system indicator"::' to '"System Indicator"::'
        ReplacePatterns.Add('"system indicator"::', '"System Indicator"::');
        // '"system indicator style"::' to '"System Indicator Style"::'
        ReplacePatterns.Add('"system indicator style"::', '"System Indicator Style"::');
        // '"link to table"::' to '"Link to Table"::'
        ReplacePatterns.Add('"link to table"::', '"Link to Table"::');
        // '"message type"::' to '"Message Type"::'
        ReplacePatterns.Add('"message type"::', '"Message Type"::');
        // '(COMPANYNAME in' to '(CompanyName() in'
        ReplacePatterns.Add('(COMPANYNAME in', '(CompanyName() in');
        // 'CompanyInformation.Iban' to 'CompanyInformation.IBAN'
        ReplacePatterns.Add('CompanyInformation.Iban', 'CompanyInformation.IBAN');
        // '"line type"::' to '"Line Type"::'
        ReplacePatterns.Add('"line type"::', '"Line Type"::');
        // '"activity type"::' to '"Activity Type"::'
        ReplacePatterns.Add('"activity type"::', '"Activity Type"::');
        // '"salutation type"::' to '"Salutation Type"::'
        ReplacePatterns.Add('"salutation type"::', '"Salutation Type"::');
        // 'addfirst(reporting)' to 'addfirst(Reporting)'
        ReplacePatterns.Add('addfirst(reporting)', 'addfirst(Reporting)');
        // 'RunObject = Report ' to 'RunObject = report '
        ReplacePatterns.Add('RunObject = Report ', 'RunObject = report ');
        // 'addfirst(processing)' to 'addfirst(Processing)'
        ReplacePatterns.Add('addfirst(processing)', 'addfirst(Processing)');
        // 'RunObject = XMLport ' to 'RunObject = xmlport '
        ReplacePatterns.Add('RunObject = XMLport ', 'RunObject = xmlport ');
        // '.ToString' to '.ToString()'
        ReplacePatterns.Add('.ToString', '.ToString()');
        // '.Flush;' to '.Flush();'
        ReplacePatterns.Add('.Flush;', '.Flush();');
        // '.ApplicationClass;' to '.ApplicationClass();'
        ReplacePatterns.Add('.ApplicationClass;', '.ApplicationClass();');
        // '.Clear;' to '.Clear();'
        ReplacePatterns.Add('.Clear;', '.Clear();');
        // '.Close;' to '.Close();'
        ReplacePatterns.Add('.Close;', '.Close();');
        // '.Dispose;' to '.Dispose();'
        ReplacePatterns.Add('.Dispose;', '.Dispose();');
        // '.DOMDocumentClass;' to '.DOMDocumentClass();'
        ReplacePatterns.Add('.DOMDocumentClass;', '.DOMDocumentClass();');
        // '.ToCharArray)' to '.ToCharArray())'
        ReplacePatterns.Add('.ToCharArray)', '.ToCharArray())');
        // '"transfer status"::' to '"Transfer Status"::'
        ReplacePatterns.Add('"transfer status"::', '"Transfer Status"::');
        // '"application table no."::' to '"Application Table No."::'
        ReplacePatterns.Add('"application table no."::', '"Application Table No."::');
        // '"attribute type"::' to '"Attribute Type"::'
        ReplacePatterns.Add('"attribute type"::', '"Attribute Type"::');
        // '"bal. applies-to doc. type"::' to '"Bal. Applies-to Doc. Type"::'
        ReplacePatterns.Add('"bal. applies-to doc. type"::', '"Bal. Applies-to Doc. Type"::');
        // '"bal. gen. posting type"::' to '"Bal. Gen. Posting Type"::'
        ReplacePatterns.Add('"bal. gen. posting type"::', '"Bal. Gen. Posting Type"::');
        // '"source document"::' to '"Source Document"::'
        ReplacePatterns.Add('"source document"::', '"Source Document"::');
        // '"bank payment type"::' to '"Bank Payment Type"::'
        ReplacePatterns.Add('"bank payment type"::', '"Bank Payment Type"::');
        // '"billing type"::' to '"Billing Type"::'
        ReplacePatterns.Add('"billing type"::', '"Billing Type"::');
        // '"caused by function"::' to '"Caused by Function"::'
        ReplacePatterns.Add('"caused by function"::', '"Caused by Function"::');
        // '"channel interface via"::' to '"Channel Interface via"::'
        ReplacePatterns.Add('"channel interface via"::', '"Channel Interface via"::');
        // '"check item"::' to '"Check Item"::'
        ReplacePatterns.Add('"check item"::', '"Check Item"::');
        // '"client type"::' to '"Client Type"::'
        ReplacePatterns.Add('"client type"::', '"Client Type"::');
        // '"contract party type"::' to '"Contract Party Type"::'
        ReplacePatterns.Add('"contract party type"::', '"Contract Party Type"::');
        // '"created by function"::' to '"Created by Function"::'
        ReplacePatterns.Add('"created by function"::', '"Created by Function"::');
        // '"credit card type"::' to '"Credit Card Type"::'
        ReplacePatterns.Add('"credit card type"::', '"Credit Card Type"::');
        // '"customer if dataschema"::' to '"Customer IF dataschema"::'
        ReplacePatterns.Add('"customer if dataschema"::', '"Customer IF dataschema"::');
        // '"delete item options"::' to '"Delete Item Options"::'
        ReplacePatterns.Add('"delete item options"::', '"Delete Item Options"::');
        // '"delete permission"::' to '"Delete Permission"::'
        ReplacePatterns.Add('"delete permission"::', '"Delete Permission"::');
        // '"delivery time"::' to '"Delivery Time"::'
        ReplacePatterns.Add('"delivery time"::', '"Delivery Time"::');
        // '"demage classification"::' to '"Demage Classification"::'
        ReplacePatterns.Add('"demage classification"::', '"Demage Classification"::');
        // '"discount state"::' to '"Discount State"::'
        ReplacePatterns.Add('"discount state"::', '"Discount State"::');
        // '"document status"::' to '"Document Status"::'
        ReplacePatterns.Add('"document status"::', '"Document Status"::');
        // '"error processing"::' to '"Error Processing"::'
        ReplacePatterns.Add('"error processing"::', '"Error Processing"::');
        // '"execute permission"::' to '"Execute Permission"::'
        ReplacePatterns.Add('"execute permission"::', '"Execute Permission"::');
        // '"file type"::' to '"File Type"::'
        ReplacePatterns.Add('"file type"::', '"File Type"::');
        // '"item if dataschema"::' to '"Item IF dataschema"::'
        ReplacePatterns.Add('"item if dataschema"::', '"Item IF dataschema"::');
        // '"job task type"::' to '"Job Task Type"::'
        ReplacePatterns.Add('"job task type"::', '"Job Task Type"::');
        // '"link rule"::' to '"Link Rule"::'
        ReplacePatterns.Add('"link rule"::', '"Link Rule"::');
        // '"linking from type"::' to '"Linking From Type"::'
        ReplacePatterns.Add('"linking from type"::', '"Linking From Type"::');
        // '"message direction"::' to '"Message Direction"::'
        ReplacePatterns.Add('"message direction"::', '"Message Direction"::');
        // '"notification method"::' to '"Notification Method"::'
        ReplacePatterns.Add('"notification method"::', '"Notification Method"::');
        // '"payback method"::' to '"Payback Method"::'
        ReplacePatterns.Add('"payback method"::', '"Payback Method"::');
        // '"period type"::' to '"Period Type"::'
        ReplacePatterns.Add('"period type"::', '"Period Type"::');
        // '"posting status"::' to '"Posting Status"::'
        ReplacePatterns.Add('"posting status"::', '"Posting Status"::');
        // '"pre-tax / after-tax"::' to '"Pre-Tax / After-Tax"::'
        ReplacePatterns.Add('"pre-tax / after-tax"::', '"Pre-Tax / After-Tax"::');
        // '"processing status rma"::' to '"Processing Status RMA"::'
        ReplacePatterns.Add('"processing status rma"::', '"Processing Status RMA"::');
        // '"processing status tsa"::' to '"Processing Status TSA"::'
        ReplacePatterns.Add('"processing status tsa"::', '"Processing Status TSA"::');
        // '"processing status"::' to '"Processing Status"::'
        ReplacePatterns.Add('"processing status"::', '"Processing Status"::');
        // '"purch. order can.if dataschema"::' to '"Purch. Order Can.IF dataschema"::'
        ReplacePatterns.Add('"purch. order can.if dataschema"::', '"Purch. Order Can.IF dataschema"::');
        // '"purch. rcpt. if dataschema"::' to '"Purch. Rcpt. IF dataschema"::'
        ReplacePatterns.Add('"purch. rcpt. if dataschema"::', '"Purch. Rcpt. IF dataschema"::');
        // '"purchase order if dataschema"::' to '"Purchase Order IF dataschema"::'
        ReplacePatterns.Add('"purchase order if dataschema"::', '"Purchase Order IF dataschema"::');
        // '"recycling decision"::' to '"Recycling Decision"::'
        ReplacePatterns.Add('"recycling decision"::', '"Recycling Decision"::');
        // '"reference document"::' to '"Reference Document"::'
        ReplacePatterns.Add('"reference document"::', '"Reference Document"::');
        // '"return method"::' to '"Return Method"::'
        ReplacePatterns.Add('"return method"::', '"Return Method"::');
        // '"rule apply type"::' to '"Rule Apply Type"::'
        ReplacePatterns.Add('"rule apply type"::', '"Rule Apply Type"::');
        // '"rule type"::' to '"Rule Type"::'
        ReplacePatterns.Add('"rule type"::', '"Rule Type"::');
        // '"sales cr.memo if dataschema"::' to '"Sales Cr.Memo IF dataschema"::'
        ReplacePatterns.Add('"sales cr.memo if dataschema"::', '"Sales Cr.Memo IF dataschema"::');
        // '"sales header status"::' to '"Sales Header Status"::'
        ReplacePatterns.Add('"sales header status"::', '"Sales Header Status"::');
        // '"sales invoice if dataschema"::' to '"Sales Invoice IF dataschema"::'
        ReplacePatterns.Add('"sales invoice if dataschema"::', '"Sales Invoice IF dataschema"::');
        // '"sales order can.if dataschema"::' to '"Sales Order Can.IF dataschema"::'
        ReplacePatterns.Add('"sales order can.if dataschema"::', '"Sales Order Can.IF dataschema"::');
        // '"sales order if dataschema"::' to '"Sales Order IF dataschema"::'
        ReplacePatterns.Add('"sales order if dataschema"::', '"Sales Order IF dataschema"::');
        // '"sales shipment if dataschema"::' to '"Sales Shipment IF dataschema"::'
        ReplacePatterns.Add('"sales shipment if dataschema"::', '"Sales Shipment IF dataschema"::');
        // '"sales type"::' to '"Sales Type"::'
        ReplacePatterns.Add('"sales type"::', '"Sales Type"::');
        // '"security protocol"::' to '"Security Protocol"::'
        ReplacePatterns.Add('"security protocol"::', '"Security Protocol"::');
        // '"send invoice email to"::' to '"Send Invoice Email to"::'
        ReplacePatterns.Add('"send invoice email to"::', '"Send Invoice Email to"::');
        // '"shipping advice"::' to '"Shipping Advice"::'
        ReplacePatterns.Add('"shipping advice"::', '"Shipping Advice"::');
        // '"source subtype"::' to '"Source Subtype"::'
        ReplacePatterns.Add('"source subtype"::', '"Source Subtype"::');
        // '"source table"::' to '"Source Table"::'
        ReplacePatterns.Add('"source table"::', '"Source Table"::');
        // '"source type"::' to '"Source Type"::'
        ReplacePatterns.Add('"source type"::', '"Source Type"::');
        // '"status defect"::' to '"Status Defect"::'
        ReplacePatterns.Add('"status defect"::', '"Status Defect"::');
        // '"status guarantee"::' to '"Status Guarantee"::'
        ReplacePatterns.Add('"status guarantee"::', '"Status Guarantee"::');
        // '"table name"::' to '"Table Name"::'
        ReplacePatterns.Add('"table name"::', '"Table Name"::');
        // '"terminated by"::' to '"Terminated by"::'
        ReplacePatterns.Add('"terminated by"::', '"Terminated by"::');
        // '"transaction type for aos debit"::' to '"Transaction Type for AoS Debit"::'
        ReplacePatterns.Add('"transaction type for aos debit"::', '"Transaction Type for AoS Debit"::');
        // '"transaction type for aos pay."::' to '"Transaction Type for AoS Pay."::'
        ReplacePatterns.Add('"transaction type for aos pay."::', '"Transaction Type for AoS Pay."::');
        // '"transport claim type"::' to '"Transport Claim Type"::'
        ReplacePatterns.Add('"transport claim type"::', '"Transport Claim Type"::');
        // '"type of change"::' to '"Type of Change"::'
        ReplacePatterns.Add('"type of change"::', '"Type of Change"::');
        // '"type of count bin"::' to '"Type of count Bin"::'
        ReplacePatterns.Add('"type of count bin"::', '"Type of count Bin"::');
        // '"type of count item"::' to '"Type of count Item"::'
        ReplacePatterns.Add('"type of count item"::', '"Type of count Item"::');
        // '"validate type"::' to '"Validate Type"::'
        ReplacePatterns.Add('"validate type"::', '"Validate Type"::');
        // '"value posting"::' to '"Value Posting"::'
        ReplacePatterns.Add('"value posting"::', '"Value Posting"::');
        // '"webservice status"::' to '"Webservice Status"::'
        ReplacePatterns.Add('"webservice status"::', '"Webservice Status"::');
        // '"whse. document type"::' to '"Whse. Document Type"::'
        ReplacePatterns.Add('"whse. document type"::', '"Whse. Document Type"::');
        // '"wizard step"::' to '"Wizard Step"::'
        ReplacePatterns.Add('"wizard step"::', '"Wizard Step"::');

    end;

    local procedure ProcessALFile(ALFilePath: Text; ALFilname: Text)
    var
        ALFileInput: File;
        ALFileOutput: File;
        ALFileInStream: InStream;
        ALFileOutStream: OutStream;
        ALFileContentNew: Text;
        ALFileContentOld: Text;
        ALFileOutputPath: Text;
        ALTextBuilder: TextBuilder;

    begin

        // Define filepath for new file
        ALFileOutputPath := ExportFolder + ALFilname + '.txt';

        // Create new file
        ALFileOutput.WriteMode(true);
        ALFileOutput.Create(ALFileOutputPath);
        ALFileOutput.CreateOutStream(ALFileOutStream);

        // Open and read one AL File
        ALFileInput.Open(ALFilePath);
        ALFileInput.CreateInStream(ALFileInStream);
        while not ALFileInStream.EOS() do begin

            // read Line
            ALFileInStream.ReadText(ALFileContentOld);

            // TODO optimization: skip empty lines
            ProcessRegexRules(ALFileContentOld, ALFileContentNew);
            ProcessOtherRules(ALFileContentNew);

            ALTextBuilder.AppendLine(ALFileContentNew);

        end;


        // Write the new content to the output
        ALFileOutStream.WriteText(ALTextBuilder.ToText());

        // Close the file and move it to a different location
        ALFileOutput.Close();

    end;

    local procedure ProcessOtherRules(var ALFileContentNew: Text)
    var
        DictKey: Text;
    begin

        foreach DictKey in ReplacePatterns.Keys() do
            ALFileContentNew := ALFileContentNew.Replace(DictKey, ReplacePatterns.Get(DictKey));

    end;

    local procedure ProcessRegexRules(ALFileContentOld: Text; var ALFileContentNew: Text)
    var
        RegexFunctions: Codeunit Regex;
        DictKey: Text;
    begin

        foreach DictKey in RegexPatterns.Keys() do
            ALFileContentOld := RegexFunctions.Replace(ALFileContentOld, DictKey, RegexPatterns.Get(DictKey), 999);

        ALFileContentNew := ALFileContentOld;

    end;
}
