SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
--(select code from PasswordChangeSettins where IsDefault = 1) as code
-- CASE
--WHEN code ='C04' THEN 'Director'
--WHEN Salary >=50000 AND Salary <80000 THEN 'Senior Consultant'
--Else 'Director'
--END AS Designation
----ASIGNAR VARIABLES DE FECHAS
----DIFERENCIA DE DIAS
----CASE PROGUNTA POR LA DIFENCIA Y LA CONFIGURACION
--SELECT * FROM USERS
--DECLARE @LastChangeDate date, @Date date;
--set @LastChangeDate = (SELECT CAST(LastPasswordChangeDate as date) FROM USERS where UserId = @userId)
--sELECT * FROM USERS

CREATE PROCEDURE [dbo].[sp_ValidatePassword]
(@Name VARCHAR(50), 
 @Date DATETIME    = NULL
)
AS
    BEGIN
        DECLARE @LastChangeDate DATE, @DaysDiferent INT, @ConfigurationCode VARCHAR(3);
        SET @LastChangeDate =
        (
            SELECT top 1  CAST(LastPasswordChangeDate AS DATE)
            FROM USERS
            WHERE((@Name LIKE '%@%'
                   AND UPPER([User]) = UPPER(@Name))
                  OR UPPER(Telephone) = (@Name))
        );
        SET @DaysDiferent = DATEDIFF(DAY, @LastChangeDate, CAST(@Date AS DATE));
        SET @ConfigurationCode =
        (
            SELECT code
            FROM PasswordChangeSettins
            WHERE IsDefault = 1
        );
        SELECT top 1 (CASE
                   WHEN @ConfigurationCode = 'C02'
                        AND @DaysDiferent >= 90
                   THEN CAST(1 AS BIT)
                   WHEN @ConfigurationCode = 'C03'
                        AND @DaysDiferent >= 180
                   THEN CAST(1 AS BIT)
                   WHEN @ConfigurationCode = 'C04'
                        AND @DaysDiferent >= 365
                   THEN CAST(1 AS BIT)
                   ELSE CAST(0 AS BIT)
               END) AS NeedChange, 
              UserId
        FROM users
        WHERE((@Name LIKE '%@%'
               AND UPPER([User]) = UPPER(@Name))
              OR UPPER(Telephone) = (@Name));
    END;
GO