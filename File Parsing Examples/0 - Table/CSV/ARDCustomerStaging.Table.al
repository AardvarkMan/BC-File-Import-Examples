table 50000 ARD_CustomerStaging
{
    Caption = 'Customer Staging';
    DataClassification = CustomerContent;
    TableType = Temporary;

    fields
    {
        field(1; "ARD_No."; Integer)
        {
            Caption = 'No.';
            ToolTip = 'Unique identifier for the customer.';
        }
        field(2; ARD_Name; Text[100])
        {
            Caption = 'Name';
            ToolTip = 'The name of the customer.';
        }
        field(3; ARD_AddressLine1; Text[100])
        {
            Caption = 'Address Line 1';
            ToolTip = 'The first line of the customer''s address.';
        }
        field(4; ARD_AddressLine2; Text[50])
        {
            Caption = 'Address Line 2';
            ToolTip = 'The second line of the customer''s address, if applicable.';
        }
        field(5; ARD_City; Text[30])
        {
            Caption = 'City';
            ToolTip = 'The city where the customer is located.';
        }
        field(6; ARD_State; Text[30])
        {
            Caption = 'State';
            ToolTip = 'The state or region of the customer''s address.';
        }
        field(7; ARD_PostalCode; Text[20])
        {
            Caption = 'Postal Code';
            ToolTip = 'The postal code for the customer''s address.';
        }
        field(8; ARD_ContactEmail; Text[80])
        {
            Caption = 'Contact Email';
            ToolTip = 'The email address for contacting the customer.';
        }
        field(9; ARD_CreditLimit; Decimal)
        {
            Caption = 'Credit Limit';
            ToolTip = 'The credit limit assigned to the customer.';
        }
        field(10; ARD_CustomerNo; Code[20])
        {
            Caption = 'Customer No.';
            ToolTip = 'The unique customer number assigned to the customer.';
        }
    }
    keys
    {
        key(PK; "ARD_No.")
        {
            Clustered = true;
        }
    }
}
