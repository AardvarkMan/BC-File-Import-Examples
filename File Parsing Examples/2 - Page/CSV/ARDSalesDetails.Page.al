page 50007 ARD_SalesDetails
{
    ApplicationArea = All;
    Caption = 'Sales Details';
    PageType = ListPart;
    SourceTable = ARD_SalesDetail;
    
    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("ARD_No."; Rec."ARD_No.")
                {
                }
                field("ARD_ItemNo."; Rec."ARD_ItemNo.")
                {
                }
                field(ARD_Quantity; Rec.ARD_Quantity)
                {
                }
                field(ARD_UoM; Rec.ARD_UoM)
                {
                }
                field(ARD_SalesLineNo; Rec.ARD_SalesLineNo)
                {
                }
            }
        }
    }
}
