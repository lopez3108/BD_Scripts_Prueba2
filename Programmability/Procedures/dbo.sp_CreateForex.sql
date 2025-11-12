SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CreateForex] 
@ForexId INT = NULL,
@ProviderId INT,
@AgencyId INT,
@Usd DECIMAL(18,2),
@CreatedBy   INT,
@CreationDate	DATETIME,
@LastUpdatedBy   INT = NULL,
@LastUpdatedOn	DATETIME = NULL,
@FromDate DATETIME,
@ToDate DATETIME,
@IsDebit BIT
AS
     BEGIN

	  DECLARE @forexExpenseType INT
		   SET @forexExpenseType = (SELECT TOP 1 e.ExpensesTypeId FROM dbo.ExpensesType e WHERE e.Code = 'C15')

	 IF((NOT EXISTS(SELECT TOP 1 * FROM dbo.Forex f 
	 WHERE f.ProviderId = @ProviderId AND f.AgencyId = @AgencyId AND CAST(f.FromDate AS DATE) <= CAST(@ToDate as DATE) and
    (CAST(f.ToDate as DATE) >= CAST(@FromDate AS DATE)))) 
			AND NOT EXISTS(SELECT TOP 1 * FROM dbo.Expenses e WHERE e.ExpenseTypeId = @forexExpenseType 
AND e.ProviderId = @ProviderId AND e.AgencyId = @AgencyId
 AND  (CAST(e.FromDate AS DATE) <= CAST(@ToDate AS DATE) and
    (CAST(e.ToDate AS DATE) >= CAST(@FromDate as DATE)))))
	 BEGIN

	 IF(CAST(@IsDebit AS BIT) = CAST(0 as BIT))
	 BEGIN
         
		 INSERT INTO [dbo].[Forex]
           ([AgencyId]
           ,[ProviderId]
           ,[Usd]
           ,[CreatedBy]
           ,[CreationDate]
           ,[LastUpdatedBy]
           ,[LastUpdatedOn]
		   ,[FromDate]
           ,[ToDate])
     VALUES
           (@AgencyId
           ,@ProviderId
           ,@Usd
           ,@CreatedBy
           ,@CreationDate
           ,@LastUpdatedBy
           ,@LastUpdatedOn
		   ,@FromDate
           ,@ToDate)

		   SELECT @@IDENTITY

		   END
		   ELSE
		   BEGIN


		   INSERT INTO [dbo].[Expenses]
           ([ExpenseTypeId]
           ,[Usd]
           ,[ProviderId]
           ,[AgencyId]
           ,[CreatedBy]
           ,[CreatedOn]
		   ,[FromDate]
           ,[ToDate])
     VALUES
           (
		   @forexExpenseType,
		   @Usd * -1,
		   @ProviderId,
		   @AgencyId,
		   @CreatedBy,
		   @CreationDate,
		   @FromDate,
           @ToDate
		   )

		   SELECT @@IDENTITY



		   END

		END
		ELSE
		BEGIN

		SELECT -1


		END

     END;
GO