SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetAllCheckFraudMaker] @Name VARCHAR(100) = NULL
AS
  SET NOCOUNT ON
  BEGIN

    SELECT DISTINCT
      *
    FROM (SELECT DISTINCT
        fa.Maker AS Maker
       ,fa.MakerAddress
      FROM dbo.FraudAlert fa
      UNION ALL
      SELECT DISTINCT
        m.Name AS Maker
       ,(SELECT TOP 1
            ax.Address
          FROM dbo.AddressXMaker ax
          WHERE ax.MakerId = m.MakerId ORDER BY ax.AddressXMakerId DESC)
      FROM Makers m) AS allMakers

    WHERE (allMakers.Maker LIKE '%' + @Name + '%'
    OR @Name IS NULL)

  END;


GO