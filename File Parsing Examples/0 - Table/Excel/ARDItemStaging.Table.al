table 50003 ARD_ItemStaging
{
    Caption = 'Item Staging';
    DataClassification = ToBeClassified;
    TableType = Temporary;
    
    fields
    {
        field(1; "ARD_No."; Integer)
        {
            Caption = 'No.';
            ToolTip = 'Unique identifier for the item.';
            DataClassification = CustomerContent;
        }
        field(2; ARD_Name; Text[50])
        {
            Caption = 'Name';
            ToolTip = 'Name of the item.';
            DataClassification = CustomerContent;
        }
        field(3; ARD_Type; Text[20])
        {
            Caption = 'Type';
            ToolTip = 'Type of the item (e.g., Product, Service, etc.).';
            DataClassification = CustomerContent;
        }
        field(4; ARD_UnitOfMeasure; Text[10])
        {
            Caption = 'Unit Of Measure';
            ToolTip = 'Unit of measure for the item (e.g., Each, Dozen, etc.).';
            DataClassification = CustomerContent;
        }
        field(5; ARD_UnitPrice; Decimal)
        {
            Caption = 'Unit Price';
            ToolTip = 'Price per unit of the item.';
            DataClassification = CustomerContent;
        }
        field(6; ARD_Message; Text[1024])
        {
            Caption = 'Message';
            ToolTip = 'Message or error related to the item import.';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "ARD_No.")
        {
            Clustered = true;
        }
    }
}
