page 50000 ARD_CustomerImport
{
    ApplicationArea = All;
    Caption = 'Customer Import';
    PageType = List;
    SourceTable = ARD_CustomerStaging;
    SourceTableTemporary = true;
    UsageCategory = Tasks;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'Import Details';
                field(ImportText; ImportText)
                {
                    ApplicationArea = All;
                    Caption = 'Import Text';
                    ToolTip = 'The text content of the imported file.';
                    Editable = false;
                    MultiLine = true;
                }
            }
            repeater(Records)
            {
                field("ARD_No."; Rec."ARD_No.")
                {
                }
                field(ARD_Name; Rec.ARD_Name)
                {
                }
                field(ARD_AddressLine1; Rec.ARD_AddressLine1)
                {
                }
                field(ARD_AddressLine2; Rec.ARD_AddressLine2)
                {
                }
                field(ARD_City; Rec.ARD_City)
                {
                }
                field(ARD_State; Rec.ARD_State)
                {
                }
                field(ARD_PostalCode; Rec.ARD_PostalCode)
                {
                }
                field(ARD_ContactEmail; Rec.ARD_ContactEmail)
                {
                }
                field(ARD_CreditLimit; Rec.ARD_CreditLimit)
                {
                }
                field(ARD_CustomerNo; Rec.ARD_CustomerNo)
                {
                }
            }
        }
    }
    actions
    {
        area(Promoted)
        {
            actionref(ImportCSVRef; ImportCSV)
            { }
            actionref(GenerateCustomersRef; GenerateCustomers)
            { }
        }
        area(Processing)
        {
            action(ImportCSV)
            {
                ApplicationArea = All;
                Caption = 'Import';
                Image = Import;
                ToolTip = 'Import Customers from a file.';
                trigger OnAction()
                var
                    FileFilter: Text; // Defines the file filter for the upload dialog
                    InStream: InStream; // Stream to read the uploaded file
                    CurrentText: Text; // Temporary variable to hold the current line of text
                    TextValue: TextBuilder; // TextBuilder to accumulate the file content
                begin
                    // Set the file filter to allow all file types
                    FileFilter := 'All Files (*.csv)|*.csv';

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
                    ParseCustomerData(ImportText);
                end;
            }
            action(GenerateCustomers)
            {
                ApplicationArea = All;
                Caption = 'Generate Customers';
                Image = Create;
                ToolTip = 'Generate customers from the imported data.';
                trigger OnAction()
                begin
                    GenerateCustomerRecords();
                end;
            }
        }
    }

    var
        TempCustomerImportRec: Record ARD_CustomerStaging temporary;
        ImportText: Text;

    procedure ParseCustomerData(customerData: Text)
    var
        Lines: List of [Text];
        Line: Text;
        LineDetails: List of [Text];
        tempDecimal: Decimal;
        CRLF: Char;
        ProcessedHeader: Boolean;
        Count: Integer;
    begin
        Count := 1; // Initialize the count of processed records
        ProcessedHeader := false; // Flag to skip the header line
        CRLF := 10; // Define the line break character

        Lines := customerData.Split(CRLF); // Split the text into lines
        foreach Line in Lines do begin
            if not ProcessedHeader then begin
                // Skip the header line
                ProcessedHeader := true;
                continue;
            end;

            LineDetails := Line.Split(',');

            if LineDetails.Count() < 8 then // Skip lines that do not have enough data
                continue;

            TempCustomerImportRec.Init();
            TempCustomerImportRec."ARD_No." := Count; // Auto-increment field, set to 0 for new records
            TempCustomerImportRec."ARD_Name" := CopyStr(LineDetails.Get(1), 1, 100);
            TempCustomerImportRec."ARD_AddressLine1" := CopyStr(LineDetails.Get(2), 1, 100);
            TempCustomerImportRec."ARD_AddressLine2" := CopyStr(LineDetails.Get(3), 1, 50);
            TempCustomerImportRec."ARD_City" := CopyStr(LineDetails.Get(4), 1, 30);
            TempCustomerImportRec."ARD_State" := CopyStr(LineDetails.Get(5), 1, 30);
            TempCustomerImportRec."ARD_PostalCode" := CopyStr(LineDetails.Get(6), 1, 20);
            TempCustomerImportRec."ARD_ContactEmail" := CopyStr(LineDetails.Get(7), 1, 80);
            if Evaluate(tempDecimal, LineDetails.Get(8)) then
                TempCustomerImportRec."ARD_CreditLimit" := tempDecimal;

            // Insert the record into the staging table
            TempCustomerImportRec.Insert();
            Count += 1;
        end;

        RefreshPage();
    end;

    procedure RefreshPage()
    begin
        Rec.Reset();
        Rec.DeleteAll();
        TempCustomerImportRec.Setfilter("ARD_No.", '<>0'); // Filter out the auto-increment field
        if TempCustomerImportRec.FindSet() then
            repeat
                Rec := TempCustomerImportRec;
                Rec.Insert();
            until TempCustomerImportRec.Next() = 0;
    end;

procedure GenerateCustomerRecords()
var
    CustomerRec: Record Customer;
begin
    TempCustomerImportRec.Setfilter("ARD_No.", '<>0'); // Filter out the auto-increment field
    if TempCustomerImportRec.FindSet() then
        repeat
            CustomerRec.Init();
            CustomerREc."No." := ''; // Let the system assign the customer number
            CustomerRec.Name := TempCustomerImportRec."ARD_Name";
            CustomerRec.Address := TempCustomerImportRec."ARD_AddressLine1";
            CustomerRec."Address 2" := TempCustomerImportRec."ARD_AddressLine2";
            CustomerRec.City := TempCustomerImportRec."ARD_City";
            CustomerRec.County := TempCustomerImportRec."ARD_State";
            CustomerRec."Post Code" := TempCustomerImportRec."ARD_PostalCode";
            CustomerRec."E-Mail" := TempCustomerImportRec."ARD_ContactEmail";
            CustomerRec."Credit Limit (LCY)" := TempCustomerImportRec."ARD_CreditLimit";

            // Insert the customer record into the main customer table
            if CustomerRec.Insert(true) then begin
                TempCustomerImportRec.ARD_CustomerNo := CustomerRec."No.";
                TempCustomerImportRec.Modify();
            end else
                Error(GetLastErrorText());

        until TempCustomerImportRec.Next() = 0;

    RefreshPage();
end;
}
