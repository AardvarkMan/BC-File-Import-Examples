namespace AardvarkLabs.FileParsingExamples;

using Microsoft.Shared.Report;

pageextension 50000 ARD_ReportLayouts extends "Report Layouts"
{
    actions
    {
        Addafter(RunReport)
        {
            action(ARD_ReportXML)
            {
                ApplicationArea = All;
                Caption = 'Get Report XML';
                tooltip = 'Get the XML of the report layout.';
                Image = Export;

                trigger OnAction()
                var
                    ReportParameterXML: Text;
                begin
                    ReportParameterXML := report.RunRequestPage(rec."Report ID");
                    Message(ReportParameterXML);
                end;
            }
        }

    }
}
