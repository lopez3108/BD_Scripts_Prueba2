SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- =============================================
-- Author:		David Jaramillo
-- Description:	Crea una nota de un contrato
-- =============================================
CREATE PROCEDURE [dbo].[sp_CreatePetsXContract] @ContractId     INT, 
                                                @Quantity       INT, 
                                                @PetId          INT, 
                                                @PetIdXContract INT = NULL, 
                                                @IdSaved        INT OUTPUT
AS
    BEGIN
        IF(@PetIdXContract IS NULL)
            BEGIN
                INSERT INTO [dbo].PetsXContract
                ([ContractId], 
                 Quantity, 
                 PetId 
            
                )
                VALUES
                (@ContractId, 
                 @Quantity, 
                 @PetId
          
                );
                SET @IdSaved = @@IDENTITY;
            END;
            ELSE
            BEGIN
                UPDATE [dbo].PetsXContract
                  SET 
                      ContractId = @ContractId, 
                      Quantity = @Quantity, 
                      PetId = @PetId
                WHERE PetIdXContract = @PetIdXContract;
                SET @IdSaved = @PetIdXContract;
            END;
    END;
GO