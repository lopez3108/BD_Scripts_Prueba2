SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- =============================================
-- Author:		David Jaramillo
-- Description:	Crea una nota de un contrato
-- =============================================
CREATE PROCEDURE [dbo].[sp_CreateContractNote]
@ContractId INT,
 @Note VARCHAR(300)
           ,@CreationDate DATETIME
           ,@CreatedBy INT
		 AS
		  
BEGIN

INSERT INTO [dbo].[ContractNotes]
           ([ContractId]
           ,[Note]
           ,[CreationDate]
           ,[CreatedBy])
     VALUES
           (@ContractId
           ,@Note
           ,@CreationDate
           ,@CreatedBy)
                      

					  SELECT @@IDENTITY

END
GO