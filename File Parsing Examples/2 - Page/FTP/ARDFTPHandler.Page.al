namespace AardvarkLabs.FileParsingExamples;

using System.SFTPClient;
using System.Utilities;

page 50012 ARD_FTPHandler
{
    ApplicationArea = All;
    Caption = 'FTP Handler';
    PageType = Card;
    SourceTable = "Integer";
    DataCaptionExpression = 'FTP Server Settings';
    UsageCategory = Administration;

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

    var
        ServerSettings: Codeunit ARD_SFTPServerSettings;
        UserName: Text;
        ServerHost: Text;
        ServerPort: Integer;
        ServerFingerPrint: text;
        ServerPassword: text;

    trigger OnOpenPage()
    begin
        //Load the current server settings from the Isolated Storage when opening the page.
        ServerHost := ServerSettings.GetServerHost();
        ServerPort := ServerSettings.GetServerPort();
        ServerFingerPrint := ServerSettings.GetServerFingerPrint();
        UserName := ServerSettings.GetServerUserName();
    end;


    
}
