namespace AardvarkLabs.FileParsingExamples;
using Microsoft.Purchases.Vendor;
using System.Xml;
using System.IO;
page 50009 ARD_xmlPOImport
{
    ApplicationArea = All;
    Caption = 'xml PO Import';
    PageType = List;
    SourceTable = ARD_cXMLPOHeader;
    UsageCategory = Lists;
    CardPageId = ARD_XMLPOCard;
    
    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("ARD_No."; Rec."ARD_No.")
                {
                }
                field(ARD_VendorName; Rec.ARD_VendorName)
                {
                }
                field("ARD_VendorNo."; Rec."ARD_VendorNo.")
                {
                }
                field(ARD_DocumentNo; Rec.ARD_DocumentNo)
                {
                }
            }
        }
    }
    actions
    {
        area(Promoted)
        {
            actionref(ARImportXML; ImportXML)
            {
            }
        }
        area(processing)
        {

            action(ImportXML)
            {
                ApplicationArea = All;
                Caption = 'Import XML';
                Image = Import;
                ToolTip = 'Import Purchase Orders from an XML file.';
                trigger OnAction()
                begin
                    ImportXMLFile();
                end;
            }
        }
    }

    procedure ImportXMLFile()
    var
        FileFilter: Text; // Defines the file filter for the upload dialog
        InStream: InStream; // Stream to read the uploaded file
        CurrentText: Text; // Temporary variable to hold the current line of text
        TextValue: TextBuilder; // TextBuilder to accumulate the file content
        FileText: Text; // Final text content of the uploaded file
    begin
        // Set the file filter to allow XML files
        FileFilter := 'XML Files (*.xml)|*.xml|All Files (*.*)|*.*';

        // Open a dialog to upload a file and read its content into a stream
        if UploadIntoStream(FileFilter, InStream) then
            // Read the stream line by line until the end of the stream
            while InStream.EOS = false do
                // Append each line of text to the TextBuilder
                if InStream.ReadText(CurrentText) <> 0 then
                    TextValue.AppendLine(CurrentText);

        // Convert the accumulated text into a single string
        FileText := TextValue.ToText();

        // Trim the text and pass it to the ParseXML procedure for processing
        ParseXML(FileText.Trim());
    end;

    procedure ParseXML(FileText: Text)
    var
        DocHeader: Record ARD_cXMLPOHeader;
        DocLine: Record ARD_cXMLPOLine;
        VendorRec: Record Vendor;
        // XML handling variables
        XmlDoc: XmlDocument;
        XmlNodeList: XmlNodeList;
        XmlNode: XmlNode;
        // Nodes for ItemOut processing
        ItemOutNode: XmlNode;
        ItemOutNodeList: XmlNodeList;
        // Nodes for ItemID processing
        ItemIdNodeList: XmlNodeList;
        ItemIdNode: XmlNode;
        // Nodes for ItemDetail processing
        ItemDetailNode: XmlNode;
        ItemDetailNodeList: XmlNodeList;
        // Nodes for UnitPrice processing
        UnitPriceNode: XmlNode;
        UnitPriceNodeList: XmlNodeList;
        // XML attribute handling variables
        xmlAttribute: XmlAttribute;
        xmlAttributes: XmlAttributeCollection;
        xmlElement: XmlElement;

        xmlName: text;
        VendorId: Text;
        tempText: Text;
    begin
        XMLDocument.ReadFrom(FileText, XmlDoc);

        //Locate the From Identity so that we can extract the Vendor ID
        XmlDoc.SelectNodes('//cXML//Header//From//Credential//Identity', XmlNodeList);
        if XmlNodeList.Count = 0 then
            error('File does not appear to be a valid cXML file.');

        XmlNodeList.Get(1, XmlNode);
        VendorId := XmlNode.AsXmlElement().InnerText;
        if not VendorRec.Get(VendorId) then
            error('Vendor with ID %1 not found.', VendorId);

        // Initialize and insert header record
        DocHeader.Init();
        DocHeader."ARD_No." := 0;
        DocHeader."ARD_VendorNo." := VendorRec."No.";
        DocHeader.ARD_VendorName := VendorRec.Name;

        // Process Header Information from the OrderRequestHeader Attributes
        XmlDoc.SelectNodes('//cXML//Request//OrderRequest//OrderRequestHeader', XmlNodeList);
        if XmlNodeList.Count = 0 then
            error('File does not appear to be a valid cXML Order Request file.');

        foreach XmlNode in XmlNodeList do begin
            xmlName := XmlNode.AsXmlElement().Name;

            xmlAttributes := XmlNode.AsXmlElement().Attributes();
            foreach xmlAttribute in xmlAttributes do begin
                tempText := xmlAttribute.Value;

                case xmlAttribute.Name of
                    'orderDate':
                        Evaluate(DocHeader.ARD_OrderDate, tempText);
                    'orderID':
                        DocHeader.ARD_DocumentNo := CopyStr(tempText, 1, 20);
                end;
            end;
        end;

        DocHeader.Insert(true);

        //Now for lines
        XmlDoc.SelectNodes('//cXML//Request//OrderRequest//ItemOut', XmlNodeList);
        if XmlNodeList.Count = 0 then
            error('File does not appear to contain any line items.');

        foreach XmlNode in XmlNodeList do begin
            DocLine.Init();
            DocLine.ARD_HeaderNo := DocHeader."ARD_No.";

            xmlAttributes := XmlNode.AsXmlElement().Attributes();

            //Parse the Attributes from the ItemOut for the Quantity and line number
            foreach xmlAttribute in xmlAttributes do begin
                tempText := xmlAttribute.Value;
                case xmlAttribute.Name of
                    'quantity':
                        Evaluate(DocLine."ARD_Quantity", tempText);
                    'lineNumber':
                        Evaluate(DocLine."ARD_Line Number", tempText);
                end;
            end;

            // Now process child nodes for this ItemOut
            xmlElement := XmlNode.AsXmlElement();
            ItemOutNodeList := xmlElement.GetChildElements();
            foreach ItemOutNode in ItemOutNodeList do begin
                xmlName := ItemOutNode.AsXmlElement().Name;
                case xmlName of
                    'ItemID':
                        begin
                            // Get Supplier Part ID
                            ItemIdNodeList := ItemOutNode.AsXmlElement().GetChildElements();
                            foreach ItemIdNode in ItemIdNodeList do
                                if ItemIdNode.AsXmlElement().Name = 'SupplierPartID' then
                                    DocLine."ARD_Supplier Part ID" := CopyStr(ItemIdNode.AsXmlElement().InnerText, 1, 50);
                        end;
                    'ItemDetail':
                        begin
                            // Process ItemDetail child nodes
                            ItemDetailNodeList := ItemOutNode.AsXmlElement().GetChildElements();
                            foreach ItemDetailNode in ItemDetailNodeList do begin
                                xmlName := ItemDetailNode.AsXmlElement().Name;
                                case xmlName of
                                    'Description':
                                        DocLine."ARD_Description" := CopyStr(ItemDetailNode.AsXmlElement().InnerText, 1, 100);
                                    'UnitPrice':
                                        begin
                                            // Get Money child node for Unit Price and Currency
                                            UnitPriceNodeList := ItemDetailNode.AsXmlElement().GetChildElements();
                                            foreach UnitPriceNode in UnitPriceNodeList do
                                                if UnitPriceNode.AsXmlElement().Name = 'Money' then begin
                                                    xmlAttributes := UnitPriceNode.AsXmlElement().Attributes();
                                                    foreach xmlAttribute in xmlAttributes do
                                                        if xmlAttribute.Name = 'currency' then
                                                            DocLine."ARD_Currency" := CopyStr(xmlAttribute.Value, 1, 3);
                                                    Evaluate(DocLine."ARD_Unit Price", UnitPriceNode.AsXmlElement().InnerText);
                                                end;
                                        end;
                                    'UnitOfMeasure':
                                        DocLine."ARD_Unit of Measure" := CopyStr(ItemDetailNode.AsXmlElement().InnerText, 1, 10);
                                end;
                            end;
                        end;
                end;
            end;
            DocLine.Insert(true);
        end;
    end;
}
