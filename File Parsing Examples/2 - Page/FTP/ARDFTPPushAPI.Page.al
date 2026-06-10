namespace AardvarkLabs.FileParsingExamples;

page 50015 ARD_FTPPushAPI
{
    APIGroup = 'aardvarklabs';
    APIPublisher = 'aardvarklabs';
    APIVersion = 'v1.0';
    ApplicationArea = All;
    Caption = 'ardFTPPushAPI';
    DelayedInsert = true;
    EntityName = 'ftpFile';
    EntitySetName = 'ftpFiles';
    PageType = API;
    SourceTable = ARD_PA_FTPPush;
    ODataKeyFields = SystemId;
    
    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(systemId; Rec.SystemId)
                {
                    Caption = 'System Id';
                }
                field(ardNo; Rec."ARD_No.")
                {
                    Caption = 'No.';
                }
                field(ardFileName; Rec.ARD_FileName)
                {
                    Caption = 'File Name';
                }
                field(ardFileContent; Rec.ARD_FileContent)
                {
                    Caption = 'File Content';
                }
                field(ardDateTime; Rec.ARD_DateTime)
                {
                    Caption = 'Date Time';
                }
            }
        }
    }
}
