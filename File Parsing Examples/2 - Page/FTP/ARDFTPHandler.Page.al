namespace AardvarkLabs.FileParsingExamples;

using System.SFTPClient;
using System.Utilities;

page 50012 ARD_FTPHandler
{
    ApplicationArea = All;
    Caption = 'FTP Handler';
    PageType = Card;
    SourceTable = "Integer";

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'Server Settings';
                field(ServerHost; ServerHost)
                {
                    Caption = 'Server Host';
                    ToolTip = 'The hostname or IP address of the FTP server.';
                    ApplicationArea = All;

                    trigger onvalidatE()
                    begin
                        ServerSettings.SetServerHost(ServerHost);
                    end;
                }
                field(ServerPort; ServerPort)
                {
                    Caption = 'Server Port';
                    ToolTip = 'The port number of the FTP server.';
                    ApplicationArea = All;
                    trigger OnValidate()
                    begin
                        ServerSettings.SetServerPort(ServerPort);
                    end;
                }
                field(ServerFingerPrint; ServerFingerPrint)
                {
                    ApplicationArea = All;
                    Caption = 'Server FingerPrint';
                    ToolTip = 'The SSH Fingerprint of the FTP server.';
                    MaskType = Concealed;
                    trigger OnValidate()
                    begin
                        ServerSettings.SetServerFingerPrint(ServerFingerPrint);
                    end;
                }
                field(UserName; UserName)
                {
                    ApplicationArea = All;
                    Caption = 'Server User Name';
                    ToolTip = 'The username for the FTP server.';
                    trigger OnValidate()
                    begin
                        ServerSettings.SetServerUserName(UserName);
                    end;

                }
                field(ServerPassword; ServerPassword)
                {
                    ApplicationArea = All;
                    Caption = 'Server Password';
                    ToolTip = 'The password for the FTP server.';
                    MaskType = Concealed;
                    trigger OnValidate()
                    begin
                        ServerSettings.SetServerPassword(ServerPassword);
                    end;
                }
            }
            group(Files)
            {
                part(FileList; ARD_FTPFileList)
                {
                    ApplicationArea = All;
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
            action(UploadFile)
            {
                ApplicationArea = All;
                Caption = 'Upload File';
                ToolTip = 'Uploads a file called data.txt to the root directory of the FTP server.';
                image = Create;
                trigger OnAction()
                begin
                    UploadFTPFile();
                end;
            }
            action(DownloadFile)
            {
                ApplicationArea = All;
                Caption = 'Download File';
                ToolTip = 'Downloads a file called data.txt from the root directory of the FTP server.';
                image = Download;
                trigger OnAction()
                begin
                    DownloadFTPFile();
                end;
            }
            action(DeleteFile)
            {
                ApplicationArea = All;
                Caption = 'Delete File';
                ToolTip = 'Deletes a file called data.txt from the root directory of the FTP server.';
                image = Delete;
                trigger OnAction()
                begin
                    DeleteFTPFile();
                end;
            }
        }
    }

    var
        ServerSettings: Codeunit ARD_SFTPServerSettings;
        UserName: Text;
        ServerHost: Text;
        ServerPort: Integer;
        ServerFingerPrint: text;
        ServerPassword: text;


    local procedure ListFTPFiles()
    var
        TempFileList: Record "SFTP Folder Content" temporary;
        SFTPClient: Codeunit "SFTP Client";
    begin
        //Setting up the client from the values in the Isolated Storage.
        SFTPClient.AddFingerPrintSHA256(ServerSettings.GetServerFingerPrint());
        SFTPClient.Initialize(ServerSettings.GetServerHost(), ServerSettings.GetServerPort(), ServerSettings.GetServerUserName(), ServerSettings.GetServerPassword());

        SFTPClient.ListFiles('', TempFileList);

        if TempFileList.FindSet() then
            repeat
                TempFileList.Insert();
            until TempFileList.Next() = 0;

        SFTPClient.Disconnect();
    end;

    local procedure UploadFTPFile()
    var
        SFTPClient: Codeunit "SFTP Client";
        InStream: InStream;
    begin
        //Setting up the client from the values in the Isolated Storage.
        SFTPClient.AddFingerPrintSHA256(ServerSettings.GetServerFingerPrint());
        SFTPClient.Initialize(ServerSettings.GetServerHost(), ServerSettings.GetServerPort(), ServerSettings.GetServerUserName(), ServerSettings.GetServerPassword());

        UploadIntoStream('', InStream);
        SFTPClient.PutFileStream('data.txt', InStream);
        SFTPClient.Disconnect();
    end;

    local procedure DownloadFTPFile()
    begin

    end;

    local procedure DeleteFTPFile()
    begin

    end;
}
