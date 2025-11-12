SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_CreateSuspiciousActivityNote]
@SuspiciousActivityId INT,
@Note VARCHAR(300),
@CreatedBy INT,
@CreationDate DATETIME
AS
     SET NOCOUNT ON;
    BEGIN
        

		INSERT INTO [dbo].[SuspiciousActivityNotes]
           ([SuspiciousActivityId]
           ,[Note]
           ,[CreationDate]
           ,[CreatedBy])
     VALUES
           (@SuspiciousActivityId
           ,@Note
           ,@CreationDate
           ,@CreatedBy)



		   SELECT @@IDENTITY

    END;
GO