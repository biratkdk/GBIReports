namespace GBIReports.GBIReports;

using Microsoft.Inventory.Ledger;
using Microsoft.Finance.Dimension;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Sales.Document;
using Microsoft.Sales.History;
using Microsoft.Sales.Customer;
using Microsoft.Inventory.Location;
using Microsoft.Foundation.Company;

report 70001 "Sales Margin Report"
{
    ApplicationArea = All;
    Caption = 'Sales Margin Report';
    UsageCategory = ReportsAndAnalysis;
    DefaultLayout = RDLC;
    RDLCLayout = 'SRC/Layouts/Sales Margin Report.rdl';
    dataset
    {
        dataitem("Item Ledger Entry"; "Item Ledger Entry")
        {
            DataItemTableView = SORTING("Posting Date");
            RequestFilterFields = "Entry Type", "Posting Date", "Location Code", "Global Dimension 1 Code";
            CalcFields = "Sales Amount (Actual)", "Cost Amount (Actual)";


            column(GetFilter; GetFilters) { }
            column(CompanyInfo_Name; CompanyInfo.Name) { }
            column(CompanyInfo_Picture; CompanyInfo.Picture) { }
            column(SLNo; SLNo) { }
            column(Cust_No; "Item Ledger Entry"."Source No.") { }
            column(Cust_Name; CustName) { }
            // column(Cust_No; PSH."Bill-to Customer No.") { }
            // column(Cust_Name; PSH."Bill-to Name") { }
            column(Department_Code; "Item Ledger Entry"."Global Dimension 1 Code") { }
            column(DocumentNo; "Item Ledger Entry"."Document No.") { }
            column(PostingDate; "Item Ledger Entry"."Posting Date") { }
            column(LocationCode; "Item Ledger Entry"."Location Code") { }
            column(SalesAmountActual; ABS("Sales Amount (Actual)")) { }
            column(CostAmountActual; ABS("Cost Amount (Actual)")) { }
            column(MarginValue; ABS("Sales Amount (Actual)") - ABS("Cost Amount (Actual)")) { }
            column("Margin_Percent"; Format(ABS("Margin %")) + '%') { }
            column(Percent; Format(Percent) + '%') { }
            column(Location; Location) { }
            column(CustomerNo; CustomerNo) { }
            trigger OnPreDataItem()
            var
                myInt: Integer;
            begin
                SETRANGE("Posting Date", StDt, EndDt);

                if DepartCode <> '' then begin
                    "Item Ledger Entry".SetRange("Item Ledger Entry"."Global Dimension 1 Code", DepartCode);
                end;
                "Item Ledger Entry".SetRange("Item Ledger Entry"."Entry Type", "Entry Type"::Sale);
                if Location <> '' then begin
                    "Item Ledger Entry".SetRange("Location Code", Location);
                end;

            end;

            trigger OnAfterGetRecord()
            var
                myInt: Integer;
            begin
                Margin := 0;
                // PSH.Reset();
                // PSH.SetRange("No.", "Item Ledger Entry"."Document No.");
                // if CustomerNo <> '' then begin
                // psh.SetFilter("Bill-to Customer No.", CustomerNo);

                // end;
                Customer.Reset();
                clear(CustName);
                Clear(CustNo);
                Customer.setrange("No.", "Item Ledger Entry"."Source No.");

                if Customer.FindFirst() then begin
                    CustName := Customer.Name;
                    CustNo := Customer."No.";
                end;

                SLNo += 1;
                IF ("Sales Amount (Actual)" <> 0) AND ("Cost Amount (Actual)" <> 0) THEN begin
                    "Margin %" := (ROUND((ABS("Sales Amount (Actual)") - ABS("Cost Amount (Actual)")) / ABS("Sales Amount (Actual)"), 0.1)) * 100;
                    "Percent" := (ROUND(ABS("Cost Amount (Actual)") / ABS("Sales Amount (Actual)"), 0.1)) * 100;
                end;
            end;
        }
    }
    requestpage
    {
        layout
        {
            area(content)
            {
                group(Option)
                {
                    field(StDt; StDt)
                    {
                        ApplicationArea = all;
                        ShowMandatory = true;
                        Caption = 'Start Date';
                    }
                    field(EndDate; EndDt)
                    {
                        ApplicationArea = all;
                        ShowMandatory = true;
                        Caption = 'End Date';
                    }
                    field("Department code"; DepartCode)
                    {
                        ApplicationArea = all;
                        Caption = 'Department Code';
                        TableRelation = "Dimension Value".Code;
                    }
                    field(CustomerNo; CustomerNo)
                    {
                        ApplicationArea = all;
                        TableRelation = Customer;
                        Caption = 'Customer';
                    }
                    field(Location; Location)
                    {
                        ApplicationArea = all;
                        TableRelation = Location;
                    }

                }
            }

        }
        actions
        {
            area(processing) { }
        }
    }
    trigger OnPreReport()
    begin
        if StDt = 0D then begin
            Error('Please enter Start Date');
        end;
        if EndDt = 0D then begin
            Error('Please Enter End Date');
        end;
        IF EndDt < StDt THEN
            ERROR('End Date cannot be greater than Start Date');
    end;

    trigger OnInitReport()
    var
        myInt: Integer;
    begin
        CompanyInfo.Get();
        CompanyInfo.CalcFields(Picture);
    end;

    var
        Customer: record Customer;
        CustName: Text;
        CustNo: Code[20];
        DepartCode: Code[20];
        SLNo: Integer;
        Margin: Decimal;
        "Margin %": Decimal;
        Percent: Decimal;
        DateFromText: Text[50];
        DateToText: Text[50];
        StDt: Date;
        EndDt: Date;
        Location: Code[20];
        CustomerNo: Code[20];
        CompanyInfo: Record "Company Information";
        PSH: Record "Sales Shipment Header";
}
