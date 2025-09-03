page 50006 ARD_SalesImportCard
{
    ApplicationArea = All;
    Caption = 'Sales Import Card';
    PageType = Card;
    SourceTable = ARD_SalesHeader;
    
    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                
                field("ARD_No."; Rec."ARD_No.")
                {
                    Editable = false;
                }
                field("ARD_CustomerNo."; Rec."ARD_CustomerNo.")
                {
                }
                field(ARD_DocumentDate; Rec.ARD_DocumentDate)
                {
                }
                field("ARD_ExtDocNo."; Rec."ARD_ExtDocNo.")
                {
                }
                field("ARD_SalesHeaderNo."; Rec."ARD_SalesHeaderNo.")
                {
                    Editable = false;
                }
            }
            group(details)
            {
                Caption = 'Details';
                ShowCaption = false;
                part(ARD_SalesDetails; ARD_SalesDetails)
                {
                    SubPageLink = "ARD_HeaderNo." = field("ARD_No.");
                }
            }
        }
    }
    actions
    {
        area(Promoted)
        {
            actionref(CreateSalesOrderPM; CreateSalesOrder){}
        }
        area(processing)
        {
            action(CreateSalesOrder)
            {
                ApplicationArea = All;
                Caption = 'Create Sales Order';
                ToolTip = 'Create a sales order from the imported data.';
                Image = NewDocument;
                trigger OnAction()
                begin
                    Rec.CreateSalesOrder();
                end;
            }
        }
    }
}
