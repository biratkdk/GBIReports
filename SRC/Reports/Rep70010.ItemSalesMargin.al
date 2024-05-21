report 70010 "Item Sales Margin"
{
    ApplicationArea = All;
    Caption = 'Item Sales Margin';
    UsageCategory = ReportsAndAnalysis;
    DefaultLayout = RDLC;
    RDLCLayout = 'SRC/Layouts/Item Sales Margin.rdl';
    dataset
    {
        dataitem("Item Ledger Entry"; "Item Ledger Entry")
        {
            DataItemTableView = SORTING("Posting Date");
            RequestFilterFields = "Entry Type", "Posting Date", "Location Code", "Global Dimension 1 Code";
            column(GetFilter; GetFilters) { }
            column(CompanyInfo_Name; CompanyInfo.Name) { }
            column(CompanyInfo_Picture; CompanyInfo.Picture) { }
            column(SLNo; SLNo) { }
            column(ItemNo; "Item No.") { }
            column(Description; Description) { }
            column(UnitofMeasureCode; "Unit of Measure Code") { }
            column(Quantity; Quantity) { }
            column(DiscountaMT; DiscountAmt) { }
            column(Margin; Margin) { }
            column(Per1; Per1) { }
            column(per2; per2) { }
            column(Netsales; Netsales) { }
            column(Costofsales; "Cost Amount (Actual)") { }
            column(SalesPrice; SalesPrice) { }
            column(UnitCost; UnitCost) { }

            trigger OnAfterGetRecord()
            var
                Itemprice: Record "Price List Line";
            begin
                SLNo += 1;
                Clear(Qty);
                CLEAR(SalesPrice);
                Customer.RESET;
                IF Customer.GET("Item Ledger Entry"."Source No.") THEN;
                IF (("Sales Amount (Actual)") <> 0) AND ("Invoiced Quantity" <> 0) THEN BEGIN
                    Clear(Itemprice);
                    SalesPrice := Itemprice."Unit Price";
                    iuom2.SETCURRENTKEY("Item No.", "Qty. per Unit of Measure");
                    iuom2.SETRANGE("Item No.", "Item No.");
                    IF iuom2.FIND('+') THEN;
                    IF "Item Ledger Entry"."Invoiced Quantity" > 0 THEN BEGIN
                        Qty := "Item Ledger Entry"."Invoiced Quantity"
                    END
                    ELSE
                        IF "Item Ledger Entry"."Invoiced Quantity" < 0 THEN BEGIN
                            Qty := "Item Ledger Entry"."Invoiced Quantity" * -1;
                        END;
                    GrossSales := SalesPrice * Qty;
                    // IF ("Entry Type" = "Item Ledger Entry"."Entry Type"::Sale) AND (SalesShipment.GET("Item Ledger Entry"."Document No.")) THEN BEGIN

                    //     SalesInv.RESET;
                    //     SalesInv.SETCURRENTKEY("Order No.");
                    //     SalesInv.SETRANGE("Order No.", SalesShipment."Order No.");
                    //     IF SalesInv.FINDFIRST THEN BEGIN
                    //         DocNo := SalesInv."No.";
                    //         //<<ALJ 300816
                    //         SalesInvoiceLine.RESET;
                    //         SalesInvoiceLine.SETCURRENTKEY("Document No.", "Line No.");
                    //         SalesInvoiceLine.SETRANGE("Document No.", DocNo);
                    //         //SalesInvoiceLine.SETFILTER("Special Price Ref. No.",'<>%1','');
                    //         SalesInvoiceLine.SETFILTER("No.", "Item No.");

                    //         //>>ALJ 300816
                    //     END
                    // END ELSE BEGIN
                    //     IF ("Entry Type" = "Item Ledger Entry"."Entry Type"::Sale) AND
                    //        (SalesReturnShip.GET("Item Ledger Entry"."Document No.")) THEN BEGIN
                    //         IF SalesCreditMemo.GET(SalesReturnShip."No.") THEN BEGIN
                    //             DocNo := SalesCreditMemo."No.";
                    //         END
                    //     END;
                    // END;
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
                Netsales := GrossSales - DiscountAmt;
                Margin := Netsales - "Cost Amount (Actual)";
                Per1 := ("Cost Amount (Actual)" / Netsales) * 100;
                per2 := (Margin / Netsales) * 100;
                UnitCost := "Cost Amount (Actual)" / Quantity;
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
    trigger OnInitReport()
    var
        myInt: Integer;
    begin
        CompanyInfo.Get();
        CompanyInfo.CalcFields(Picture);
    end;

    var
        SLNo: Integer;
        CompanyInfo: Record "Company Information";
        StDt: Date;
        EndDt: Date;
        DepartCode: Code[20];
        ItemNo: Code[20];
        Location: Code[20];
        CustomerNo: Code[20];
        Customer: Record Customer;
        Qty: Decimal;
        SalesPrice: Decimal;
        UnitCost: Decimal;
        iuom2: Record "Item Unit of Measure";
        VE: Record "Value Entry";
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
        DiscountAmt: Decimal;
        Department: Record Dimension;
}
