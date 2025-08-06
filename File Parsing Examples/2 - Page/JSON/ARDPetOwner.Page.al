page 50001 ARD_PetOwner
{
    ApplicationArea = All;
    Caption = 'Pet Owner';
    PageType = Card;
    SourceTable = ARD_PetOwner;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field(ARD_FirstName; Rec.ARD_FirstName)
                {
                }
                field(ARD_LastName; Rec.ARD_LastName)
                {
                }
                field(ARD_NoOPPets; Rec.ARD_NoOfPets)
                {
                }
            }
            group(Pets)
            {
                Caption = 'Pets';

                part(PetsPart; ARD_Pets)
                {
                    ApplicationArea = All;
                    Caption = 'Pets';
                    Visible = true;
                    SubPageLink = "ARD_OwnerNo" = field("ARD_No.");
                }
            }
        }
    }
    actions
    {
        area(Promoted)
        {
            actionref(ExportRef; Export)
            { }
        }
        area(Processing)
        {
            action(Export)
            {
                ApplicationArea = All;
                Caption = 'Export';
                Image = Export;
                ToolTip = 'Export the pet owner data to a file.';
                trigger OnAction()
                var
                    TempBLOB: Codeunit "Temp Blob"; // Temporary blob to store the JSON data
                    JSONText: BigText; // BigText variable to hold the JSON text
                    FileName: Text; // File name for the exported JSON file
                    InStr: InStream; // Input stream for downloading the file
                    OutStr: OutStream; // Output stream for writing the JSON data
                begin
                    // Generate the JSON text using the ExportPetOwner procedure
                    JSONText.AddText(ExportPetOwner(Rec));

                    // Construct the file name using the pet owner's first and last name
                    FileName := 'PetOwner_' + Format(Rec.ARD_FirstName) + '_' + Format(Rec.ARD_LastName) + '.json';

                    // Write the JSON text to the temporary blob
                    TempBLOB.CreateOutStream(OutStr);
                    JSONText.Write(OutStr);

                    // Create an input stream from the temporary blob and download the file
                    TempBLOB.CreateInStream(InStr);
                    DownloadFromStream(Instr, '', '', '', FileName);
                end;
            }
        }
    }

    procedure ExportPetOwner(var PetOwner: Record ARD_PetOwner): Text
    var
        PetRec: Record ARD_Pet; // Record variable for accessing pet details
        FileText: Text; // Text variable to store the resulting JSON
        JsonObject: JsonObject; // JSON object to represent the pet owner data
        JsonPetObject: JsonObject; // JSON object to represent individual pet details
        JsonArray: JsonArray; // JSON array to hold the list of pets
    begin
        // Add basic pet owner details to the JSON object
        JsonObject.add('firstName', PetOwner.ARD_FirstName);
        JsonObject.add('lastName', PetOwner.ARD_LastName);
        JsonObject.add('numberOfPets', PetOwner.ARD_NoOfPets);

        // Filter the pet records based on the owner number
        PetRec.SetFilter("ARD_OwnerNo", '%1', PetOwner."ARD_No.");
        if PetRec.FindSet() then begin
            repeat
                // Clear the JSON object for each pet and add pet details
                clear(JsonPetObject);
                JsonPetObject.Add('name', PetRec.ARD_Name);
                JsonPetObject.Add('type', PetRec.ARD_Type);
                JsonPetObject.Add('age', PetRec.ARD_Age);
                // Add the pet JSON object to the JSON array
                JsonArray.Add(JsonPetObject);
            until PetRec.Next() = 0;
            // Add the array of pet details to the main JSON object
            JsonObject.add('petDetails', JsonArray);
        end;

        // Write the JSON object to a text variable
        JsonObject.WriteTo(FileText);

        // Return the JSON text
        exit(FileText);
    end;
}
