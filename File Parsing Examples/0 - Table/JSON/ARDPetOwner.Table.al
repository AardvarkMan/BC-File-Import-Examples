table 50002 ARD_PetOwner
{
    Caption = 'Pet Owner';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "ARD_No."; Integer)
        {
            Caption = 'No.';
            ToolTip = 'Unique identifier for the pet owner.';
            AutoIncrement = true;
        }
        field(2; ARD_FirstName; Text[255])
        {
            Caption = 'First Name';
            ToolTip = 'First name of the pet owner.';
        }
        field(3; ARD_LastName; Text[255])
        {
            Caption = 'Last Name';
            ToolTip = 'Last name of the pet owner.';
        }
        field(4; ARD_NoOfPets; Integer)
        {
            Caption = 'No OP Pets';
            ToolTip = 'Number of pets owned by the owner.';
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
