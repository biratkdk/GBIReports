namespace GBIReports.GBIReports;

using Microsoft.Sales.Document;
using Microsoft.Sales.Customer;
using Microsoft.Inventory.Location;
using Microsoft.Foundation.Company;
using Microsoft.Finance.Dimension;

report 70003 "Customer Wise Non Sales Cost"
{
    ApplicationArea = All;
    Caption = 'Customer Wise Non Sales Cost';
    UsageCategory = ReportsAndAnalysis;
    DefaultLayout = RDLC;
    RDLCLayout = 'SRC/Layouts/Customer Wise Non Sales Cost.rdl';
    dataset
    {
        dataitem("Sales Header"; "Sales Header")
        {
            DataItemTableView = sorting("No.");
            column(GetFilter; GetFilters) { }
            column(SLNo; SLNo) { }
            column(Cust_No; CustNo) { }
            column(Cust_Name; CustName) { }
            column(PostingDate; "Posting Date") { }
            column(LocationCode; "Location Code") { }
            column(CustomerNo; CustomerNo) { }
            column(StartDate; StartDate) { }
            column(EndDate; EndDate) { }
            column(CostAmountActual; ABS(SalesLine.Amount)) { }
            column(Gen__Prod__Posting_Group; "Gen. Prod. Posting Group") { }
            trigger OnPreDataItem()
            var
                myInt: Integer;
            begin
                // "Sales Header".SETRANGE("Posting Date", StDt, EndDt);
                "Sales Header".SetFilter("Posting Date", '%1..%2', StartDate, EndDate);
                if CustomerNo <> '' then begin
                    "Sales Header".SetRange("Sales Header"."Bill-to Customer No.", CustomerNo);
                end;
                if DepartCode <> '' then begin
                    //"Sales Header".SetRange("Sales Header"."Global Dimension 1 Code", DepartCode);
                end;
                "Sales Header".SetRange("Sales Header"."Invoice Type", "Invoice Type"::"Free Supply");
                if Location <> '' then begin
                    "Sales Header".SetRange("Sales Header"."Location Code", Location);
                end;
            end;

            trigger OnAfterGetRecord()
            var
                myInt: Integer;
            begin
                SLNo += 1;
            end;
        }
    }
    requestpage
    {
        layout
        {
            area(content)
            {
                group(Period1)
                {
                    Caption = 'Period Filters';
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
            area(processing)
            {
            }
        }
    }
    trigger OnInitReport()
    var
        myInt: Integer;
    begin
        CompanyInfo.Get();
        CompanyInfo.CalcFields(Picture);
    end;

    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        DepartCode: Code[20];
        CustName: Text;
        CustNo: Code[20];
        SLNo: Integer;
        DateFromText: Text[50];
        DateToText: Text[50];
        StDt: Date;
        EndDt: Date;
        StartDate: Date;
        EndDate: Date;
        CompanyInfo: Record "Company Information";
        Location: Code[20];
        CustomerNo: Code[20];
        Period1: Code[20];
}
