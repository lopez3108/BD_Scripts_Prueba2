SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 15/08/2025 JF 6687: Balance de Provider en Money distribution no coincide con el balance en los reportes del Provider

CREATE PROCEDURE [dbo].[sp_GetMoneyTransferInitialBalance] 
    @AgencyId   INT,
    @ProviderId INT,
    @EndDate DATETIME,
    @GetCurrentDate BIT = 0
AS
BEGIN
    DECLARE @result DECIMAL(18,2);   
  
    -- Mismo cálculo que en sp_GetReportMoneyTransfer
    SET @result = 
        ISNULL(
            (SELECT TOP 1 InitialBalance
             FROM MoneyTransferxAgencyInitialBalances
             WHERE AgencyId = @AgencyId
             AND ProviderId = @ProviderId),
        0) 
        + ISNULL(
            (SELECT SUM(CAST(Balance AS DECIMAL(18,2)))
             FROM dbo.FN_GenerateMoneyTransferReport(@AgencyId, '1985-01-01', @EndDate, @EndDate, @ProviderId)),
        0);

    SELECT @result;
END;
GO