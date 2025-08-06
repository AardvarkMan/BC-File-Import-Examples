page 50003 ARD_PetOwners
{
    ApplicationArea = All;
    Caption = 'Pet Owners';
    PageType = List;
    SourceTable = ARD_PetOwner;
    UsageCategory = Documents;
    CardPageId = ARD_PetOwner;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("ARD_No."; Rec."ARD_No.")
                {
                }
                field(ARD_FirstName; Rec.ARD_FirstName)
                {
                }
                field(ARD_LastName; Rec.ARD_LastName)
                {
                }
            }
        }
    }
    actions
    {
        area(promoted)
        {
            actionref(ImportRef; Import)
            { }
        }
        area(Processing)
        {
            action(Import)
            {
                ApplicationArea = All;
                Caption = 'Import';
                Image = Import;
                ToolTip = 'Import pet owners from a file.';
                trigger OnAction()
                var
                    FileFilter: Text; // Defines the file filter for the upload dialog
                    InStream: InStream; // Stream to read the uploaded file
                    CurrentText: Text; // Temporary variable to hold the current line of text
                    TextValue: TextBuilder; // TextBuilder to accumulate the file content
                    FileText: Text; // Final text content of the uploaded file
                begin
                    // Set the file filter to allow all file types
                    FileFilter := 'All Files (*.*)|*.*';

                    // Open a dialog to upload a file and read its content into a stream
                    if UploadIntoStream(FileFilter, InStream) then
                        // Read the stream line by line until the end of the stream
                        while InStream.EOS = false do
                            // Append each line of text to the TextBuilder
                            if InStream.ReadText(CurrentText) <> 0 then
                                TextValue.AppendLine(CurrentText);

                    // Convert the accumulated text into a single string
                    FileText := TextValue.ToText();

                    // Trim the text and pass it to the ParseJSON procedure for processing
                    ParseJSON(FileText.Trim());
                end;
            }
        }
    }

    procedure ParseJSON(FileText: Text)
    var
        PetOwner: Record ARD_PetOwner; // Record for storing pet owner details
        Pet: Record ARD_Pet; // Record for storing pet details
        JsonToken: JsonToken; // Token used to iterate through JSON array
        JsonObject: JsonObject; // JSON object representing the root of the JSON structure
        JsonPetObject: JsonObject; // JSON object representing individual pet details
        JsonArray: JsonArray; // JSON array containing pet details
        FirstName: Text; // Variable to store the first name of the pet owner
        LastName: Text; // Variable to store the last name of the pet owner
        NumberOfPets: Integer; // Variable to store the number of pets
        PetType: Text; // Variable to store the type of the pet
        PetName: Text; // Variable to store the name of the pet
        PetAge: Integer; // Variable to store the age of the pet
    begin
        // Read the text into a JSON Object and validate the format
        if JsonObject.ReadFrom(FileText) = false then
            Error('Invalid JSON format.');

        // Extract pet owner details from the JSON object
        FirstName := JsonObject.GetText('firstName');
        LastName := JsonObject.GetText('lastName');
        NumberOfPets := JsonObject.GetInteger('numberOfPets');

        // Initialize and insert a new record for the pet owner
        PetOwner.Init();
        PetOwner."ARD_No." := 0; // Auto-incremented field, set to 0 for new record
        PetOwner."ARD_FirstName" := CopyStr(FirstName, 1, 255); // Copy first name with max length 255
        PetOwner."ARD_LastName" := CopyStr(LastName, 1, 255); // Copy last name with max length 255
        PetOwner.ARD_NoOfPets := NumberOfPets; // Set the number of pets

        // Insert the pet owner record into the database
        if PetOwner.Insert() then begin
            // Extract the array of pet details from the JSON object
            JsonArray := JsonObject.GetArray('petDetails');
            foreach JsonToken in JsonArray do begin
                // Convert each token into a JSON object representing a pet
                JsonPetObject := JsonToken.AsObject();
                PetType := JsonPetObject.GetText('type'); // Extract pet type
                PetName := JsonPetObject.GetText('name'); // Extract pet name
                PetAge := JsonPetObject.GetInteger('age'); // Extract pet age

                // Initialize and insert a new record for the pet
                Pet.Init();
                Pet."ARD_No." := 0; // Auto-incremented field, set to 0 for new record
                Pet.ARD_OwnerNo := PetOwner."ARD_No."; // Link pet to the owner
                Pet.ARD_Type := CopyStr(PetType, 1, 50); // Copy pet type with max length 50
                Pet.ARD_Name := CopyStr(PetName, 1, 255); // Copy pet name with max length 255
                Pet.ARD_Age := PetAge; // Set pet age
                Pet.Insert(); // Insert the pet record into the database
            end;
        end;
    end;
}
