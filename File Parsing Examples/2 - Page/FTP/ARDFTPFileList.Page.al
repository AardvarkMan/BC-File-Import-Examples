namespace AardvarkLabs.FileParsingExamples;

using System.SFTPClient;

page 50013 ARD_FTPFileList
{
    ApplicationArea = All;
    Caption = 'FTP File List';
    PageType = ListPart;
    SourceTable = "SFTP Folder Content";
    InsertAllowed = true;

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
                    trigger OnDrillDown()
                    begin
                        if Rec."Is Directory" then begin
                            case Rec.Name of
                                '.': //return to the root
                                    currentPath := '';
                                '..': //go up one level
                                    currentPath := CopyStr(currentPath, 1, currentPath.lastindexof('/') - 1);
                                else //go down one level
                                    currentPath := Rec."Full Name";

                            end;
                            
                            //List the files at the new level
                            ListFTPFiles();
                        end else
                            DownloadFTPFile(Rec."Full Name"); //Download the file that was clicked on
                    end;
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
            
            group(Upload)
            {
                Caption = 'Upload File';
                field(UploadFileName; UploadFileName)
                {
                    ApplicationArea = All;
                    Caption = 'File Name';
                    ToolTip = 'The name of the file to be uploaded to the FTP server.';

                    trigger OnValidate()
                    begin
                        UploadFTPFile(UploadFileName);
                    end;
                }
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action(ListFiles)
            {
                ApplicationArea = All;
                Caption = 'List Files';
                ToolTip = 'Lists the files in the root directory of the FTP server.';
                image = View;
                trigger OnAction()
                begin
                    ListFTPFiles();
                end;
            }
            action(DeleteFile)
            {
                ApplicationArea = All;
                Caption = 'Delete File';
                ToolTip = 'Deletes a file called data.txt from the root directory of the FTP server.';
                image = Delete;
                Scope = Repeater;

                trigger OnAction()
                begin
                    if (NOT Rec."Is Directory") and (Rec."Full Name" <> '') then
                        if Confirm('Are you sure you want to delete ' + Rec.Name + '?', false) then
                            DeleteFTPFile(Rec."Full Name");
                end;
            }
        }
    }

    var
        ServerSettings: Codeunit ARD_SFTPServerSettings;
        currentPath: Text;
        UploadFileName: Text;

    trigger OnOpenPage()
    begin
        currentPath := '';
    end;

    procedure ListFTPFiles()
    var
        TempFileList: Record "SFTP Folder Content" temporary;
        SFTPClient: Codeunit "SFTP Client";
    begin
        Rec.DeleteAll();

        //Setting up the client from the values in the Isolated Storage.
        SFTPClient.AddFingerPrintSHA256(ServerSettings.GetServerFingerPrint());
        SFTPClient.Initialize(ServerSettings.GetServerHost(), ServerSettings.GetServerPort(), ServerSettings.GetServerUserName(), ServerSettings.GetServerPassword());

        //Disconnect when complete or if there is an error.
        SFTPClient.ListFiles(currentPath, TempFileList);

        //Insert the files from the temporary record into the page's record to display them in the list.
        if TempFileList.FindSet() then
            repeat
                Rec := TempFileList;
                Rec.Insert();
            until TempFileList.Next() = 0
        else
            Message('No files found in the root directory of the FTP server.');

        CurrPage.Update(false);

        //Disconnect when complete or if there is an error.
        SFTPClient.Disconnect();
    end;

    procedure UploadFTPFile(FileName: Text)
    var
        SFTPClient: Codeunit "SFTP Client";
        InStream: InStream;
    begin
        if UploadIntoStream('', InStream) then begin
            //Setting up the client from the values in the Isolated Storage.
            SFTPClient.AddFingerPrintSHA256(ServerSettings.GetServerFingerPrint());
            SFTPClient.Initialize(ServerSettings.GetServerHost(), ServerSettings.GetServerPort(), ServerSettings.GetServerUserName(), ServerSettings.GetServerPassword());

            //Upload the file to the FTP server using the provided filename and filestream.
            SFTPClient.PutFileStream(FileName, InStream);
            //Disconnect when complete or if there is an error.
            SFTPClient.Disconnect();
        end else
            Message('File upload cancelled.');
    end;

    procedure DownloadFTPFile(FullFileName: Text)
    var
        SFTPClient: Codeunit "SFTP Client";
        InStream: InStream;
        FileContent: TextBuilder;
        CurrentText: Text;
    begin
        //Setting up the client from the values in the Isolated Storage.
        SFTPClient.AddFingerPrintSHA256(ServerSettings.GetServerFingerPrint());
        SFTPClient.Initialize(ServerSettings.GetServerHost(), ServerSettings.GetServerPort(), ServerSettings.GetServerUserName(), ServerSettings.GetServerPassword());

        //Download the file from the FTP server into a filestream.
        SFTPClient.GetFileAsStream(FullFileName, InStream);
        //Disconnect when complete or if there is an error.
        SFTPClient.Disconnect();

        while InStream.EOS = false do
            // Append each line of text to the TextBuilder
            if InStream.ReadText(CurrentText) <> 0 then
                FileContent.AppendLine(CurrentText);

        Dialog.Message(FileContent.ToText());
    end;

    procedure DeleteFTPFile(FullFileName: Text)
    var
        SFTPClient: Codeunit "SFTP Client";
    begin
        //Setting up the client from the values in the Isolated Storage.
        SFTPClient.AddFingerPrintSHA256(ServerSettings.GetServerFingerPrint());
        SFTPClient.Initialize(ServerSettings.GetServerHost(), ServerSettings.GetServerPort(), ServerSettings.GetServerUserName(), ServerSettings.GetServerPassword());

        //Delete the file from the FTP server using the provided filename.
        SFTPClient.DeleteFile(FullFileName);
        //Disconnect when complete or if there is an error.
        SFTPClient.Disconnect();
    end;
}
