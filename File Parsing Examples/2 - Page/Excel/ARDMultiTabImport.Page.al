namespace aardvark;

using System.IO;
using Microsoft.Inventory.Item;
using Microsoft.Foundation.NoSeries;
using Microsoft.Foundation.UOM;
using System.Utilities;

page 50008 ARD_MultiTabImport
{
    ApplicationArea = All;
    Caption = 'Excel Multi-Tab Import';
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
                field(ARD_DocumentDate; Rec.ARD_DocumentDate)
                {
                }
                field("ARD_ExtDocNo."; Rec."ARD_ExtDocNo.")
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
            actionref(ImportExcelRef; ImportExcel)
            { }
        }

        area(Processing)
        {
            action(ImportExcel)
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

        }
    }

    var
        TempExcelBuffer: Record "Excel Buffer" temporary;


    procedure ImportExcelFile()
    var
        SalesHeaderRec: Record ARD_SalesHeader;
        FileManagement: Codeunit "File Management";
        TempBlob: Codeunit "Temp Blob";
        FileInStream: InStream;
        ImportFileLbl: Label 'Import file';
        DataKeys: Dictionary of [Text, Integer];
        ErrorMessage: Text;
        RowNo: Integer;
        MaxRows: Integer;
        TempDate: Date;
    begin
        RowNo := 0;

        // Select file and import the file to tempBlob
        FileManagement.BLOBImportWithFilter(TempBlob, ImportFileLbl, 'Excel Item Import', FileManagement.GetToFilterText('All Files (*.xlsx)|*.xlsx', '.xlsx'), 'xlsx');

        //Need to see if the temp blob is uninitialized.
        if TempBlob.HasValue() = false then exit;

        // Select sheet from the excel file
        TempBlob.CreateInStream(FileInStream);

        // Open the Header sheet
        ErrorMessage := TempExcelBuffer.OpenBookStream(FileInStream, 'Headers');
        if ErrorMessage <> '' then
            Error(ErrorMessage);

        //Read the sheet into the excel buffer
        TempExcelBuffer.ReadSheet();

        //Finding total number of Rows to Import
        TempExcelBuffer.Reset();
        TempExcelBuffer.FindLast();
        MaxRows := TempExcelBuffer."Row No.";

        SalesHeaderRec.Reset();
        SalesHeaderRec.DeleteAll();

        FOR RowNo := 2 to MaxRows DO begin //Assuming Row 1 has the header information
            SalesHeaderRec."ARD_No." := RowNo - 1;
            SalesHeaderRec."ARD_CustomerNo." := CopyStr(GetValueAtCell(RowNo, 1).Trim(), 1, 20);
            if Evaluate(TempDate, GetValueAtCell(RowNo, 2).Trim()) then
                SalesHeaderRec."ARD_DocumentDate" := TempDate;
            SalesHeaderRec."ARD_ExtDocNo." := CopyStr(GetValueAtCell(RowNo, 3).Trim(), 1, 100);

            if SalesHeaderRec.Insert() then
                DataKeys.Add(SalesHeaderRec."ARD_ExtDocNo.", SalesHeaderRec."ARD_No.");
        end;

        ImportExcelFileLines(FileInStream, DataKeys);
    end;

    procedure ImportExcelFileLines(FileInStream: InStream; DataKeys: Dictionary of [Text, Integer])
    var
        SalesLineRec: Record ARD_SalesDetail;
        ErrorMessage: Text;
        RowNo: Integer;
        MaxRows: Integer;
        TempDecimal: Decimal;
        RowKey: Text;
    begin
        RowNo := 0;

        // Open the Header sheet
        ErrorMessage := TempExcelBuffer.OpenBookStream(FileInStream, 'Lines');
        if ErrorMessage <> '' then
            Error(ErrorMessage);

        //Read the sheet into the excel buffer
        TempExcelBuffer.ReadSheet();

        // Finding total number of Rows to Import
        TempExcelBuffer.Reset();
        TempExcelBuffer.FindLast();
        MaxRows := TempExcelBuffer."Row No.";

        SalesLineRec.Reset();
        SalesLineRec.DeleteAll();

        FOR RowNo := 2 to MaxRows DO begin //Assuming Row 1 has the header information
            salesLineRec."ARD_No." := 0;
            RowKey := GetValueAtCell(RowNo, 1).Trim();
            if DataKeys.ContainsKey(RowKey) then begin
                salesLineRec."ARD_HeaderNo." := DataKeys.Get(RowKey);
                salesLineRec."ARD_ItemNo." := CopyStr(GetValueAtCell(RowNo, 2).Trim(), 1, 20);
                if Evaluate(TempDecimal, GetValueAtCell(RowNo, 3).Trim()) then
                    salesLineRec.ARD_Quantity := TempDecimal;
                salesLineRec.ARD_UoM := CopyStr(GetValueAtCell(RowNo, 4).Trim(), 1, 10);
                salesLineRec.Insert();
            end;
        end;
    end;

    procedure GetValueAtCell(RowNo: Integer; ColNo: Integer): Text
    begin
        TempExcelBuffer.Reset();
        If TempExcelBuffer.Get(RowNo, ColNo) then
            EXIT(TempExcelBuffer."Cell Value as Text")
        else
            EXIT('');
    end;
}
