SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetZipCodeByCode] @ZipCode VARCHAR(10)
AS
     BEGIN
         SELECT [ZipCode],
                UPPER([City]) City,
                UPPER([State]) [State],
                [StateAbre],
                UPPER([County]) [County],
                [Latitude],
                [Longitude]
         FROM [dbo].[ZipCodes]
         WHERE [ZipCode] = @ZipCode;
     END;
GO