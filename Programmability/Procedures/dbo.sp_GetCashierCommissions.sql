SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetCashierCommissions]
AS
    BEGIN
    -- 2025-01-18 JF/6293: Habilitar comisiones insurance a los cajeros para los nuevos servicios
        SELECT U.Name, 
               U.UserId, 
               C.CashierId,
               u1.Name AS CreatedByNameCitySticker,
               u2.Name AS CreatedByNamePlateSticker,
               u3.Name AS CreatedByNameTitlesAndPlates,
               u5.Name AS CreatedByNameTelephones,
               u4.Name AS CreatedBynameTrp,
               u6.Name AS CreatedBynameLendify,
               u7.Name AS CreatedByNameTickets, 
               u8.Name AS CreatedByNameNewPolicy, 
               u9.Name AS CreatedByNameMonthlyPayment,
               u10.Name AS CreatedByNameRegistrationRelease,
               u11.Name AS CreatedByNameEndorsement,
               u12.Name AS CreatedByNamePolicyRenewal,
               CA.*
        FROM Users U
             INNER JOIN Cashiers C ON C.UserId = U.UserId
             LEFT JOIN CashierApplyComissions CA ON CA.CashierId = c.CashierId
             LEFT JOIN Users u1 ON ca.CreatedByCitySticker = u1.UserId   
              LEFT JOIN Users u2 ON ca.CreatedByPlateSticker = u2.UserId 
              LEFT JOIN Users u3 ON ca.CreatedByTitlesAndPlates = u3.UserId 
              LEFT JOIN Users u4 ON ca.CreatedByTrp = u4.UserId 
              LEFT JOIN Users u5 ON ca.CreatedByTelephones = u5.UserId 
              LEFT JOIN Users u6 ON ca.CreatedByLendify = u6.UserId 
              LEFT JOIN Users u7 ON ca.CreatedByTickets = u7.UserId 
              LEFT JOIN Users u8 ON ca.CreatedByNewPolicy = u8.UserId 
              LEFT JOIN Users u9 ON ca.CreatedByMonthlyPayment = u9.UserId 
              LEFT JOIN Users u10 ON ca.CreatedByRegistrationRelease = u10.UserId 
              LEFT JOIN Users u11 ON ca.CreatedByEndorsement = u11.UserId 
              LEFT JOIN Users u12 ON ca.CreatedByPolicyRenewal = u12.UserId 
        WHERE C.IsActive = 1
              AND C.IsComissions = 1
        ORDER BY U.Name ASC;
    END;



GO