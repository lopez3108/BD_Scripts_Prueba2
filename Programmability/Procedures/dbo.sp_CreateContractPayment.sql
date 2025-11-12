SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CreateContractPayment]
 (
	  @ContractId int,
      @Date DATETIME,
	  @USD DECIMAL(18,2)

    )
AS 

BEGIN

INSERT INTO [dbo].[ContractPayment]
           ([ContractId]
           ,[Date]
           ,[USD])
     VALUES
           (@ContractId
           ,@Date
           ,@USD)

		   SELECT @@IDENTITY

	END
GO