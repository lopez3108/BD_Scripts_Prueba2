SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_CreateMaker]
(@MakerId           INT          = NULL, 
 @Name              VARCHAR(80), 
 @ZipCode           VARCHAR(6)   = NULL, 
 @Address           VARCHAR(50)  = NULL, 
 @City              VARCHAR(255) = NULL, 
 @State             VARCHAR(255) = NULL, 
 @County            VARCHAR(255) = NULL, 
 @FileNumber        VARCHAR(12)  = NULL, 
 @EntityTypeId      INT          = NULL, 
 @IncorporationDate DATETIME     = NULL, 
 @UpdatedBy         INT          = NULL, 
 @UpdatedOn         DATETIME     = NULL, 
 @AgencyId          INT          = NULL, 
 @CreatedBy         INT          = NULL, 
 @ValidatedBy       INT          = NULL, 
 @OtherStateId      INT          = NULL, 
 @ValidatedMakerBy  INT          = NULL, 
 @CheckNoRegistered BIT          = NULL, 
 @CreationDate      DATETIME     = NULL, 
 @ValidatedMakerOn  DATETIME     = NULL,
 @AddressXMakerId           INT          = NULL,
 @IsCacheSaving BIT = NULL

)
AS
    BEGIN
        DECLARE @MakerRetunrId INT;
		        IF(EXISTS--Primero validamos que el maker name no se repita ni creando ni editando - Task 5120 dTa 
                (
                    SELECT Name
                    FROM Makers
                    WHERE (SELECT [dbo].[removespecialcharatersinstring]( UPPER(Name))) = (SELECT [dbo].[removespecialcharatersinstring]( UPPER(@Name)))
					AND ((@MakerId IS NOT NULL AND Makers.MakerId != @MakerId) OR @MakerId IS NULL )
                ))
                    BEGIN
                        SELECT-1;
                    END
					ELSE
					BEGIN
        IF(@MakerId IS NULL
           OR @MakerId = 0)
            BEGIN            
                        IF(EXISTS
                        (
                            SELECT *
                            FROM AddressXMaker
                            WHERE MakerId = @MakerId
                                  AND Address = @Address
                                  AND ZipCode = @ZipCode
                                  AND State = @State
                                  AND City = @City
                                  AND County = @County
                        ))
                            BEGIN
                                SELECT-2;
                            END;
                            ELSE
                            BEGIN


							IF(@IsCacheSaving IS NULL OR @IsCacheSaving = CAST(0 as BIT))
							BEGIN


                                INSERT INTO [dbo].[Makers]
                                ([Name], 
                                 FileNumber, 
                                 EntityTypeId, 
                                 IncorporationDate, 
                                 UpdatedBy, 
                                 UpdatedOn, 
                                 AgencyId, 
                                 CreatedBy, 
                                 ValidatedBy, 
                                 OtherStateId, 
                                 NoRegistered, 
                                 CreationDate, 
                                 ValidatedMakerBy, 
                                 ValidatedMakerOn
                                )
                                VALUES
                                (@Name, 
                                 @FileNumber, 
                                 @EntityTypeId, 
                                 @IncorporationDate, 
                                 @UpdatedBy, 
                                 @UpdatedOn, 
                                 @AgencyId, 
                                 @CreatedBy, 
                                 @ValidatedBy, 
                                 @OtherStateId, 
                                 @CheckNoRegistered, 
                                 @CreationDate, 
                                 @ValidatedMakerBy, 
                                 @ValidatedMakerOn
                                );
                                SET @MakerId =
                                (
                                    SELECT @@identity
                                );
                                IF(@Address IS NOT NULL)
                                    BEGIN
                                        INSERT INTO AddressXMaker
                                        VALUES
                                        (@MakerId, 
                                         @Address, 
                                         @ZipCode, 
                                         @State, 
                                         @City, 
                                         @County
                                        );
                                    END;
                                SELECT @MakerId;
                            END
							ELSE
							BEGIN

							SELECT 0

							END
							END
            END;
            ELSE
            BEGIN
                UPDATE [dbo].[Makers]
                  SET                         [Name] = @Name, 
                      FileNumber = @FileNumber, 
                      EntityTypeId = @EntityTypeId, 
                      IncorporationDate = @IncorporationDate, 
                      UpdatedBy = @UpdatedBy, 
                      UpdatedOn = @UpdatedOn,
                      --       ,AgencyId = @AgencyId
                      --       ,CreatedBy = @CreatedBy 
                      ValidatedBy = @ValidatedBy, 
                      OtherStateId = @OtherStateId, 
                      NoRegistered = @CheckNoRegistered, 
                      ValidatedMakerBy = @ValidatedMakerBy, 
                      ValidatedMakerOn = @ValidatedMakerOn
                      
                WHERE MakerId = @MakerId;

if(@Address IS NOT NULL)
BEGIN

IF (@AddressXMakerId is null ) 
BEGIN  
	  INSERT INTO AddressXMaker
                                        VALUES
                                        (@MakerId, 
                                         @Address, 
                                         @ZipCode, 
                                         @State, 
                                         @City, 
                                         @County
                                        );
END
ELSE

begin
         UPDATE [dbo].AddressXMaker
                  SET 
                   Address = @Address, 
                                       ZipCode=  @ZipCode, 
                                        State = @State, 
                                        City = @City, 
                                        County = @County
                WHERE AddressXMakerId = @AddressXMakerId;

               
            END;

END;
             SELECT @MakerId;
            end;
        IF(@ZipCode IS NOT NULL)
            BEGIN
                IF(NOT EXISTS
                (
                    SELECT ZipCode
                    FROM ZipCodes
                    WHERE ZipCode = @ZipCode
                ))
                    BEGIN
                        --Guardamos el zipcode en caso que no exista 
                        EXEC sp_SaveZipCode 
                             @ZipCode, 
                             @City, 
                             @State, 
                             @County;
                    END;
            END;
        SELECT 1; --RESULT OK
		END
    END;
GO