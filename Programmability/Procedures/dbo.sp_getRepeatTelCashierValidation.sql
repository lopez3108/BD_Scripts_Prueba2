SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_getRepeatTelCashierValidation] @Telephone VARCHAR(20)
AS
    BEGIN
        IF(EXISTS
        (
            SELECT 1
            FROM Users
            WHERE Telephone = @Telephone
        ))
            BEGIN
                SELECT-4;
            END;
    END;
GO