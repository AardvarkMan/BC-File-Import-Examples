table 50007 ARD_cXMLPOHeader
{
    Caption = 'cXMLPOHeader';
    DataClassification = CustomerContent;
    
    fields
    {
        field(1; "ARD_No."; Integer)
        {
            Caption = 'No.';
            ToolTip = 'Unique identifier for the cXML PO Header.';
            AutoIncrement = true;
        }
        field(2; "ARD_VendorNo."; Code[20])
        {
            Caption = 'Vendor No.';
            ToolTip = 'Unique identifier for the vendor.';
        }
        field(3; ARD_VendorName; Text[100])
        {
            Caption = 'Vendor Name';
            ToolTip = 'Name of the vendor.';
        }
        field(4; ARD_DocumentNo; Code[20])
        {
            Caption = 'Document No';
            ToolTip = 'Document number of the purchase order.';
        }
        field(5; ARD_OrderDate; Date)
        {
            Caption = 'Order Date';
            ToolTip = 'Date when the purchase order was created.';
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
