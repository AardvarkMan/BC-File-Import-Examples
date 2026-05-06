namespace AardvarkLabs.FileParsingExamples;

codeunit 50000 ARD_SFTPServerSettings
{
    Access = Internal;

    var
        FTPServerUserNameLbl: Label 'FTPServerUserNAme';
        FTPServerPasswordLbl: Label 'FTPServerPassword';
        FTPServerHostLbl: Label 'FTPServerHost';
        FTPServerPortLbl: Label 'FTPServerPort';
        FTPServerFingerPrintLbl: Label 'FTPServerFingerPrint';

    procedure GetServerUserName():Text
    var
        value: Text;
    begin
        IsolatedStorage.get(FTPServerUserNameLbl, value);
        exit(value);
    end;    

    procedure SetServerUserName(value: Text)
    begin
        IsolatedStorage.set(FTPServerUserNameLbl, value);
    end;

    procedure GetServerPassword():SecretText
    var
        value: SecretText;
    begin
        if NOT IsolatedStorage.get(FTPServerPasswordLbl, value) then value := SecretStrSubstNo('');
        exit(value);
    end;

    procedure SetServerPassword(value: SecretText)
    begin
        IsolatedStorage.set(FTPServerPasswordLbl, value);
    end;

    procedure GetServerHost():Text
    var
        value: Text;
    begin
        IsolatedStorage.get(FTPServerHostLbl, value);
        exit(value);
    end;

    procedure SetServerHost(value: Text)
    begin
        IsolatedStorage.set(FTPServerHostLbl, value);
    end;    

    procedure GetServerPort():Integer
    var
        value: Integer;
        TextValue: Text;
    begin
        IsolatedStorage.get(FTPServerPortLbl, TextValue);
        if TextValue = '' then
            value := 0
        else
            Evaluate(Value, TextValue);
        exit(value);
    end;

    procedure SetServerPort(value: Integer)
    var
        TextValue: Text;
    begin
        TextValue := Format(value);
        IsolatedStorage.set(FTPServerPortLbl, TextValue);
    end;

    procedure GetServerFingerPrint():text
    var
        value: text;
    begin
        if NOT IsolatedStorage.get(FTPServerFingerPrintLbl, value) then value := '';
        exit(value);
    end;

    procedure SetServerFingerPrint(value: text)
    begin
        IsolatedStorage.set(FTPServerFingerPrintLbl, value);
    end;
}