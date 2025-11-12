SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- =============================================
-- Author:		David Jaramillo
-- Description:	Crea una nota de cheque retornado
-- =============================================
CREATE PROCEDURE [dbo].[sp_GetCreateReturnNote]
@ReturnedCheckId INT = NULL
           ,@Note VARCHAR(300)
           ,@CreationDate DATETIME
           ,@CreatedBy INT
		 AS
		  
BEGIN

INSERT INTO [dbo].[ReturnNotes]
           ([ReturnedCheckId]
           ,[Note]
           ,[CreationDate]
           ,[CreatedBy])
     VALUES
           (@ReturnedCheckId
           ,@Note
           ,@CreationDate
           ,@CreatedBy)
            SELECT @@IDENTITY
                              
  BEGIN                 
      UPDATE ReturnedCheck set
      LastModifiedDate = @CreationDate,
      LastModifiedBy = @CreatedBy
      WHERE ReturnedCheckId = @ReturnedCheckId
     END

					 

END

GO