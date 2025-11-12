SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetPropertiesById]
(@PropertiesId     INT
)
AS
     BEGIN

SELECT        dbo.Properties.PropertiesId, dbo.Properties.Name, dbo.Properties.Address, dbo.Properties.PIN, dbo.Properties.Zipcode, dbo.ZipCodes.City, dbo.ZipCodes.State, dbo.ZipCodes.StateAbre
FROM            dbo.Properties INNER JOIN
                         dbo.ZipCodes ON dbo.Properties.Zipcode = dbo.ZipCodes.ZipCode
						 WHERE dbo.Properties.PropertiesId = @PropertiesId

       
     END;
GO