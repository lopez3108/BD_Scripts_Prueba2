SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[FN_GetKycCreationInformation](@ProviderId INT, 
                                                  @OrderNumber VARCHAR(15))
RETURNS @result TABLE
(UserId INT, 
 UserName        VARCHAR(80), 
 CreationDate DATETIME,
  LastUpdatedById INT, 
  LastUpdatedBy VARCHAR(80), 
 LastUpdatedOn        DATETIME
)
AS
     BEGIN

	 DECLARE @creationDate DATETIME
	 SET @creationDate = (SELECT TOP 1 CreationDate FROM dbo.Kyc ky WHERE ky.ProviderId = @ProviderId AND ky.OrderNumber = @OrderNumber
				  ORDER BY ky.KycId ASC)

	 DECLARE @userId INT
	 SET @userId = (SELECT TOP 1 ky.UserId FROM dbo.Kyc ky 
				  WHERE ky.ProviderId = @ProviderId AND ky.OrderNumber = @OrderNumber
				  ORDER BY ky.KycId ASC)

 DECLARE @userName VARCHAR(80)
	 SET @userName =   (SELECT TOP 1 u.Name FROM dbo.Kyc ky 
				  INNER JOIN Users u ON u.UserId = ky.UserId
				  WHERE ky.ProviderId = @ProviderId AND ky.OrderNumber = @OrderNumber
				  ORDER BY ky.KycId ASC)

				  DECLARE @lastUpdatedOn DATETIME
	 SET @lastUpdatedOn = (SELECT TOP 1 LastUpdatedOn FROM dbo.Kyc ky WHERE ky.ProviderId = @ProviderId AND ky.OrderNumber = @OrderNumber
				  ORDER BY ky.LastUpdatedOn DESC)

	 DECLARE @lastUpdatedById INT
	 SET @lastUpdatedById = (SELECT TOP 1 ky.LastUpdatedBy FROM dbo.Kyc ky 
				  WHERE ky.ProviderId = @ProviderId AND ky.OrderNumber = @OrderNumber
				  ORDER BY ky.LastUpdatedOn DESC)

 DECLARE @lastUpdatedBy VARCHAR(80)
	 SET @lastUpdatedBy =   (SELECT TOP 1 u.Name FROM dbo.Kyc ky 
				  INNER JOIN Users u ON u.UserId = ky.UserId
				  WHERE ky.ProviderId = @ProviderId AND ky.OrderNumber = @OrderNumber
				  ORDER BY ky.LastUpdatedOn DESC)

INSERT INTO @result (UserId, UserName, CreationDate, LastUpdatedById, LastUpdatedBy, LastUpdatedOn)
VALUES(@userId, @userName, @creationDate, @lastUpdatedById, @lastUpdatedBy, @lastUpdatedOn)

         RETURN;
     END;

GO