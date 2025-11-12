SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllBirthDaysToday] @Date DATETIME
AS
     SET NOCOUNT ON;
     BEGIN
         SELECT Name ClientName,
                Telephone
         FROM Users
         WHERE MONTH(BirthDay) = MONTH(@Date) AND DAY(BirthDay) = DAY(@Date)
         UNION
         SELECT Name ClientName,
                Telephone
         FROM DocumentInformation
	   WHERE MONTH(Doc1Birth) = MONTH(@Date) AND DAY(Doc1Birth) = DAY(@Date)
     END;
GO