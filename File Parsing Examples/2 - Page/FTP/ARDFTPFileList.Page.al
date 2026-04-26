namespace AardvarkLabs.FileParsingExamples;

using System.SFTPClient;

page 50013 ARD_FTPFileList
{
    ApplicationArea = All;
    Caption = 'FTP File List';
    PageType = ListPart;
    SourceTable = "SFTP Folder Content";
    
    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(Name; Rec.Name)
                {
                }
                field("Full Name"; Rec."Full Name")
                {
                }
                field(Length; Rec.Length)
                {
                }
                field("Is Directory"; Rec."Is Directory")
                {
                }
                field("Last Write Time"; Rec."Last Write Time")
                {
                }
            }
        }
    }
}
