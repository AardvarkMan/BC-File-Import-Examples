table 50009 ARD_PAFTPSend
{
    Caption = 'PA_FTPSend';
    DataClassification = CustomerContent;
    
    fields
    {
        field(1; "ARD_No."; Integer)
        {
            Caption = 'No.';
            tooltip = 'Unique number for each file sent to FTP. It is automatically generated.';
            DataClassification = CustomerContent;
            AutoIncrement = true;
        }
        field(2; ARD_GeneratedDate; DateTime)
        {
            Caption = 'Generated Date';
            tooltip = 'Date and time when the file was generated to be sent to FTP.';
            DataClassification = CustomerContent;
        }
        field(3; ARD_Handled; Boolean)
        {
            Caption = 'Handled';
            tooltip = 'Indicates whether the file has been handled (sent) to FTP.';
            DataClassification = CustomerContent;
        }
        field(4; ARD_HandledDateTime; DateTime)
        {
            Caption = 'Handled Date Time';
            tooltip = 'Date and time when the file was handled (sent) to FTP.';
            DataClassification = CustomerContent;
        }
        field(5; ARD_Invoice; Blob)
        {
            Caption = 'Invoice';
            ToolTip = 'The invoice data associated with the record.';
            DataClassification = CustomerContent;
        }
        field(6; ARD_InvoiceFileName; Text[255])
        {
            Caption = 'Invoice File Name';
            ToolTip = 'The file name of the invoice data.';
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
