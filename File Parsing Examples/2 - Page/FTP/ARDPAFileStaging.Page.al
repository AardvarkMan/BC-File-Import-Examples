namespace AardvarkLabs.FileParsingExamples;

page 50017 ARD_PAFileStaging
{
    ApplicationArea = All;
    Caption = 'PA File Staging';
    PageType = List;
    SourceTable = ARD_PAFTPSend;
    UsageCategory = Lists;
    
    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("ARD_No."; Rec."ARD_No.")
                {
                }
                field(ARD_InvoiceFIleName; Rec.ARD_InvoiceFileName)
                {
                }
                field(ARD_GeneratedDate; Rec.ARD_GeneratedDate)
                {
                }
                field(ARD_Handled; Rec.ARD_Handled)
                {
                }
                field(ARD_HandledDateTime; Rec.ARD_HandledDateTime)
                {
                }
            }
        }
    }
}
