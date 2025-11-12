SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2025-10-10 JF/6786: Ajuste para contratos cerrados el mismo día de creación

CREATE FUNCTION [dbo].[fn_GetRentDueDays](
@ContractId   INT,
@Date DATETIME)
RETURNS DECIMAL(18, 2)
--WITH RETURNS NULL ON NULL INPUT
AS
     BEGIN


		 DECLARE @paid DECIMAL(18,2)
			SET @paid = ISNULL(
			(SELECT SUM(UsdPayment) FROM [dbo].[RentPayments] 
			WHERE ContractId = @ContractId ),0)

			declare @startingDate DATETIME
			set @startingDate = (SELECT TOP 1 StartDate FROM Contract WHERE ContractId = @ContractId)

			declare @endDate DATETIME
			set @endDate = (SELECT TOP 1 EndDate FROM Contract WHERE ContractId = @ContractId)

			 declare @months float
			set @months = (select CAST(DATEDIFF(MONTH, @startingDate, @endDate) AS float))

			 declare @days float
			set @days = (select CAST(DATEDIFF(DAY, @startingDate, @endDate) AS float))

			DECLARE @rent DECIMAL(18,2)
			SET @rent = (SELECT TOP 1 RentValue FROM [dbo].[Contract] WHERE ContractId = @ContractId)
		
		declare @contractValue decimal(18,2)
		set @contractValue = @rent * @months
		
			declare @valueDay decimal(18,2)
--			set @valueDay = @contractValue / @days --6786
      SET @valueDay = ISNULL(@contractValue / NULLIF(@days, 0), 0)

			 declare @daysmustpaid float
			set @daysmustpaid = (select CAST(DATEDIFF(DAY, @startingDate, @Date) AS float))

			declare @valueMustPaid decimal(18,2)
			set @valueMustPaid = @daysmustpaid * @valueDay

			declare @dif decimal(18,2)
			set @dif = @valueMustPaid - @paid

			--declare @due decimal(18,2)
			--SET @due = [dbo].[fn_GetRentDue](@ContractId, @Date)

			declare @daysdue decimal(18,2)
--			set @daysdue = @dif / @valueDay --6786
      SET @daysdue = ISNULL(@dif / NULLIF(@valueDay, 0), 0)

			return @daysdue
			
			

     END;

GO