SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetPropertyBasicInformation] @PropertiesId INT
AS
     SET NOCOUNT ON;
     BEGIN
         SELECT dbo.Properties.Name,
                dbo.Properties.Address,
                dbo.ZipCodes.City,
                dbo.ZipCodes.StateAbre,
                dbo.Properties.Zipcode,
                dbo.Properties.Pin AS PIN
         FROM dbo.Properties
              INNER JOIN dbo.ZipCodes ON dbo.Properties.Zipcode = dbo.ZipCodes.ZipCode
         WHERE PropertiesId = @PropertiesId;
     END;
GO