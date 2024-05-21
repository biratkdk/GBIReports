namespace GBIReports.GBIReports;

using Microsoft.Inventory.Ledger;
using Microsoft.Foundation.Company;
using Microsoft.Inventory.Item;

report 70000 "Sales Summary Report"
{
    ApplicationArea = All;
    Caption = 'Sales Summary Report';
    UsageCategory = ReportsAndAnalysis;
    DefaultLayout = RDLC;
    RDLCLayout = 'SRC/Layouts/Sales Summary Report.rdl';
    dataset
    {
        dataitem("Item Ledger Entry"; "Item Ledger Entry")
        {
            DataItemTableView = SORTING("Posting Date");
            RequestFilterFields = "Location Code", "Global Dimension 1 Code", "Posting Date";
            // column(Company_Name;CompanyInfo."Company name"){}
            column(GetFilter; GetFilters) { }
            column(Posting_Date; "Item Ledger Entry"."Posting Date")
            { }
            column(UOM; "Unit of Measure Code")
            { }
            column(Qty_per_UOM; "Qty. per Unit of Measure")
            { }
            column(Date; "Posting Date")
            { }
            column(Location_Code; "Item Ledger Entry"."Location Code")
            { }
            column(Department_Code; "Global Dimension 1 Code")
            { }
            column(Item_Category_Code; "Item Category Code")
            { }
            // column(Product_Group_Code; "Item Ledger Entry"."Product Group Code")
            // { }
            // column()
            // {}
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
                    field(FromDate; FromDate)
                    { }
                    field(ToDate; ToDate)
                    { }
                    field(Mode; Mode)
                    { }

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
    var
        ioum: Record "Item Unit of Measure";
        CompanyInfo: Record "Company Information";
        FromDate: Date;
        ToDate: Date;
        Mode: Option Weekly,Monthly,Yearly;
}
