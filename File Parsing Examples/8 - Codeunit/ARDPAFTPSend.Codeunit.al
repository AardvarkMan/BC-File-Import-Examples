namespace AardvarkLabs.FileParsingExamples;

using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Foundation.Reporting;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using Microsoft.Sales.Posting;
using Microsoft.Sales.Receivables;
using System.Integration;

codeunit 50001 ARD_PAFTPSend
{
    var
        EventCategory: Enum "EventCategory";

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", OnAfterPostSalesDoc, '', false, false)]
    local procedure "Sales-Post_OnAfterPostSalesDoc"(var SalesHeader: Record "Sales Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line"; SalesShptHdrNo: Code[20]; RetRcpHdrNo: Code[20]; SalesInvHdrNo: Code[20]; SalesCrMemoHdrNo: Code[20]; CommitIsSuppressed: Boolean; InvtPickPutaway: Boolean; var CustLedgerEntry: Record "Cust. Ledger Entry"; WhseShip: Boolean; WhseReceiv: Boolean; PreviewMode: Boolean)
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        if NOT SalesInvoiceHeader.Get(SalesInvHdrNo) then
            exit;

        GenerateInvoice(SalesInvHdrNo, SalesInvoiceHeader.SystemId);

    end;

    procedure GenerateInvoice(SalesInvHdrNo: Code[20]; SalesInvoiceRecId: Guid)
    var
        PAStaging: Record ARD_PAFTPSend;
        SalesInvoiceHeader: Record "Sales Invoice Header";
        mRecRef: RecordRef;
        ReportNo: Integer;
        mOutStream: OutStream;
        Parameters: Text;
    begin
        PAStaging.Init();
        PAStaging."Ard_No." := 0;
        PAStaging.ARD_InvoiceFileName := SalesInvHdrNo + '.pdf';
        PAStaging.ARD_GeneratedDate := CurrentDateTime();
        PAStaging.ARD_Handled := false;
        PAStaging.ARD_Invoice.CreateOutStream(mOutStream, TEXTENCODING::UTF16);

        mRecRef.GetTable(SalesInvoiceHeader);
        ReportNo := GetInvoiceReportByUsage(Enum::"Report Selection Usage"::"S.Invoice");

        Parameters := GenerateReportParameters(SalesInvHdrNo);

        if Report.SaveAs(ReportNo, Parameters, ReportFormat::Pdf, mOutStream) then begin
            PAStaging.Insert();
            // Trigger Business Event
            OnPAInvoiceReady(PAStaging.SystemId);
        end;
    end;

    Procedure GetInvoiceReportByUsage(ReportUsage: Enum "Report Selection Usage"): Integer
    var
        RepSel: Record "Report Selections";
    Begin
        RepSel.SetRange(Usage, ReportUsage);
        RepSel.SetFilter("Report ID", '<>0');

        if RepSel.findfirst() then
            Exit(RepSel."Report ID")
        else
            exit(GetInvoiceReportByUsage(ReportUsage::"S.Invoice"))
    End;

    local procedure GenerateReportParameters(InvoiceNo: Code[20]): Text
    var
        BaseParametersLbl: Label
@'<?xml version="1.0" standalone="yes"?>
<ReportParameters name="Standard Sales - Invoice" id="1306">
	<Options>
		<Field name="LogInteraction">true</Field>
		<Field name="DisplayAssemblyInformation">false</Field>
		<Field name="DisplayShipmentInformation">false</Field>
		<Field name="DisplayAdditionalFeeNote">false</Field>
		<Field name="HideLinesWithZeroQuantity">false</Field>
	</Options>
	<DataItems>
		<DataItem name="Header">VERSION(1) SORTING(Field3) WHERE(Field3=1(%1))</DataItem>
		<DataItem name="Line">VERSION(1) SORTING(Field3,Field4)</DataItem>
		<DataItem name="ShipmentLine">VERSION(1) SORTING(Field1,Field2,Field3)</DataItem>
		<DataItem name="AssemblyLine">VERSION(1) SORTING(Field2,Field3)</DataItem>
		<DataItem name="WorkDescriptionLines">VERSION(1) SORTING(Field1)</DataItem>
		<DataItem name="VATAmountLine">VERSION(1) SORTING(Field5,Field9,Field10,Field13,Field16)</DataItem>
		<DataItem name="VATClauseLine">VERSION(1) SORTING(Field5,Field9,Field10,Field13,Field16)</DataItem>
		<DataItem name="ReportTotalsLine">VERSION(1) SORTING(Field1)</DataItem>
		<DataItem name="USReportTotalsLine">VERSION(1) SORTING(Field1)</DataItem>
		<DataItem name="LineFee">VERSION(1) SORTING(Field1)</DataItem>
		<DataItem name="PaymentReportingArgument">VERSION(1) SORTING(Field1)</DataItem>
		<DataItem name="LeftHeader">VERSION(1) SORTING(Field1)</DataItem>
		<DataItem name="RightHeader">VERSION(1) SORTING(Field1)</DataItem>
		<DataItem name="LetterText">VERSION(1) SORTING(Field1)</DataItem>
		<DataItem name="Totals">VERSION(1) SORTING(Field1)</DataItem>
		<DataItem name="ContractBillingDetailsMapping">VERSION(1) SORTING(Field1)</DataItem>
		<DataItem name="ContractBillingDetailsGrouping">VERSION(1) SORTING(Field1)</DataItem>
		<DataItem name="ContractBillingDetails">VERSION(1) SORTING(Field1)</DataItem>
	</DataItems>
</ReportParameters>', Comment = 'Generates report parameters for the given invoice number. %1 is replaced with the invoice number.';

        Parameters: Text;
    begin
        Parameters := StrSubstNo(BaseParametersLbl, InvoiceNo);
        exit(Parameters);
    end;

    procedure TriggerPOVIDTSInvoiceReadyEvent(PAInvoiceId: Guid)
    begin
        OnPAInvoiceReady(PAInvoiceId);
    end;

    [ExternalBusinessEvent('PAInvoice', 'PA Invoice Ready', 'Handles the PA Invoice Ready event', EventCategory::AardvarkLabs)]
    local procedure OnPAInvoiceReady(PAInvoiceId: Guid)
    begin
        // Handle the event
    end;
}
