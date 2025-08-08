page 50004 ARD_ExcelImport
{
    ApplicationArea = All;
    Caption = 'Excel Item Import';
    PageType = List;
    SourceTable = ARD_ItemStaging;
    UsageCategory = Tasks;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("ARD_No."; Rec."ARD_No.")
                {
                }
                field(ARD_Name; Rec.ARD_Name)
                {
                }
                field(ARD_Type; Rec.ARD_Type)
                {
                }
                field(ARD_UnitOfMeasure; Rec.ARD_UnitOfMeasure)
                {
                }
                field(ARD_UnitPrice; Rec.ARD_UnitPrice)
                {
                }
                field(ARD_Message; Rec.ARD_Message)
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
                ToolTip = 'Import Items from a file.';
                trigger OnAction()
                begin
                    ImportExcelFile();
                end;
            }
            action(GenerateCustomers)
            {
                ApplicationArea = All;
                Caption = 'Generate Items';
                Image = Create;
                ToolTip = 'Generate Items from the imported data.';
                trigger OnAction()
                begin
                    GenerateItemRecords();
                end;
            }
        }
    }

    var
        TempItemRec: Record ARD_ItemStaging temporary;
        TempExcelBuffer: Record "Excel Buffer" temporary;

    procedure ImportExcelFile()
    var
        FileManagement: Codeunit "File Management";
        TempBlob: Codeunit "Temp Blob";
        SheetName, ErrorMessage : Text;
        FileInStream: InStream;
        ImportFileLbl: Label 'Import file';

        RowNo: Integer;
        MaxRows: Integer;
        TempDecimal: Decimal;
    begin
        RowNo := 0;

        // Select file and import the file to tempBlob
        FileManagement.BLOBImportWithFilter(TempBlob, ImportFileLbl, 'Excel Item Import', FileManagement.GetToFilterText('All Files (*.xlsx)|*.xlsx', '.xlsx'), 'xlsx');

        //Need to see if the temp blob is uninitialized.
        if TempBlob.HasValue() = false then exit;

        // Select sheet from the excel file
        TempBlob.CreateInStream(FileInStream);
        SheetName := TempExcelBuffer.SelectSheetsNameStream(FileInStream);

        // Open selected sheet
        ErrorMessage := TempExcelBuffer.OpenBookStream(FileInStream, SheetName);
        if ErrorMessage <> '' then
            Error(ErrorMessage);

        //Read the sheet into the excel buffer
        TempExcelBuffer.ReadSheet();

        //Finding total number of Rows to Import
        TempExcelBuffer.Reset();
        TempExcelBuffer.FindLast();
        MaxRows := TempExcelBuffer."Row No.";

        TempItemRec.Reset();
        TempItemRec.DeleteAll();

        FOR RowNo := 2 to MaxRows DO begin //Assuming Row 1 has the header information
            TempItemRec."ARD_No." := RowNo - 1;
            TempItemRec.ARD_Name := CopyStr(GetValueAtCell(RowNo, 1).Trim(), 1, 50);
            TempItemRec.ARD_Type := CopyStr(GetValueAtCell(RowNo, 2).Trim(), 1, 20);
            TempItemRec.ARD_UnitOfMeasure := CopyStr(GetValueAtCell(RowNo, 3).Trim(), 1, 10);
            if Evaluate(TempDecimal, GetValueAtCell(RowNo, 4).Trim()) then
                TempItemRec.ARD_UnitPrice := TempDecimal;

            TempItemRec.Insert();
        end;

        ValidateData();
        RefreshPage();
    end;

    procedure GetValueAtCell(RowNo: Integer; ColNo: Integer): Text
    begin
        TempExcelBuffer.Reset();
        If TempExcelBuffer.Get(RowNo, ColNo) then
            EXIT(TempExcelBuffer."Cell Value as Text")
        else
            EXIT('');
    end;

    procedure ValidateData()
    var
        UnitofMeasure: Record "Unit of Measure";
        Message: TextBuilder;
    begin
        TempItemRec.Setfilter("ARD_No.", '<>0');
        if TempItemRec.FindSet() then
            repeat
                if TempItemRec.ARD_Type = '' then
                    Message.Append('Type is required.');

                if (TempItemRec.ARD_Type.ToLower() <> 'inventory') and (TempItemRec.ARD_Type.ToLower() <> 'service') then
                    Message.Append('Type must be either Inventory or Service.');

                if not UnitofMeasure.Get(TempItemRec.ARD_UnitOfMeasure) then
                    Message.Append('Unit of Measure does not exist.');

            until TempItemRec.Next() = 0;
    end;

    procedure GenerateItemRecords()
    var
        ItemRec: Record Item;
        NoSeries: Codeunit "No. Series";
    begin
        TempItemRec.Setfilter("ARD_No.", '<>0');
        if TempItemRec.FindSet() then
            repeat
                ItemRec.Init();
                ItemRec."No." := NoSeries.GetNextNo('ITEM');
                ItemRec.Description := TempItemRec.ARD_Name;
                if TempItemRec.ARD_Type.ToLower() = 'inventory' then ItemRec.validate(Type, Enum::"Item Type"::Inventory);
                if TempItemRec.ARD_Type.ToLower() = 'service' then ItemRec.Validate(Type, Enum::"Item Type"::Service);
                ItemRec."Base Unit of Measure" := TempItemRec.ARD_UnitOfMeasure;
                ItemRec."Unit Price" := TempItemRec.ARD_UnitPrice;

                // Insert the item record
                ItemRec.Insert();
            until TempItemRec.Next() = 0;
    end;

    procedure RefreshPage()
    begin
        Rec.Reset();
        Rec.DeleteAll();
        TempItemRec.Setfilter("ARD_No.", '<>0');
        if TempItemRec.FindSet() then
            repeat
                Rec := TempItemRec;
                Rec.Insert();
            until TempItemRec.Next() = 0;
    end;
}
