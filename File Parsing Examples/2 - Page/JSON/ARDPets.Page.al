page 50002 ARD_Pets
{
    ApplicationArea = All;
    Caption = 'Pets';
    PageType = ListPart;
    SourceTable = ARD_Pet;
    
    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(ARD_Name; Rec.ARD_Name)
                {
                }
                field(ARD_Type; Rec.ARD_Type)
                {
                }
                field(ARD_Age; Rec.ARD_Age)
                {
                }
            }
        }
    }
}
