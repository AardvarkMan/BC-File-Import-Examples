namespace AardvarkLabs.FileParsingExamples;

page 50016 "ARD_FTP File Card"
{
    ApplicationArea = All;
    Caption = 'FTP File Card';
    PageType = Card;
    SourceTable = ARD_PA_FTPPush;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field("ARD_No."; Rec."ARD_No.")
                {
                }
                field(ARD_FileName; Rec.ARD_FileName)
                {
                }
                field(ARD_DateTime; Rec.ARD_DateTime)
                {
                }
            }
            group(FileContent)
            {
                field(FileText; GetFileText())
                {
                    Caption = 'File Content';
                    tooltip = 'Content of the file pushed to FTP.';
                    multiline = true;
                }

            }
        }
    }

    procedure GetFileText(): TEXT
    var
        inStream: InStream;
        FileContent: Text;
    begin
        Clear(FileContent);
        Rec.CalcFields(ARD_FileContent);
        if Rec.ARD_FileContent.HasValue() then begin
            Rec.ARD_FileContent.CreateInStream(inStream, TEXTENCODING::UTF8);
            InStream.Read(FileContent);
        end;

        exit(FileContent);
    end;
}
