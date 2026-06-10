namespace AardvarkLabs.FileParsingExamples;

page 50014 ARD_FTPFiles
{
    ApplicationArea = All;
    Caption = 'FTP Files';
    PageType = List;
    SourceTable = ARD_PA_FTPPush;
    UsageCategory = Lists;
    cardPageId = "ARD_FTP File Card";
    
    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("ARD_No."; Rec."ARD_No.")
                {
                }
                field("ARD_FileName"; Rec.ARD_FileName)
                {
                }
                field(ARD_FileContent; Rec.ARD_FileContent)
                {
                }
                field(ARD_DateTime; Rec.ARD_DateTime)
                {
                }
            }
        }
    }
}
