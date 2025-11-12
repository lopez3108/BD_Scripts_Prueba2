SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_DeletePhoneSaleById](@PhoneSalesId INT)
AS
    BEGIN
        DELETE FROM PhoneSales
        WHERE PhoneSalesId = @PhoneSalesId;
    END;
GO