SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE FUNCTION [dbo].[fn_GetPropertiesDepositRefund](@PropertiesIds VARCHAR(100), @FromDate     DATETIME,
 @ToDate            DATETIME)
RETURNS DECIMAL(18, 1)
AS
     BEGIN
         
		 DECLARE @refund DECIMAL(18, 2)
 
  SET @refund = (SELECT SUM(Usd) FROM DepositFinancingPayments d 
  INNER JOIN Contract c on c.ContractId = d.ContractId
  INNER JOIN Apartments a on a.ApartmentsId = c.ApartmentId
  WHERE a.PropertiesId IN
         (
             SELECT item
             FROM dbo.FN_ListToTableInt(@PropertiesIds)
         ) AND c.RefundDate IS NOT NULL AND
CAST(d.CreationDate as DATE) >= CAST(@FromDate as DATE) AND
CAST(d.CreationDate as DATE) <= CAST(@ToDate as DATE))

         RETURN @refund
     END;
GO