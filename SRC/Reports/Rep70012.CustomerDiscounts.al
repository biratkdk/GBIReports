namespace GBIReports.GBIReports;

using Microsoft.Inventory.Ledger;
using Microsoft.Sales.Customer;
using Microsoft.Sales.Receivables;
using Microsoft.Finance.Dimension;
using Microsoft.Inventory.Location;
using Microsoft.Foundation.Company;

report 70012 "Customer Discounts"
{
    ApplicationArea = All;
    Caption = 'Customer Discounts';
    UsageCategory = ReportsAndAnalysis;
    DefaultLayout = RDLC;
    RDLCLayout = 'SRC/Layouts/Customer Discounts.rdl';
    dataset
    {
        dataitem("Cust. Ledger Entry"; "Cust. Ledger Entry")
        {
            DataItemTableView = sorting("Posting Date");
            column(Customer_No_; "Customer No.") { }
            column(Customer_Name; "Customer Name") { }
            column(Sales__LCY_; "Sales (LCY)") { }
            column(Discount_; "Discount%") { }


            dataitem("Value Entry"; "Value Entry")
            {
                DataItemLinkReference = "Cust. Ledger Entry";
                DataItemTableView = sorting("Entry No.");
                DataItemLink = "Entry No." = field("Entry No.");

                column(Discount_Amount; "Discount Amount") { }
            }

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
        trigger OnAfterGetRecord()
        var
            myInt: Integer;
        begin
            "Discount%" := ("Value Entry"."Discount Amount" / "Cust. Ledger Entry"."Sales (LCY)") * 100;
        end;

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
        custledgerentry: Record "Cust. Ledger Entry";
        "Discount%": Integer;
        StDt: Date;
        EndDt: Date;
        StartDate: Date;
        EndDate: Date;
        DepartCode: Code[20];
        Location: Code[20];
        CustomerNo: Code[20];
        CompanyInfo: Record "Company Information";
}
