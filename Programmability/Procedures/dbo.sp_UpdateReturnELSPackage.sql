SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_UpdateReturnELSPackage]
 (

 @ReturnsELSId int,
@PackageNumber VARCHAR(30),
@ShippingDate DATETIME,
@CurrentDate DATETIME,
@UserId INT

    )
AS 

BEGIN

declare @statusId INT
SET @statusId = (SELECT TOP 1 ReturnsELSStatusId FROM ReturnELSStatus WHERE Code = 'C02')

UPDATE [dbo].[ReturnsELS]
   SET 
      [PackageNumber] = @PackageNumber
      ,[LastUpdatedOn] = @CurrentDate
      ,[LastUpdatedBy] = @UserId
	  ,[ReturnsELSStatusId] = @statusId
	  ,[ShippingDate] = @ShippingDate
 WHERE ReturnsELSId = @ReturnsELSId








	END
GO