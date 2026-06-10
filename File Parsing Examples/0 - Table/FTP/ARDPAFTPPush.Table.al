table 50008 ARD_PA_FTPPush
{
    Caption = 'PA_FTPPush';
    DataClassification = ToBeClassified;
    
    fields
    {
        field(1; "ARD_No."; Integer)
        {
            Caption = 'No.';
            tooltip = 'Unique number for each file pushed to FTP. It is automatically generated.';
            DataClassification = CustomerContent;
            autoIncrement = true;
        }
        field(2; ARD_FileContent; Blob)
        {
            Caption = 'File Content';
            tooltip = 'Content of the file pushed to FTP.';
            DataClassification = CustomerContent;
        }
        field(3; ARD_DateTime; DateTime)
        {
            Caption = 'Date Time';
            tooltip = 'Date and time when the file was pushed to FTP.';
            DataClassification = CustomerContent;
        }
        field(4; ARD_FileName; Text[255])
        {
            Caption = 'File Name';
            tooltip = 'Name of the file pushed to FTP.';
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
