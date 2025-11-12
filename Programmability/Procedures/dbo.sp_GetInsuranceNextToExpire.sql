SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetInsuranceNextToExpire] @CurrentDate DATETIME, 
                                                    @Days        INT
AS
    BEGIN
        SELECT dbo.Properties.PropertiesId, 
		dbo.Properties.PropertiesId as PropertyId, 
               dbo.Insurance.InsuranceId, 
               dbo.Properties.PolicyStartDate, 
               dbo.Properties.PolicyEndDate, 
               dbo.Properties.PersonInCharge, 
               dbo.Insurance.Name AS InsuranceName, 
               dbo.Properties.Name AS PropertyName, 
               'NextToExpire' AS InsuranceStatus, 
        (
            SELECT TOP 1 Message
            FROM FinancingMessages
            WHERE Title = 'PROPERTY INSURANCE NEXT TO EXPIRE'
        ) AS ExpiredMessage, 
        (
            SELECT TOP 1 FinancingMessageId
            FROM FinancingMessages
            WHERE Title = 'PROPERTY INSURANCE NEXT TO EXPIRE'
        ) AS FinancingMessageId, 
        (
            SELECT TOP 1 SMSCategoryId
            FROM FinancingMessages
            WHERE Title = 'PROPERTY INSURANCE NEXT TO EXPIRE'
        ) AS MessageCategoryId, 
        (
            SELECT TOP 1 AdminId
            FROM Admin
        ) AS AdminId,
               CASE
                   WHEN DATEDIFF(day, @CurrentDate, dbo.Properties.PolicyEndDate) < 0
                   THEN(DATEDIFF(day, @CurrentDate, dbo.Properties.PolicyEndDate) * -1)
                   ELSE DATEDIFF(day, @CurrentDate, dbo.Properties.PolicyEndDate)
               END AS DaysToExpire, 
               Properties.PersonInChargeTelephone AS Telephone, 
        (
            SELECT TOP 1 AgencyId
            FROM Agencies
            WHERE IsActive = 1
        ) AS AgencyId, 
        (
            SELECT TOP 1 Name
            FROM Agencies
            WHERE IsActive = 1
        ) AS AgencyName, 
        (
            SELECT TOP 1 Telephone
            FROM Agencies
            WHERE IsActive = 1
        ) AS AgencyPhone
        FROM dbo.Properties
             INNER JOIN dbo.Insurance ON dbo.Properties.InsuranceId = dbo.Insurance.InsuranceId
        WHERE DATEDIFF(day, @CurrentDate, dbo.Properties.PolicyEndDate) = @Days
        UNION ALL
        SELECT dbo.Properties.PropertiesId, 
		dbo.Properties.PropertiesId  as PropertyId, 
               dbo.Insurance.InsuranceId, 
               dbo.Properties.PolicyStartDate, 
               dbo.Properties.PolicyEndDate, 
               dbo.Properties.PersonInCharge, 
               dbo.Insurance.Name AS InsuranceName, 
               dbo.Properties.Name AS PropertyNamepr1, 
               'Expired' AS InsuranceStatus, 
        (
            SELECT TOP 1 Message
            FROM FinancingMessages
            WHERE Title = 'PROPERTY INSURANCE EXPIRED'
        ) AS ExpiredMessage, 
        (
            SELECT TOP 1 FinancingMessageId
            FROM FinancingMessages
            WHERE Title = 'PROPERTY INSURANCE EXPIRED'
        ) AS FinancingMessageId, 
        (
            SELECT TOP 1 SMSCategoryId
            FROM FinancingMessages
            WHERE Title = 'PROPERTY INSURANCE EXPIRED'
        ) AS MessageCategoryId, 
        (
            SELECT TOP 1 AdminId
            FROM Admin
        ) AS AdminId,
               CASE
                   WHEN DATEDIFF(day, @CurrentDate, dbo.Properties.PolicyEndDate) < 0
                   THEN(DATEDIFF(day, @CurrentDate, dbo.Properties.PolicyEndDate) * -1)
                   ELSE DATEDIFF(day, @CurrentDate, dbo.Properties.PolicyEndDate)
               END AS DaysToExpire, 
               Properties.PersonInChargeTelephone AS Telephone, 
        (
            SELECT TOP 1 AgencyId
            FROM Agencies
            WHERE IsActive = 1
        ) AS AgencyId, 
        (
            SELECT TOP 1 Name
            FROM Agencies
            WHERE IsActive = 1
        ) AS AgencyName, 
        (
            SELECT TOP 1 Telephone
            FROM Agencies
            WHERE IsActive = 1
        ) AS AgencyPhone
        FROM dbo.Properties
             INNER JOIN dbo.Insurance ON dbo.Properties.InsuranceId = dbo.Insurance.InsuranceId
        WHERE DATEDIFF(day, @CurrentDate, dbo.Properties.PolicyEndDate) < 0;
    END;
GO