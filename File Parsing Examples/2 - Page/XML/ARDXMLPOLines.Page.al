namespace AardvarkLabs.FileParsingExamples;

page 50011 ARD_XMLPOLines
{
    ApplicationArea = All;
    Caption = 'XML PO Lines';
    PageType = ListPart;
    SourceTable = ARD_cXMLPOLine;
    
    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("ARD_Supplier Part ID"; Rec."ARD_Supplier Part ID")
                {
                }
                field(ARD_Description; Rec.ARD_Description)
                {
                }
                field(ARD_Quantity; Rec.ARD_Quantity)
                {
                }
                field("ARD_Unit Price"; Rec."ARD_Unit Price")
                {
                }
                field("ARD_Unit of Measure"; Rec."ARD_Unit of Measure")
                {
                }
                field(ARD_Currency; Rec.ARD_Currency)
                {
                }
            }
        }
    }
}
