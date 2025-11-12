SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_SaveMsb]
(@MsbId          INT          = NULL, 
 @CreationDate   DATETIME, 
 @DocumentName   VARCHAR(400), 
 @LastUpdatedOn  DATETIME, 
 @LastUpdatedBy  INT, 
 @CreatedBy      INT, 
 @ExpirationDate DATETIME, 
 @IdCreated      INT OUTPUT
)
AS
    BEGIN
        IF(@MsbId IS NULL)
            BEGIN



DECLARE @maxExpirationDate DATETIME
	SET @maxExpirationDate = ISNULL((SELECT TOP 1 ExpirationDate FROM dbo.Msb ORDER BY ExpirationDate DESC), @CreationDate)


	IF(@maxExpirationDate >= @ExpirationDate AND EXISTS(SELECT * FROM Msb))
	BEGIN

	SET @IdCreated = -1


	END
	ELSE
	BEGIN

                INSERT INTO [dbo].Msb
                (CreationDate, 
                 ExpirationDate, 
                 DocumentName, 
                 CreatedBy, 
                 LastUpdatedOn, 
                 LastUpdatedBy
                )
                VALUES
                (@CreationDate, 
                 @ExpirationDate, 
                 @DocumentName, 
                 @CreatedBy, 
                 @LastUpdatedOn, 
                 @LastUpdatedBy
                );
                SET @IdCreated = @@IDENTITY;
				END
            END;
            ELSE
            BEGIN
                UPDATE [dbo].Msb
                  SET 
                      CreationDate = @CreationDate, 
                      ExpirationDate = @ExpirationDate, 
                      DocumentName = @DocumentName, 
                      LastUpdatedOn = @LastUpdatedOn, 
                      LastUpdatedBy = @LastUpdatedBy
                WHERE MsbId = @MsbId;
                SET @IdCreated = @MsbId;
            END;
    END;
GO