# Page Creation Skill
---
name: page-creation
description: Guidance for creating AL pages in the File Import Examples project, including patterns, structures, and best practices.
---

## Overview
This skill provides guidance for creating Business Central AL pages for the File Import Examples project. It documents patterns, structures, and best practices observed from existing pages in the project.

## Page Types in Project

### 1. Import Pages (List)
**Purpose**: Main user interface for importing data files  
**Pattern**: ARDCustomerImport.Page.al, ARDSalesImport.Page.al

**Key Characteristics**:
- `PageType = List` with `SourceTable = [StagingTable]`
- `SourceTableTemporary = true` (data not immediately persisted)
- `UsageCategory = Tasks` (appears in search and role centers)
- Single data import text field for display
- Repeater section showing imported records
- Import action (file upload + parsing)
- Generate/Create action (transforms to business records)

**Basic Structure**:
```al
page 50XXX ARD_[Name]Import
{
    ApplicationArea = All;
    Caption = '[Descriptive Name] Import';
    PageType = List;
    SourceTable = ARD_[Name]Staging;
    SourceTableTemporary = true;
    UsageCategory = Tasks;

    layout
    {
        area(Content)
        {
            group(General)
            {
                field(ImportText; ImportText) { /* Display raw imported content */ }
            }
            repeater(Records)
            {
                // Field bindings to staging table
            }
        }
    }
    
    actions
    {
        area(Promoted) { /* Primary actions */ }
        area(Processing)
        {
            action(Import[Type])
            {
                trigger OnAction()
                {
                    // File upload, stream reading, parsing
                }
            }
            action(Generate[Records])
            {
                trigger OnAction()
                {
                    // Transform staging → business tables
                }
            }
        }
    }

    procedure Parse[Type]Data(importData: Text) { }
    procedure Generate[Records]() { }
    procedure RefreshPage() { }
}
```

### 2. List Pages
**Purpose**: Browse and manage imported data header records  
**Pattern**: ARDSalesImport.Page.al

**Key Characteristics**:
- Standalone list of header records
- Multiple import action variants (e.g., Normalized/Denormalized)
- `CardPageId` reference to detail card page
- Parse procedures for different data formats
- Supports both header-only and header-detail structures

### 3. Card Pages (Details)
**Purpose**: View and edit individual record details with line items  
**Pattern**: ARDSalesImportCard.Page.al

**Key Characteristics**:
- `PageType = Card`
- Header section with main record fields
- Subpage part (ListPart) for related lines/details
- `SubPageLink` to relate header to details
- Actions for business operations (e.g., CreateSalesOrder)

### 4. ListPart Pages
**Purpose**: Embedded repeater for showing related detail records  
**Pattern**: ARDSalesDetails.Page.al

**Key Characteristics**:
- `PageType = ListPart`
- Simple repeater with fields
- No actions (controlled by parent page)
- Linked to parent via SubPageLink on parent page

## Common Patterns

### File Import Pattern
```al
action(Import[Type])
{
    ApplicationArea = All;
    Caption = 'Import [Type]';
    Image = Import;
    ToolTip = 'Import [Description]';
    trigger OnAction()
    var
        FileFilter: Text;
        InStream: InStream;
        CurrentText: Text;
        TextValue: TextBuilder;
    begin
        FileFilter := 'Files (*.xxx)|*.xxx|All Files (*.*)|*.*';
        if UploadIntoStream(FileFilter, InStream) then
            while InStream.EOS = false do
                if InStream.ReadText(CurrentText) <> 0 then
                    TextValue.AppendLine(CurrentText);
        
        ImportText := TextValue.ToText();
        Parse[Format]Data(ImportText);
    end;
}
```

### Data Parsing Pattern
```al
procedure Parse[Format]Data(importData: Text)
var
    [RecordVariable]: Record "[TableName]";
    Lines: List of [Text];
    Line: Text;
    LineDetails: List of [Text];
    CRLF: Char;
begin
    CRLF := 10;
    Lines := importData.Split(CRLF);
    
    foreach Line in Lines do begin
        if StrLen(Line.Trim()) < 1 then continue;
        LineDetails := Line.Split('[Delimiter]');
        
        // Parse and create records
        [RecordVariable].Init();
        [RecordVariable].Field := CopyStr(LineDetails.Get(N), 1, MaxLength);
        [RecordVariable].Insert();
    end;
    RefreshPage();
end;
```

