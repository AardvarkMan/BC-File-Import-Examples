table 50005 ARD_SalesDetail
{
    Caption = 'Delimited Sales Detail';
    DataClassification = CustomerContent;
    
    fields
    {
        field(1; "ARD_No."; Integer)
        {
            Caption = 'No.';
            ToolTip = 'Unique identifier for the sales detail.';
            AutoIncrement = true;
        }
        field(2; "ARD_HeaderNo."; Integer)
        {
            Caption = 'Header No.';
            ToolTip = 'Unique identifier for the sales header.';
            TableRelation = ARD_SalesHeader."ARD_No.";
        }
        field(3; "ARD_ItemNo."; Text[20])
        {
            Caption = 'Item No.';
            ToolTip = 'Unique identifier for the item.';
        }
        field(4; ARD_Quantity; Decimal)
        {
            Caption = 'Quantity';
            ToolTip = 'Quantity of the item.';
        }
        field(5; ARD_UoM; Text[10])
        {
            Caption = 'UoM';
            ToolTip = 'Unit of Measure.';
        }
        field(6; ARD_SalesLineNo; Integer)
        {
            Caption = 'Sales Line No.';
            ToolTip = 'Unique identifier for the sales line.';
        }
    }
    keys
    {
        key(PK; "ARD_No.", "ARD_HeaderNo.")
        {
            Clustered = true;
        }
    }
}
