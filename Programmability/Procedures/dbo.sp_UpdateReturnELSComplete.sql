SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_UpdateReturnELSComplete]
 (

 @ReturnsELSId int,
@CurrentDate DATETIME,
@UserId INT

    )
AS 

BEGIN

declare @statusId INT
SET @statusId = (SELECT TOP 1 ReturnsELSStatusId FROM ReturnELSStatus WHERE Code = 'C03')

UPDATE [dbo].[ReturnsELS]
   SET 
      [LastUpdatedOn] = @CurrentDate
      ,[LastUpdatedBy] = @UserId
	  ,[ReturnsELSStatusId] = @statusId
 WHERE ReturnsELSId = @ReturnsELSId








	END
GO