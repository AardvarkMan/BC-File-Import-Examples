table 50001 ARD_Pet
{
    Caption = 'Pet';
    DataClassification = ToBeClassified;
    
    fields
    {
        field(1; "ARD_No."; Integer)
        {
            Caption = 'No.';
            ToolTip = 'Unique identifier for the pet.';
            AutoIncrement = true;
        }
        field(2; ARD_OwnerNo; Integer)
        {
            Caption = 'Owner No.';
            ToolTip = 'Unique identifier for the pet owner.';
        }
        field(3; ARD_Name; Text[255])
        {
            Caption = 'Name';
            ToolTip = 'Name of the pet.';
        }
        field(4; ARD_Type; Text[50])
        {
            Caption = 'Type';
            ToolTip = 'Type of the pet (e.g., Dog, Cat, etc.).';
        }
        field(5; ARD_Age; Integer)
        {
            Caption = 'Age';
            ToolTip = 'Age of the pet in years.';
        }
    }
    keys
    {
        key(PK; "ARD_No.", ARD_OwnerNo)
        {
            Clustered = true;
        }
    }
}
