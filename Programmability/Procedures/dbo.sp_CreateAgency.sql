SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_CreateAgency]
(@AgencyId           INT            = NULL, 
 @AdminId            INT, 
 @Name               VARCHAR(50), 
 @Code               VARCHAR(10), 
 @Manager            VARCHAR(50)    = NULL, 
 @Telephone          VARCHAR(20), 
 @Telephone2         VARCHAR(20)    = NULL, 
 @Fax                VARCHAR(20)    = NULL, 
 @Email              VARCHAR(100)   = NULL, 
 @ZipCode            VARCHAR(10), 
 @State              VARCHAR(20), 
 @City               VARCHAR(20), 
 @County             VARCHAR(20)    = NULL, 
 @Address            VARCHAR(100)   = NULL, 
 @Owner              VARCHAR(50)    = NULL, 
 @IsActive           BIT, 
 @InitialBalanceCash DECIMAL(18, 2), 
 @Mid                VARCHAR(20)    = NULL, 
 @FlexxizCode        VARCHAR(4), 
 @LastInitialBalanceSaved DATETIME = null,
     @LastInitialBalanceBy INT            = NULL,
                 @AgencyCreatedOn DATETIME = null,
                 @AgencyCreatedBy INT            = NULL,
                 @AgencyLastUpdatedBy INT            = NULL,
                 @AgencyLastUpdatedOn DATETIME = null,
 @IdCreated          INT OUTPUT
)
AS
    BEGIN
        IF(NOT EXISTS
        (
            SELECT *
            FROM ZipCodes
            WHERE ZipCode = @ZipCode
        ))
            BEGIN
                INSERT INTO [dbo].[ZipCodes]
                ([ZipCode], 
                 [City], 
                 [State], 
                 [County]
                )
                VALUES
                (@ZipCode, 
                 @City, 
                 @State, 
                 @County
                );
            END;
        IF(@AgencyId IS NULL)
            BEGIN
                INSERT INTO [dbo].[Agencies]
                ([AdminId], 
                 [Name], 
                 [Code], 
                 [Manager], 
                 [Telephone], 
                 [Telephone2], 
                 [Fax], 
                 [Email], 
                 [ZipCode], 
                 [Address], 
                 [Owner], 
                 [IsActive], 
                 [InitialBalanceCash], 
                 Mid, 
                 FlexxizCode,
                 LastInitialBalanceSaved,
                 LastInitialBalanceBy,
                 AgencyCreatedOn,
                 AgencyCreatedBy,
                 AgencyLastUpdatedBy,
                 AgencyLastUpdatedOn
                )
                VALUES
                (@AdminId, 
                 @Name, 
                 @Code, 
                 @Manager, 
                 @Telephone, 
                 @Telephone2, 
                 @Fax, 
                 @Email, 
                 @ZipCode, 
                 @Address, 
                 @Owner, 
                 1, 
                 @InitialBalanceCash, 
                 @Mid, 
                 @FlexxizCode,
                 @LastInitialBalanceSaved,
                 @LastInitialBalanceBy,
                 @AgencyCreatedOn,
                 @AgencyCreatedBy,
                 @AgencyLastUpdatedBy,
                 @AgencyLastUpdatedOn
                );
                SET @IdCreated = @@IDENTITY;
            END;
            ELSE
            BEGIN
                UPDATE [dbo].[Agencies]
                  SET 
                      [AdminId] = @AdminId, 
                      [Name] = @Name, 
                      [Code] = @Code, 
                      [Manager] = @Manager, 
                      [Telephone] = @Telephone, 
                      [Telephone2] = @Telephone2, 
                      [Fax] = @Fax, 
                      [Email] = @Email, 
                      [ZipCode] = @ZipCode, 
                      [Address] = @Address, 
                      [Owner] = @Owner, 
                      [IsActive] = @IsActive, 
                      [InitialBalanceCash] = @InitialBalanceCash, 
                      LastInitialBalanceSaved= @LastInitialBalanceSaved,
                      LastInitialBalanceBy =  @LastInitialBalanceBy,
                      AgencyLastUpdatedBy = @AgencyLastUpdatedBy,
                      AgencyLastUpdatedOn =  @AgencyLastUpdatedOn,
                      Mid = @Mid, 
                      FlexxizCode = @FlexxizCode
                WHERE AgencyId = @AgencyId;
				 SET @IdCreated = @AgencyId;
                IF(@IsActive = 0)
                    BEGIN
                        DELETE [dbo].AgenciesxUser
                        WHERE AgencyId = @AgencyId;
                        DELETE [dbo].[MoneyTransferxAgencyNumbers]
                        WHERE AgencyId = @AgencyId;
                       
                    END;
            END;
    END;

GO