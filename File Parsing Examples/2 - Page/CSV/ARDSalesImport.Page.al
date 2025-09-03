page 50005 ARD_SalesImport
{
    ApplicationArea = All;
    Caption = 'Sales Import';
    PageType = List;
    SourceTable = ARD_SalesHeader;
    UsageCategory = Lists;
    CardPageId = ARD_SalesImportCard;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("ARD_No."; Rec."ARD_No.")
                {
                }
                field("ARD_CustomerNo."; Rec."ARD_CustomerNo.")
                {
                }
                field("ARD_ExtDocNo."; Rec."ARD_ExtDocNo.")
                {
                }
                field(ARD_DocumentDate; Rec.ARD_DocumentDate)
                {
                }
                field("ARD_SalesHeaderNo."; Rec."ARD_SalesHeaderNo.")
                {
                }
            }
        }
    }
    actions
    {
        area(Promoted)
        {
            actionref(Normalized; ImportNormalized) { }
            actionref(Denormalized; ImportDenormalized) { }
        }
        area(processing)
        {
            action(ImportNormalized)
            {
                ApplicationArea = All;
                Caption = 'Import Normalized';
                ToolTip = 'Import normalized sales data.';
                Image = Import;
                trigger OnAction()
                var
                    FileFilter: Text; // Defines the file filter for the upload dialog
                    InStream: InStream; // Stream to read the uploaded file
                    CurrentText: Text; // Temporary variable to hold the current line of text
                    TextValue: TextBuilder; // TextBuilder to accumulate the file content
                begin
                    // Set the file filter to allow all file types
                    FileFilter := 'All Files (*.txt)|*.txt';

                    // Open a dialog to upload a file and read its content into a stream
                    if UploadIntoStream(FileFilter, InStream) then
                        // Read the stream line by line until the end of the stream
                        while InStream.EOS = false do
                            // Append each line of text to the TextBuilder
                            if InStream.ReadText(CurrentText) <> 0 then
                                TextValue.AppendLine(CurrentText);

                    // Convert the accumulated text into a single string
                    ImportText := TextValue.ToText();
                    // Parse the customer data from the imported text
                    ParseNormalizedSalesData(ImportText);
                end;
            }
            action(ImportDenormalized)
            {
                ApplicationArea = All;
                Caption = 'Import Denormalized';
                ToolTip = 'Import denormalized sales data.';
                Image = Import;
                trigger OnAction()
                var
                    FileFilter: Text; // Defines the file filter for the upload dialog
                    InStream: InStream; // Stream to read the uploaded file
                    CurrentText: Text; // Temporary variable to hold the current line of text
                    TextValue: TextBuilder; // TextBuilder to accumulate the file content
                begin
                    // Set the file filter to allow all file types
                    FileFilter := 'All Files (*.txt)|*.txt';

                    // Open a dialog to upload a file and read its content into a stream
                    if UploadIntoStream(FileFilter, InStream) then
                        // Read the stream line by line until the end of the stream
                        while InStream.EOS = false do
                            // Append each line of text to the TextBuilder
                            if InStream.ReadText(CurrentText) <> 0 then
                                TextValue.AppendLine(CurrentText);

                    // Convert the accumulated text into a single string
                    ImportText := TextValue.ToText();
                    // Parse the customer data from the imported text
                    ParseDenormalizedSalesData(ImportText);
                end;
            }
        }
    }

    var
        ImportText: Text;

    procedure ParseDenormalizedSalesData(SalesTextText: Text)
    var
        SalesHeader: Record "ARD_SalesHeader";
        SalesDetail: Record "ARD_SalesDetail";
        Lines: List of [Text];
        Line: Text;
        LineDetails: List of [Text];
        tempDate: Date;
        tempDecimal: Decimal;
        CRLF: Char;
        CurrentHeaderId: Integer;
        CurrentExternalDocumentNo: Text[100];
        LastExternalDocumentNo: Text[100];
    begin
        LastExternalDocumentNo := ''; // Initialize last external document number

        CRLF := 10; // Define the line break character

        // Split the imported text into lines
        Lines := SalesTextText.Split(CRLF);

        // Process each line
        foreach Line in Lines do begin
            if StrLen(Line.Trim()) < 1 then
                continue; // Skip empty lines

            LineDetails := Line.Split('|'); // Split line into fields by delimiter
            CurrentExternalDocumentNo := CopyStr(LineDetails.Get(3), 1, 100); // Get current external document number

            // If the external document number changes, create a new header
            if LastExternalDocumentNo <> CurrentExternalDocumentNo then begin
                SalesHeader."ARD_No." := 0; // Initialize header record
                SalesHeader."ARD_CustomerNo." := CopyStr(LineDetails.Get(1), 1, 20); // Set customer number
                                                                                     // Set document date if valid
                if Evaluate(tempDate, LineDetails.Get(2)) then
                    SalesHeader.ARD_DocumentDate := tempDate;
                SalesHeader."ARD_ExtDocNo." := CopyStr(LineDetails.Get(3), 1, 100); // Set external document number
                SalesHeader.Insert(); // Insert header record
                LastExternalDocumentNo := CurrentExternalDocumentNo; // Update last external document number
                CurrentHeaderId := SalesHeader."ARD_No."; // Store header ID for details
            end;

            SalesDetail."ARD_No." := 0; // Initialize detail record
            SalesDetail."ARD_HeaderNo." := CurrentHeaderId; // Link to header
            SalesDetail."ARD_ItemNo." := CopyStr(LineDetails.Get(4), 1, 20); // Set item number
                                                                             // Set quantity if valid
            if Evaluate(tempDecimal, LineDetails.Get(5)) then
                SalesDetail.ARD_Quantity := tempDecimal;
            SalesDetail.ARD_UoM := CopyStr(LineDetails.Get(6), 1, 10); // Set unit of measure
            SalesDetail.Insert(); // Insert detail record
        end;
    end;

    procedure ParseNormalizedSalesData(SalesTextText: Text)
    var
        SalesHeader: Record "ARD_SalesHeader";
        SalesDetail: Record "ARD_SalesDetail";
        Lines: List of [Text];
        Line: Text;
        LineDetails: List of [Text];
        tempDate: Date;
        tempDecimal: Decimal;
        CRLF: Char;
        CurrentHeaderId: Integer;
    begin
        CRLF := 10; // Define the line break character

        // Split the imported text into lines
        Lines := SalesTextText.Split(CRLF);

        // Process each line
        foreach Line in Lines do begin
            if StrLen(Line.Trim()) < 1 then
                continue; // Skip empty lines

            LineDetails := Line.Split('|'); // Split line into fields by delimiter

            // Check if the line is a header line
            if LineDetails.Get(1).ToLower() = 'h' then begin
                SalesHeader."ARD_No." := 0; // Initialize header record
                SalesHeader."ARD_CustomerNo." := CopyStr(LineDetails.Get(2), 1, 20); // Set customer number
                if Evaluate(tempDate, LineDetails.Get(3)) then
                    SalesHeader.ARD_DocumentDate := tempDate; // Set document date
                SalesHeader."ARD_ExtDocNo." := CopyStr(LineDetails.Get(4), 1, 100); // Set external document number
                SalesHeader.Insert(); // Insert header record
                CurrentHeaderId := SalesHeader."ARD_No."; // Store header ID for details
            end else begin
                SalesDetail."ARD_No." := 0; // Initialize detail record
                SalesDetail."ARD_HeaderNo." := CurrentHeaderId; // Link to header
                SalesDetail."ARD_ItemNo." := CopyStr(LineDetails.Get(2), 1, 20); // Set item number
                if Evaluate(tempDecimal, LineDetails.Get(3)) then
                    SalesDetail.ARD_Quantity := tempDecimal; // Set quantity
                SalesDetail.ARD_UoM := CopyStr(LineDetails.Get(4), 1, 10); // Set unit of measure
                SalesDetail.Insert(); // Insert detail record
            end;
        end;
    end;
}
