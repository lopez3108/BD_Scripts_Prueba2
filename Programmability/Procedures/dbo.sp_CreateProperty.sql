SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- =============================================
-- Author:		David Jaramillo
-- Description:	Creates a new property
-- =============================================

-- 2024-07-24 DJ/5973: Adding column ZelleEmail
-- =============================================
-- Author:     JF
-- Create date: 4/09/2024 3:54 p. m.
-- Database:    developing
-- Description: task 6042 Ajustes formulario property
-- =============================================

CREATE PROCEDURE [dbo].[sp_CreateProperty] @PropertiesId              INT            = NULL, 
                                          @Name                      VARCHAR(40), 
                                          @Address                   VARCHAR(50), 
                                          @Zipcode                   VARCHAR(6), 
                                          @City                      VARCHAR(20), 
                                          @State                     VARCHAR(20), 
                                          @InsuranceId               INT            = NULL, 
                                          @Telephone                 VARCHAR(50)    = NULL, 
                                          @PolicyNumber              VARCHAR(20)    = NULL, 
                                          @PolicyStartDate           DATETIME       = NULL, 
                                          @PolicyEndDate             DATETIME       = NULL, 
                                          @County                    VARCHAR(30)    = NULL, 
                                          @PersonInCharge            VARCHAR(40)    = NULL, 
                                          @BillNumber                VARCHAR(20)    = NULL, 
                                          @PersonInChargeTelephone   VARCHAR(10), 
                                          @PropertyValue             DECIMAL(18, 2), 
                                          @PurchaseDate              DATETIME, 
                                          @PIN                       VARCHAR(20), 
                                          @InsuranceContactName      VARCHAR(50)    = NULL, 
                                          @InsuranceContactTelephone VARCHAR(50)    = NULL, 
                                          @CreationDate              DATETIME, 
                                          @CreatedBy                 INT,                                        
                                          @AddressCorporation        VARCHAR(50)    = NULL, 
                                          @EmailCorporation          VARCHAR(50)    = NULL ,
                                          @TrustNumber               VARCHAR(16)  = NULL,
                                          @Zelle  VARCHAR(10)  = NULL,
                                          @BankAccountId  INT = null,
                                          @ZelleEmail  VARCHAR(100)  = NULL,
                                          @TrustCompany              VARCHAR(16)  = NULL
AS
    BEGIN
        IF(NOT EXISTS
        (
            SELECT 1
            FROM ZipCodes
            WHERE ZipCode = @Zipcode
        ))
            BEGIN
                INSERT INTO [dbo].[ZipCodes]
                ([ZipCode], 
                 [City], 
                 [State], 
                 [County]
                )
                VALUES
                (@Zipcode, 
                 @City, 
                 @State, 
                 @County
                );
            END;
        IF(@PropertiesId IS NULL)
            BEGIN
                IF(EXISTS
                (
                    SELECT 1
                    FROM Properties
                    WHERE Name = @Name
                ))
                    BEGIN
                        SELECT-1;
                    END;
                    ELSE
                    BEGIN
                        INSERT INTO [dbo].[Properties]
                        ([Name], 
                         [Address], 
                         [Zipcode], 
                         [City], 
                         [State], 
                         [InsuranceId], 
                         [Telephone], 
                         [PolicyNumber], 
                         [County], 
                         [PersonInCharge], 
                         [PolicyStartDate], 
                         [PolicyEndDate], 
                         [BillNumber], 
                         [PersonInChargeTelephone], 
                         PropertyValue, 
                         PurchaseDate, 
                         PIN, 
                         InsuranceContactName, 
                         InsuranceContactTelephone, 
                         CreationDate, 
                         CreatedBy,
                        AddressCorporation,
                        EmailCorporation,
                        TrustNumber,
                        Zelle,
                        BankAccountId,
                        ZelleEmail,
                        TrustCompany 

                        )
                        VALUES
                        (@Name, 
                         @Address, 
                         @Zipcode, 
                         @City, 
                         @State, 
                         @InsuranceId, 
                         @Telephone, 
                         @PolicyNumber, 
                         @County, 
                         @PersonInCharge, 
                         @PolicyStartDate, 
                         @PolicyEndDate, 
                         @BillNumber, 
                         @PersonInChargeTelephone, 
                         @PropertyValue, 
                         @PurchaseDate, 
                         @PIN, 
                         @InsuranceContactName, 
                         @InsuranceContactTelephone, 
                         @CreationDate, 
                         @CreatedBy,
                        @AddressCorporation,
                        @EmailCorporation,
                        @TrustNumber ,
                        @Zelle,
                        @BankAccountId,
                        @ZelleEmail,
                        @TrustCompany 
                        );
                        DECLARE @propertyId INT;
                        SET @propertyId =
                        (
                            SELECT @@IDENTITY
                        );
                        INSERT INTO [dbo].[PropertyControlsXProperty]
                               SELECT pr.[PropertyControlId], 
                                      @propertyId, 
                                      NULL, 
                                      @CreationDate, 
                                      NULL, 
                                      0, 
                                      @CreationDate, 
                                      @CreatedBy, 
                                      1, 
                                      NULL, 
                                      NULL, 
                                      NULL
                               FROM [dbo].[PropertyControls] pr
							   WHERE CAST(pr.CheckProperty as BIT) = CAST(1 as BIT) 
                        SELECT @propertyId;
                    END;
            END;
            ELSE
            BEGIN
                UPDATE [dbo].[Properties]
                  SET 
                      [Name] = @Name, 
                      [Address] = @Address, 
                      [Zipcode] = @Zipcode, 
                      [City] = @City, 
                      [State] = @State, 
                      [InsuranceId] = @InsuranceId, 
                      [Telephone] = @Telephone, 
                      [PolicyNumber] = @PolicyNumber, 
                      [County] = @County, 
                      [PersonInCharge] = @PersonInCharge, 
                      [PolicyStartDate] = @PolicyStartDate, 
                      [PolicyEndDate] = @PolicyEndDate, 
                      [BillNumber] = @BillNumber, 
                      [PersonInChargeTelephone] = @PersonInChargeTelephone, 
                      PropertyValue = @PropertyValue, 
                      PurchaseDate = @PurchaseDate, 
                      PIN = @PIN, 
                      InsuranceContactTelephone = @InsuranceContactTelephone, 
                      InsuranceContactName = @InsuranceContactName,
                      AddressCorporation = @AddressCorporation,
                      EmailCorporation= @EmailCorporation,
                      TrustNumber = @TrustNumber,
                      Zelle = @Zelle,
                      BankAccountId = @BankAccountId,
                      ZelleEmail = @ZelleEmail,
                      TrustCompany  = @TrustCompany
                      WHERE PropertiesId = @PropertiesId;
                      SELECT @PropertiesId;
            END;
    END;


GO