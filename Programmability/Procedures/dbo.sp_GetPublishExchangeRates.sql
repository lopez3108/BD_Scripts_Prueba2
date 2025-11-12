SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetPublishExchangeRates]
AS
    BEGIN
        SELECT TOP 1 p.*, 
                     u.Name LastPublishName
        FROM PublishExchangeRates p
             LEFT JOIN users u ON u.UserId = p.PublishBy;
    END;
GO