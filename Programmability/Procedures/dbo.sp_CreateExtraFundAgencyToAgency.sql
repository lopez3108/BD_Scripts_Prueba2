SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_CreateExtraFundAgencyToAgency]
@ExtraFundAgencyToAgencyId INT = NULL,
@FromAgencyId INT,
@ToAgencyId INT,
@Usd DECIMAL(18,2),
@CreatedBy INT,
@CreationDate DATETIME,
@AssignedTo INT,
@AcceptedBy INT = NULL,
@AcceptedDate DATETIME = NULL,
@LastUpdatedBy INT = NULL,
@LastUpdatedOn DATETIME = NULL
AS
     BEGIN

	 DECLARE @isAdmin BIT
	  DECLARE @isManager BIT

	 IF(@LastUpdatedBy IS NOT NULL)
	 BEGIN

	 SET @isAdmin = (SELECT TOP 1 IsAdmin  FROM dbo.Cashiers c INNER JOIN dbo.Users u ON u.UserId = c.UserId WHERE u.UserId = @LastUpdatedBy)
	  SET @isManager = (SELECT TOP 1 IsManager  FROM dbo.Cashiers c INNER JOIN dbo.Users u ON u.UserId = c.UserId WHERE u.UserId = @LastUpdatedBy)

	 END

	 IF(EXISTS(SELECT TOP 1 * FROM dbo.Daily d
	 INNER JOIN dbo.Cashiers c ON c.CashierId = d.CashierId
	 INNER JOIN dbo.Users u ON u.UserId = c.UserId
	 WHERE (CAST(d.CreationDate as DATE) = CAST(@CreationDate as DATE) 
	 AND d.AgencyId = @FromAgencyId AND u.UserId = @CreatedBy
	 AND d.ClosedOn IS NOT NULL) AND (@LastUpdatedBy IS NULL OR @isAdmin = CAST(0 as BIT) OR @isManager = CAST(0 as BIT))))
	 BEGIN

	 SELECT -2

	 END
	 ELSE
	 BEGIN
	 IF(@ExtraFundAgencyToAgencyId IS NULL)
	 BEGIN

	 INSERT INTO [dbo].[ExtraFundAgencyToAgency]
           ([FromAgencyId]
           ,[ToAgencyId]
           ,[Usd]
           ,[CreatedBy]
           ,[CreationDate]
           ,[AssignedTo]
           ,[AcceptedBy]
           ,[AcceptedDate])
     VALUES
           (@FromAgencyId
           ,@ToAgencyId
           ,@Usd
           ,@CreatedBy
           ,@CreationDate
           ,@AssignedTo
           ,NULL
           ,NULL)

		   SELECT @@IDENTITY

		   END
		   ELSE
		   BEGIN

		   IF((SELECT TOP 1 ex.AcceptedBy FROM ExtrafundAgencyToAgency ex 
	 WHERE ExtraFundAgencyToAgencyId = @ExtraFundAgencyToAgencyId) IS NOT NULL)
	 BEGIN

	 SELECT -1

	 END
	 ELSE
	 BEGIN

		  
UPDATE [dbo].[ExtraFundAgencyToAgency]
   SET [ToAgencyId] = @ToAgencyId
      ,[Usd] = @Usd
      ,[AssignedTo] = @AssignedTo
	  ,[LastUpdatedBy] = @LastUpdatedBy
	  ,[LastUpdatedOn] = @LastUpdatedOn
 WHERE ExtraFundAgencyToAgencyId = @ExtraFundAgencyToAgencyId

 SELECT @ExtraFundAgencyToAgencyId

 END
 END
		   END


END;
GO