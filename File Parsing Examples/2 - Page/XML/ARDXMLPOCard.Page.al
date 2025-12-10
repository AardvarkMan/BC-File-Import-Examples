namespace AardvarkLabs.FileParsingExamples;

page 50010 ARD_XMLPOCard
{
    ApplicationArea = All;
    Caption = 'XML PO Card';
    PageType = Card;
    SourceTable = ARD_cXMLPOHeader;

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
                field(ARD_DocumentNo; Rec.ARD_DocumentNo)
                {
                }
                field(ARD_OrderDate; Rec.ARD_OrderDate)
                {
                }
                field(ARD_VendorName; Rec.ARD_VendorName)
                {
                }
                field("ARD_VendorNo."; Rec."ARD_VendorNo.")
                {
                }
            }
            part(ARD_XMLPOLines; ARD_XMLPOLines)
            {
                ApplicationArea = All;
                SubPageLink = ARD_HeaderNo = FIELD("ARD_No.");
            }
        }
    }
}