### Page Refresh Pattern
```al
procedure RefreshPage()
begin
    Rec.Reset();
    Rec.DeleteAll();
    TempRecord.SetFilter([FilterField], '<>0');
    if TempRecord.FindSet() then
        repeat
            Rec := TempRecord;
            Rec.Insert();
        until TempRecord.Next() = 0;
end;
```

## Field Naming Conventions

All project fields use **ARD_ prefix** (Aardvark Dynamics):
- `ARD_No.` - Record number (auto-increment)
- `ARD_CustomerNo.` - External reference number
- `ARD_ExtDocNo.` - External document number
- `ARD_HeaderNo.` - Link to header record
- `ARD_[EntityName]` - Data fields (e.g., ARD_Name, ARD_Quantity)

## Delimiters by Format

| Format | Delimiter | File Extension |
|--------|-----------|-----------------|
| CSV    | `,`       | `.csv`          |
| Normalized Text | `\|` (pipe) | `.txt` |
| Denormalized Text | `\|` (pipe) | `.txt` |
| JSON   | N/A (structured) | `.json` |
| XML    | N/A (structured) | `.xml` |

## Page ID Ranges

| Purpose | ID Range | Example |
|---------|----------|---------|
| Tables | 50000-50099 | ARD_CustomerStaging (50250) |
| Pages | 50000-50999 | ARD_CustomerImport (50000) |
| ListPart Subpages | 50XXX | ARD_SalesDetails (50007) |
| Card Detail Pages | 50XXX | ARD_SalesImportCard (50006) |

## Best Practices

1. **Temporary Tables**: Use `SourceTableTemporary = true` for staging/import pages
2. **Error Handling**: Validate line count/field count before parsing
3. **Data Validation**: Use `Evaluate()` for type conversions (Date, Decimal)
4. **Field Length**: Always use `CopyStr()` to match field lengths
5. **Import/Generate Pattern**: Separate import (file → staging) from generation (staging → business)
6. **Filtering**: Skip empty lines: `if StrLen(Line.Trim()) < 1 then continue;`
7. **User Feedback**: Display `ImportText` in group field for transparency
8. **Actions Layout**: Use `area(Promoted)` for primary actions, `area(Processing)` for secondary

## Related Tables

When creating a page, reference these key tables:
- **Staging Tables** (0 - Table folder):
  - `ARD_CustomerStaging` (CSV import)
  - `ARD_SalesHeader`, `ARD_SalesDetail` (sales data)
  - `ARD_Pet`, `ARD_PetOwner` (JSON)
  - `ARD_cXMLPOHeader`, `ARD_cXMLPOLine` (XML)

- **Business Tables**:
  - `Customer` (native)
  - `Sales Header`, `Sales Line` (native)
  - `Item` (native)

## Examples by Import Format

### CSV Import Page
- Use `,` delimiter
- Single header row to skip
- File filter: `'Files (*.csv)|*.csv'`

### Normalized Text Import Page
- Use `|` delimiter
- First field indicates record type ('H' for header, 'D' for detail)
- Handles related header-detail structures

### JSON Import Page
- Use JSON parsing library/methods
- Load entire file (typically smaller than text)

### XML Import Page
- Use XML parsing capabilities
- Handle element attributes and nested structures

## Testing Checklist

When creating a new page:
- [ ] Import action opens file dialog
- [ ] File upload reads complete content
- [ ] Parsing handles empty lines gracefully
- [ ] Field lengths validated with CopyStr()
- [ ] Type conversions protected with Evaluate()
- [ ] RefreshPage() displays all records
- [ ] Generate action creates business records
- [ ] Generated records link back to staging (e.g., ARD_CustomerNo.)
- [ ] Page displays in role center (UsageCategory = Tasks)
