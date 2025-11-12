SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_SaveRegisteredMacs] @RegisteredMacId INT = NULL,
@Mac VARCHAR(30),
@Description VARCHAR(30),
@ComputerBrand VARCHAR(30) = NULL,
@CreatedBy INT,
@AgencyId INT,
@CreationDate DATETIME
AS
BEGIN
  IF @RegisteredMacId IS NULL
  BEGIN
    INSERT INTO RegisteredMacs (Mac,
    Description,
    ComputerBrand,
    CreatedBy,
    CreationDate,
    AgencyId)
      VALUES (@Mac, @Description, @ComputerBrand, @CreatedBy, @CreationDate, @AgencyId);
  END;
  ELSE
  BEGIN
    UPDATE RegisteredMacs
    SET Mac = @Mac
       ,Description = @Description
       ,ComputerBrand = @ComputerBrand
       ,CreatedBy = @CreatedBy
       ,CreationDate = @CreationDate
       ,AgencyId = @AgencyId
    WHERE RegisteredMacId = @RegisteredMacId;
  END;
END;
GO