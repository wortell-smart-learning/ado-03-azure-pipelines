CREATE TABLE [dbo].[FactResellerSales] (
    [ProductKey]            INT           NOT NULL,
    [OrderDateKey]          INT           NOT NULL,
    [DueDateKey]            INT           NOT NULL,
    [ShipDateKey]           INT           NOT NULL,
    [ResellerKey]           INT           NOT NULL,
    [EmployeeKey]           INT           NOT NULL,
    [PromotionKey]          INT           NOT NULL,
    [CurrencyKey]           INT           NOT NULL,
    [SalesTerritoryKey]     INT           NOT NULL,
    [SalesOrderNumber]      NVARCHAR (20) NOT NULL,
    [SalesOrderLineNumber]  TINYINT       NOT NULL,
    [RevisionNumber]        TINYINT       NULL,
    [OrderQuantity]         SMALLINT      NULL,
    [UnitPrice]             MONEY         NULL,
    [ExtendedAmount]        MONEY         NULL,
    [UnitPriceDiscountPct]  FLOAT (53)    NULL,
    [DiscountAmount]        FLOAT (53)    NULL,
    [ProductStandardCost]   MONEY         NULL,
    [TotalProductCost]      MONEY         NULL,
    [SalesAmount]           MONEY         NULL,
    [TaxAmt]                MONEY         NULL,
    [Freight]               MONEY         NULL,
    [CarrierTrackingNumber] NVARCHAR (25) NULL,
    [CustomerPONumber]      NVARCHAR (25) NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH([ProductKey]));

