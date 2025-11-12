SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[fn_GetRentPaymentDue](
@ContractId   INT,
@Date DATETIME)
RETURNS DECIMAL(18, 2)
--WITH RETURNS NULL ON NULL INPUT
AS
     BEGIN
         

		 DECLARE @paid DECIMAL(18,2)
			SET @paid = ( ISNULL(
			(SELECT SUM(UsdPayment) FROM [dbo].[RentPayments] 
			WHERE ContractId = @ContractId),0) + ISNULL(
			(SELECT SUM(FeeDue) FROM [dbo].[RentPayments] 
			WHERE ContractId = @ContractId AND
			CAST(CreationDate as DATE) <= CAST(@Date as date)),0) + ISNULL(
			(SELECT SUM(CardPaymentFee) FROM [dbo].[RentPayments] 
			WHERE ContractId = @ContractId AND
			CAST(CreationDate as DATE) <= CAST(@Date as date)),0) )

			declare @startingDate DATETIME
			set @startingDate = (SELECT TOP 1 StartDate FROM Contract WHERE ContractId = @ContractId)

			declare @month float
			set @month = (select CAST(DATEDIFF(MONTH, @startingDate, @Date) AS float))

			DECLARE @rent DECIMAL(18,2)
			SET @rent = (SELECT TOP 1 RentValue FROM [dbo].[Contract] WHERE ContractId = @ContractId)


			 DECLARE @mustpaid DECIMAL(18,2)
			SET @mustpaid = ISNULL(((@month + 1) * @rent),0)

			
			declare @due decimal(18,2)
			SET @due = ISNULL((@mustpaid - @paid),0)
			
			
			return @due
			
			

     END;

GO