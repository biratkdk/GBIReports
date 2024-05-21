namespace GBIReports.GBIReports;

using Microsoft.Inventory.Ledger;
using Microsoft.Sales.History;
using Microsoft.Inventory.Item;
using Microsoft.Foundation.Company;
using Microsoft.Inventory.Location;
using Microsoft.Finance.Dimension;
using Microsoft.Pricing.PriceList;
using Microsoft.Sales.Customer;
report 70013 "Detailed Sales"
{
    ApplicationArea = All;
    Caption = 'Detailed Sales';
    DefaultLayout = RDLC;
    RDLCLayout = 'SRC/Layouts/Detailed Sales.rdl';
    UsageCategory = ReportsAndAnalysis;
    dataset
    {
        dataitem("Item Ledger Entry"; "Item Ledger Entry")
        {

            DataItemTableView = SORTING("Posting Date");
            RequestFilterFields = "Entry Type", "Posting Date", "Location Code", "Global Dimension 1 Code";
            CalcFields = "Cost Amount (Actual)", "Sales Amount (Actual)";
            column(SLNO; SLNO) { }
            column(CompanyInfo_Name; CompanyInfo.Name) { }
            column(CompanyInfo_Picture; CompanyInfo.Picture) { }
            column(DocumentNo; DocNo) { }
            column(DocumentDate; "Document Date") { }
            column(Getfilter; 'From Date: ' + FORMAT(StDt) + ' To Date: ' + FORMAT(EndDt) + ' ' + GETFILTERS) { }
            column(GrossSales; GrossSales) { }
            column(DiscountaMT; DiscountAmt) { }
            column(Margin; Margin) { }
            column(Per1; Per1 + '%') { }
            column(per2; per2 + '%') { }
            column(per3; per3 + '%') { }
            column(Netsales; Netsales) { }
            column(Costofsales; "Cost Amount (Actual)") { }
            column(CustName; CustName) { }
            column(CustNo; CustNo) { }
            column(Location_Code; locationcode) { }
            column(DimensionCode; DepartCode) { }
            trigger OnPreDataItem()
            var
                myInt: Integer;
            begin
                IF (StDt = 0D) OR (EndDt = 0D) THEN
                    ERROR('Please specify Start Date and End Date');

                SETRANGE("Posting Date", StDt, EndDt);

                if DepartCode <> '' then begin
                    "Item Ledger Entry".SetRange("Item Ledger Entry"."Global Dimension 1 Code", DepartCode);
                end;

                "Item Ledger Entry".SetRange("Item Ledger Entry"."Entry Type", "Entry Type"::Sale);
                "Item Ledger Entry".SetRange("Item Ledger Entry"."Sales Amount (Actual)", 0);
                if locationcode <> '' then begin
                    "Item Ledger Entry".SetRange("Location Code", locationcode);
                end;
                Customer.SetRange("No.", "Item Ledger Entry"."Source No.");
                if Customer.FindFirst() then begin
                    RetailPriceUtil.GetItemPrice(Customer."Customer Price Group", '', '', "Posting Date", '', Itemprice, "Item Ledger Entry"."Unit of Measure Code");
                    // RSP Should be taken from customer price group
                end;
            end;

            trigger OnAfterGetRecord()

            begin
                SLNo += 1;
                Clear(Qty);
                CLEAR(Itemprice);
                IF (("Sales Amount (Actual)") <> 0) AND ("Invoiced Quantity" <> 0) THEN BEGIN
                    Clear(Itemprice);
                    SalesPrice := Itemprice."Unit Price";
                    iuom2.SETCURRENTKEY("Item No.", "Qty. per Unit of Measure");
                    iuom2.SETRANGE("Item No.", "Item Ledger Entry"."Item No.");
                    IF iuom2.FIND('+') THEN;
                    IF "Item Ledger Entry"."Invoiced Quantity" > 0 THEN BEGIN
                        Qty := "Item Ledger Entry"."Invoiced Quantity"
                    END
                    ELSE
                        IF "Item Ledger Entry"."Invoiced Quantity" < 0 THEN BEGIN
                            Qty := "Item Ledger Entry"."Invoiced Quantity" * -1;
                        END;
                    A := ROUND(ABS("Sales Amount (Actual)" / "Invoiced Quantity"), 0.01);
                    B := ROUND(ABS((SalesPrice / iuom2."Qty. per Unit of Measure")), 0.01);
                    GrossSales := SalesPrice * Qty;
                    IF ("Entry Type" = "Item Ledger Entry"."Entry Type"::Sale) AND (SalesShipment.GET("Item Ledger Entry"."Document No.")) THEN BEGIN

                        SalesInv.RESET;
                        SalesInv.SETCURRENTKEY("Order No.");
                        SalesInv.SETRANGE("Order No.", SalesShipment."Order No.");
                        IF SalesInv.FINDFIRST THEN BEGIN
                            DocNo := SalesInv."No.";
                            //<<ALJ 300816
                            SalesInvoiceLine.RESET;
                            SalesInvoiceLine.SETCURRENTKEY("Document No.", "Line No.");
                            SalesInvoiceLine.SETRANGE("Document No.", DocNo);
                            //SalesInvoiceLine.SETFILTER("Special Price Ref. No.",'<>%1','');
                            SalesInvoiceLine.SETFILTER("No.", "Item No.");

                            //>>ALJ 300816
                        END
                    END ELSE BEGIN
                        IF ("Entry Type" = "Item Ledger Entry"."Entry Type"::Sale) AND
                           (SalesReturnShip.GET("Item Ledger Entry"."Document No.")) THEN BEGIN
                            IF SalesCreditMemo.GET(SalesReturnShip."No.") THEN BEGIN
                                DocNo := SalesCreditMemo."No.";
                            END
                        END;
                    END;
                End;
                VE.Reset();
                VE.SetRange("Document No.", "Item Ledger Entry"."Document No.");
                VE.SetRange("Item Ledger Entry No.", "Item Ledger Entry"."Entry No.");
                VE.SetRange("Posting Date", "Item Ledger Entry"."Posting Date");
                VE.SetRange("Source Type", "Item Ledger Entry"."Source Type");
                VE.SetRange("Item Ledger Entry Type", "Item Ledger Entry"."Entry Type");
                if VE.FindFirst() then begin
                    DiscountAmt := VE."Discount Amount";
                end;
                if DiscountAmt <> 0 then begin
                    Per1 := DiscountAmt / GrossSales * 100;
                    Netsales := GrossSales - DiscountAmt;
                    per2 := "Cost Amount (Actual)" / Netsales * 100;
                    Margin := Netsales - "Cost Amount (Actual)";
                    per3 := Margin / Netsales * 100;
                end;
                // else
                //     Error('Discount Amout is Zero');

                Customer.Reset();
                clear(CustName);
                Clear(CustNo);
                Customer.setrange("No.", "Item Ledger Entry"."Source No.");

                if Customer.FindFirst() then begin
                    CustName := Customer.Name;
                    CustNo := Customer."No.";
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
                group(GroupName)
                {
                    field(StDt; StDt)
                    {
                        Caption = 'Start Date';
                    }
                    field(EndDt; EndDt)
                    {
                        Caption = 'End Date';
                        trigger onvalidate()
                        var
                            myInt: Integer;
                        begin
                            IF StDt = 0D THEN
                                ERROR('Please select the Start Date');

                            IF EndDt < StDt THEN
                                ERROR('End Date cannot be greater than Start Date');
                        end;
                    }
                    field(DimensionCode; DepartCode)
                    {
                        Caption = 'Dimension';
                        TableRelation = "Dimension Value".Code;
                    }
                    field(locationcode; locationcode)
                    {
                        Caption = 'Location';
                        TableRelation = Location;
                    }
                    field(CustomerNo; CustNo)
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
        IF StDt = 0D THEN
            ERROR('Please select the Start Date');

        if EndDt = 0D then begin
            Error('Please Enter End Date');
        end;

        IF EndDt < StDt THEN
            ERROR('End Date cannot be greater than Start Date');
    end;

    trigger OnInitReport()
    BEGIN
        CompanyInfo.GET;
        CompanyInfo.CALCFIELDS(Picture);

    END;

    var
        CompanyInfo: Record "Company Information";
        Itemprice: Record "Price List Line";
        SLNO: Integer;
        StDt: Date;
        EndDt: Date;
        Qty: Decimal;
        Customer: Record Customer;
        SalesPrice: Decimal;
        iuom2: Record "Item Unit of Measure";
        A: Decimal;
        B: Decimal;
        VE: Record "Value Entry";
        RetailPriceUtil: Codeunit "LSC Retail Price Utils";
        GrossSales: Decimal;
        Per1: Decimal;
        per2: Decimal;
        per3: Decimal;
        Netsales: Decimal;
        Margin: Decimal;
        SalesInv: Record "Sales Invoice Header";
        SalesInvoiceLine: Record "Sales Invoice Line";
        SalesReturnShip: Record "Return Receipt Header";
        SalesShipment: Record "Sales Shipment Header";
        SalesCreditMemo: Record "Sales Cr.Memo Header";
        ReturnReceiptLine: Record "Return Receipt Line";
        DocNo: Text[30];
        DepartCode: Code[20];
        DiscountAmt: Decimal;
        Department: Record Dimension;
        locationcode: Code[20];
        CustName: Text[100];
        CustNo: Code[20];

}