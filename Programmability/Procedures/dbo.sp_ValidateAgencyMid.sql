SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_ValidateAgencyMid] (@AgencyId INT)
AS
BEGIN
  SELECT
    CASE
      WHEN a.Mid IS NOT NULL AND LEN( a.Mid) > 2   THEN CAST(1 AS BIT)

      ELSE CAST(0 AS BIT)

    END AS HasAgencyMid,
    a.Mid

  FROM Agencies a
  WHERE a.AgencyId = @AgencyId
END
GO