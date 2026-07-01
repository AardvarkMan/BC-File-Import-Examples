namespace AardvarkLabs.FileParsingExamples;

page 50018 ARD_PAFileStagingAPI
{
    APIGroup = 'aardvarkLabs';
    APIPublisher = 'aardvarkLabs';
    APIVersion = 'v1.0';
    ApplicationArea = All;
    Caption = 'ardPAFileStagingAPI';
    DelayedInsert = true;
    EntityName = 'ftpStage';
    EntitySetName = 'ftpStaging';
    PageType = API;
    SourceTable = ARD_PAFTPSend;
    ODataKeyFields = SystemId;
    
    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(systemId; Rec.SystemId)
                {
                    Caption = 'SystemId';
                }
                field(ardNo; Rec."ARD_No.")
                {
                    Caption = 'No.';
                }
                field(ardInvoiceFileName; Rec.ARD_InvoiceFileName)
                {
                    Caption = 'Invoice File Name';
                }
                field(ardGeneratedDate; Rec.ARD_GeneratedDate)
                {
                    Caption = 'Generated Date';
                }
                field(ardHandled; Rec.ARD_Handled)
                {
                    Caption = 'Handled';
                }
                field(ardHandledDateTime; Rec.ARD_HandledDateTime)
                {
                    Caption = 'Handled Date Time';
                }
                field(ardInvoice; Rec.ARD_Invoice)
                {
                    Caption = 'Invoice';
                }
            }
        }
    }
}
