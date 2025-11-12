SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--------------------------------Este sp no se utiliza-------------------  14/03/2023  

CREATE PROCEDURE [dbo].[sp_GenerateFirstLoginDaily]   
(@AgencyId  INT,
 @CashierId INT
)
AS
-- exec [dbo].[sp_GenerateFirstLoginDaily]  16, 15
    BEGIN TRY
        BEGIN TRANSACTION;
        DECLARE @IdCreated INT;
        DECLARE @IdCreatedTime INT;
        DECLARE @UserId INT;
        SET @UserId =
        (
            SELECT UserId
            FROM Cashiers
            WHERE CashierId = @CashierId
        );
        INSERT INTO [dbo].[Daily ]
        (CashierId,
         AgencyId,
         CreationDate
        )
        VALUES
        (@CashierId,
         @AgencyId,
         GETDATE()
        );
        SET @IdCreated = @@IDENTITY;
        INSERT INTO TimeSheet
        (UserId,
         AgencyId,
         LoginDate  
        )
        VALUES
        (@UserId,
         @AgencyId,
         GETDATE()
        );
        SET @IdCreatedTime = @@IDENTITY;
        IF(@IdCreatedTime > 0
           AND @IdCreated > 0)
            BEGIN
                COMMIT;
			 SELECT  @IdCreatedTime
        END;
            ELSE
            BEGIN
                ROLLBACK;
			  SELECT 'ERROR'
        END;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;
        SELECT ERROR_MESSAGE();
    END CATCH;

GO