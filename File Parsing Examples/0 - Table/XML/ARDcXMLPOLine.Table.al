table 50100 "ARD_cXMLPOLine"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "ARD_Line Number"; Integer)
        {
            Caption = 'Line Number';
            ToolTip = 'Unique identifier for the cXML PO Line.';
            AutoIncrement = true;
        }
        field(2; ARD_HeaderNo; Integer)
        {
            Caption = 'Header No.';
            ToolTip = 'Identifier linking to the cXML PO Header.';
        }
        field(3; "ARD_Quantity"; Integer)
        {
            Caption = 'Quantity';
            ToolTip = 'Quantity of the item in the cXML PO Line.';
        }
        field(4; "ARD_Supplier Part ID"; Code[50])
        {
            Caption = 'Supplier Part ID';
            ToolTip = 'Unique identifier for the supplier part.';
        }
        field(5; "ARD_Description"; Text[100])
        {
            Caption = 'Description';
            ToolTip = 'Description of the item in the cXML PO Line.';
        }
        field(6; "ARD_Unit Price"; Decimal)
        {
            Caption = 'Unit Price';
            ToolTip = 'Unit price of the item in the cXML PO Line.';
        }
        field(7; "ARD_Currency"; Code[3])
        {
            Caption = 'Currency';
            ToolTip = 'Currency code for the item in the cXML PO Line.';
        }
        field(8; "ARD_Unit of Measure"; Code[10])
        {
            Caption = 'Unit of Measure';
            ToolTip = 'Unit of measure for the item in the cXML PO Line.';
        }
    }

    keys
    {
        key(PK; "ARD_Line Number", ARD_HeaderNo)
        {
            Clustered = true;
        }
    }
}
