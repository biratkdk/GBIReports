namespace GBIReports.GBIReports;

using Microsoft.Inventory.Ledger;
using Microsoft.Pricing.PriceList;
using Microsoft.Inventory.Location;
using Microsoft.Inventory.Item;
using Microsoft.Finance.Dimension;
using Microsoft.Sales.Customer;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Foundation.Company;

report 70005 "Item Wise Non Sales Cost"
{
    ApplicationArea = All;
    Caption = 'Item Wise Non Sales Cost';
    UsageCategory = ReportsAndAnalysis;
    DefaultLayout = RDLC;
    RDLCLayout = 'SRC/Layouts/Item Wise Non Sales Cost.rdl';
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
            column(Item_No_; "Item No.") { }
            column(Description; Description) { }
            column(UnitofMeasureCode; "Unit of Measure Code") { }
            column(Quantity; abs(Quantity)) { }
            column(DocumentNo; "Item Ledger Entry"."Document No.") { }
            column(PostingDate; "Item Ledger Entry"."Posting Date") { }
            column(LocationCode; "Item Ledger Entry"."Location Code") { }
            column(SalesAmountActual; ABS("Sales Amount (Actual)")) { }
            column(CostAmountActual; ABS("Cost Amount (Actual)")) { }
            column(GlobalDimension1Code; "Global Dimension 1 Code") { }
            column(UnitCost; UnitCost) { }
            trigger OnPreDataItem()
            var
                myInt: Integer;
            begin
                SETRANGE("Posting Date", StDt, EndDt);

                if DepartCode <> '' then begin
                    "Item Ledger Entry".SetRange("Item Ledger Entry"."Global Dimension 1 Code", DepartCode);
                end;
                if ItemNo <> '' then begin
                    "Item Ledger Entry".SetRange("Item Ledger Entry"."Item No.", ItemNo);
                end;
                "Item Ledger Entry".SetRange("Item Ledger Entry"."Entry Type", "Entry Type"::Sale);
                "Item Ledger Entry".SetRange("Item Ledger Entry"."Sales Amount (Actual)", 0);
                if Location <> '' then begin
                    "Item Ledger Entry".SetRange("Location Code", Location);
                end;
                Customer.SetRange("No.", "Item Ledger Entry"."Source No.");
                if Customer.FindFirst() then begin
                    RetailPriceUtil.GetItemPrice(Customer."Customer Price Group", '', '', "Posting Date", '', Itemprice, "Item Ledger Entry"."Unit of Measure Code");
                    // RSP Should be taken from customer price group
                end;


            end;

            trigger OnAfterGetRecord()
            var
                myInt: Integer;
            begin

                SLNo += 1;
                IF ("Sales Amount (Actual)" = 0) AND ("Cost Amount (Actual)" <> 0) THEN begin
                    UnitCost := ROUND(ABS("Cost Amount (Actual)") / Quantity, 0.01);
                end;
                UnitPrice := ROUND(ABS("Sales Amount (Actual)") / Quantity, 0.01);
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
                    field(StartDate; StDt)
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
                    field("Item Code"; ItemNo)
                    {
                        ApplicationArea = all;
                        Caption = 'Item Code';
                        TableRelation = Item."No.";
                    }
                    field(Location; Location)
                    {
                        ApplicationArea = all;
                        Caption = 'Location';
                        TableRelation = Location;
                    }
                    field(CustomerNo; CustomerNo)
                    {
                        ApplicationArea = all;
                        TableRelation = Customer;
                        Caption = 'Customer';
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
    end;

    trigger OnInitReport()
    var
        myInt: Integer;
    begin
        CompanyInfo.Get();
        CompanyInfo.CalcFields(Picture);
    end;

    var
        CustName: Text;
        CustNo: Code[20];
        DepartCode: Code[20];
        SLNo: Integer;
        StDt: Date;
        EndDt: Date;
        Location: Code[20];
        CustomerNo: Code[20];
        CompanyInfo: Record "Company Information";
        ItemNo: Code[20];
        UnitCost: Decimal;
        UnitPrice: Decimal;
        Itemprice: Record "Price List Line";
        RetailPriceUtil: Codeunit "LSC Retail Price Utils";
        Customer: Record Customer;
}
