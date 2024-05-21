namespace GBIReports.GBIReports;

using Microsoft.Inventory.Ledger;
using Microsoft.Finance.Dimension;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Foundation.Company;
using Microsoft.Sales.History;
using System.Utilities;
using Microsoft.Inventory.Location;
using Microsoft.Sales.Customer;

report 70002 "Sales Margin Report-Comparison"
{
    ApplicationArea = All;
    Caption = 'Sales Margin Report-Comparison';
    UsageCategory = ReportsAndAnalysis;
    DefaultLayout = RDLC;
    RDLCLayout = 'SRC/Layouts/Sales Margin Report-Comparison.rdl';
    dataset
    {
        // dataitem(Integer; Integer)
        // {
        //     DataItemTableView = SORTING(Number)
        //                   ORDER(Ascending)
        //                   WHERE(Number = CONST(1));
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
            column(CurrentPeriod; 'PERIOD' + Format(StDt) + 'To' + Format(EndDt)) { }
            column(ComparisonPeriod; 'PERIOD' + Format(StartDate) + 'To' + Format(EndDate)) { }


            trigger OnPreDataItem()
            var
                myInt: Integer;
            begin
                SETRANGE("Posting Date", StDt, EndDt);
                // SetRange("Posting Date",StartDate,EndDate);

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
        // }
    }
    requestpage
    {
        layout
        {
            area(content)
            {
                group(Option)
                {
                    group("Current Period")
                    {
                        field(StDt; StDt)
                        {
                            ApplicationArea = all;
                            ShowMandatory = true;
                            Caption = 'Start Date';
                        }
                        field(EndDt; EndDt)
                        {
                            ApplicationArea = all;
                            ShowMandatory = true;
                            Caption = 'End Date';
                        }
                    }
                    group("Comparison Period")
                    {
                        field(StartDate; StartDate)
                        {
                            ApplicationArea = All;
                            ShowMandatory = true;
                            Caption = 'Start Date';
                        }
                        field(EndDate; EndDate)
                        {
                            ApplicationArea = all;
                            ShowMandatory = true;
                            Caption = 'End Date';
                        }
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
                        Caption = 'Location';
                        TableRelation = Location;
                    }
                }
            }
        }
        actions
        {
            area(processing)
            {
            }
        }
    }
    trigger OnPreReport()
    begin
        if StDt = 0D then begin
            Error('Please enter Current Period Start Date');
        end;
        if EndDt = 0D then begin
            Error('Please Enter Current Period End Date');
        end;
        if StartDate = 0D then begin
            Error('Please enter Comparison Period Start Date');
        end;
        if EndDate = 0D then begin
            Error('Please Enter Comparison Period End Date');
        end;
    end;

    trigger OnInitReport()
    var
        myInt: Integer;
    begin
        CompanyInfo.Get();
        CompanyInfo.CalcFields(Picture);
    end;

    var
        Customer: Record Customer;
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
        StartDate: Date;
        EndDate: Date;
        Location: Code[20];
        CustomerNo: Code[20];
        CompanyInfo: Record "Company Information";
}
