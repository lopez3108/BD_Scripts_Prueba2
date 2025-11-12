SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetMakersAddressByMakerId] @MakerId INT
AS
  SET NOCOUNT ON;

  DECLARE @IsReturn BIT = 0;
  DECLARE @IsCheck BIT = 0;


  IF EXISTS (SELECT
        rc.MakerId
      FROM ReturnedCheck rc
      WHERE rc.MakerId = @MakerId)
  BEGIN
    SET @IsReturn = 1
  END
  ELSE
  IF EXISTS (SELECT
        rc.Maker
      FROM Checks rc
      WHERE rc.Maker = @MakerId)
  BEGIN
    SET @IsCheck = 1
  END



  -------------------------------------------------

  IF (@IsReturn = 1)
  BEGIN

    SELECT TOP 1
      RC.MakerId MakerId
     ,amr.Address
     ,amr.ZipCode
     ,amr.State
     ,amr.City
     ,amr.County
     ,amr.AddressXMakerId
    FROM dbo.ReturnedCheck RC
    INNER JOIN AddressXMaker amr
      ON amr.AddressXMakerId = RC.AddressXMakerId
    WHERE RC.MakerId = @MakerId
    ORDER BY RC.CreationDate DESC
  END
  ELSE
  IF (@IsCheck = 1)
  BEGIN
    SELECT TOP 1
      C.Maker MakerId
     ,amr.Address
     ,amr.ZipCode
     ,amr.State
     ,amr.City
     ,amr.County
     ,amr.AddressXMakerId
    FROM dbo.Checks C
    INNER JOIN Makers M
      ON M.MakerId = C.Maker
    INNER JOIN AddressXMaker amr
      ON amr.MakerId = C.Maker
    WHERE C.Maker = @MakerId
    ORDER BY C.DateCashed DESC
  END

  ELSE
  BEGIN

    SELECT TOP 1
      amr.MakerId MakerId
     ,amr.Address
     ,amr.ZipCode
     ,amr.State
     ,amr.City
     ,amr.County
     ,amr.AddressXMakerId
    FROM AddressXMaker amr

    WHERE amr.MakerId = @MakerId
    ORDER BY amr.AddressXMakerId DESC
  END

GO