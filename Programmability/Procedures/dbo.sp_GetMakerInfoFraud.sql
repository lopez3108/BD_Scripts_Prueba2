SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetMakerInfoFraud] @Account VARCHAR(50) = NULL, @Maker VARCHAR (50) = NULL
AS
  SET NOCOUNT ON;

  BEGIN

    SELECT DISTINCT
  m.*
    FROM Makers m
    left JOIN dbo.AddressXMaker c ON c.MakerId = m.MakerId
    WHERE (m.Name = @Maker)

  END
   




GO