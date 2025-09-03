table 50004 ARD_SalesHeader
{
    Caption = 'Delimited Sales Header';
    DataClassification = CustomerContent;
    
    fields
    {
        field(1; "ARD_No."; Integer)
        {
            Caption = 'No.';
            ToolTip = 'Unique identifier for the sales header.';
            AutoIncrement = true;
        }
        field(2; "ARD_CustomerNo."; Text[20])
        {
            Caption = 'Customer No.';
            ToolTip = 'Unique identifier for the customer.';
        }
        field(3; ARD_DocumentDate; Date)
        {
            Caption = 'Document Date';
            ToolTip = 'Date of the document.';
        }
        field(4; "ARD_ExtDocNo."; Text[100])
        {
            Caption = 'Ext Doc No.';
            ToolTip = 'External document number.';
        }
        field(5; "ARD_SalesHeaderNo."; Code[20])
        {
            Caption = 'Sales Header No.';
            ToolTip = 'Unique identifier for the sales header.';
            TableRelation = "Sales Header"."No.";
        }
    }
    keys
    {
        key(PK; "ARD_No.")
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    var
        SalesDetail: Record ARD_SalesDetail;
    begin
        SalesDetail.SetRange("ARD_HeaderNo.", "ARD_No.");
        SalesDetail.DeleteAll();
    end;

procedure CreateSalesOrder()
var
    SalesHeader: Record "Sales Header";
    SalesLine: Record "Sales Line";
    SalesDetail: Record ARD_SalesDetail;
    LineNo: Integer;
begin
    // Set Sales Header fields for a new sales order
    SalesHeader."Document Type" := Enum::"Sales Document Type"::Order;
    SalesHeader.InitInsert();
    SalesHeader.validate("Sell-to Customer No.", Rec."ARD_CustomerNo.");
    SalesHeader.validate("External Document No.", Rec."ARD_ExtDocNo.");
    SalesHeader.Validate("Document Date", Rec.ARD_DocumentDate);
    SalesHeader.Validate("Posting Date", Rec.ARD_DocumentDate);

    // Insert the Sales Header record
    if SalesHeader.Insert() then begin
        // Store the created Sales Header No. in the current record
        Rec."ARD_SalesHeaderNo." := SalesHeader."No.";

        // Filter Sales Detail lines for the current header
        SalesDetail.SetFilter("ARD_HeaderNo.", '%1', Rec."ARD_No.");
        LineNo := 1;

        // Loop through all Sales Detail lines and create Sales Lines
        if SalesDetail.findset() then
            repeat
                SalesLine.Init();
                SalesLine."Document Type" := Enum::"Sales Document Type"::Order;
                SalesLine."Document No." := SalesHeader."No.";
                SalesLine.Type := Enum::"Sales Line Type"::Item;
                SalesLine."Line No." := LineNo * 10000;
                SalesLine.Validate("No.", SalesDetail."ARD_ItemNo.");
                SalesLine.Validate(Quantity, SalesDetail.ARD_Quantity);
                SalesLine.Validate("Unit of Measure Code", SalesDetail.ARD_UoM);

                // Insert the Sales Line record
                if SalesLine.Insert() then begin
                    LineNo := LineNo + 1;
                    // Store the created Sales Line No. in the Sales Detail record
                    SalesDetail.ARD_SalesLineNo := SalesLine."Line No.";
                    SalesDetail.Modify()
                end;
            until SalesDetail.Next() = 0;
    end;
end;
}