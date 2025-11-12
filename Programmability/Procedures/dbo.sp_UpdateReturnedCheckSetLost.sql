SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_UpdateReturnedCheckSetLost]
 (
      @ReturnedCheckId int,
	  @Note varchar(300),
	  @CreationDate DATETIME,
	  @CreatedBy INT
    )
AS 

BEGIN

UPDATE [dbo].[ReturnedCheck]
   SET 
      [StatusId] = (SELECT TOP 1 ReturnStatusId FROM ReturnStatus WHERE Code = 'C03')   
	  ,LostBy = @CreatedBy
	  ,LostDate = @CreationDate
 WHERE ReturnedCheckId = @ReturnedCheckId

 
 EXEC sp_CreateReturnNote @ReturnedCheckId,@Note, @CreationDate, @CreatedBy


	END
GO