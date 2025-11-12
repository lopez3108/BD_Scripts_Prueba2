SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllRentPaymentsAndDepositsByAgencyId] @AgencyId     INT,
                                                                   @CreationDate DATE = NULL,
                                                                   @UserId       INT = NULL
AS
     SET NOCOUNT ON;
     BEGIN
         SELECT *,
                ISNULL((QUERY.RentPayments + QUERY.DepositPayments +  QUERY.FeeDue) - QUERY.DepositRefunds, 0) AS Total
         FROM
         (
             SELECT ISNULL(
                          (
                              SELECT SUM(ISNULL(RP.Usd, 0))
                              FROM RentPayments RP
                                   INNER JOIN Agencies a ON RP.AgencyId = a.AgencyId
                                   INNER JOIN Users u ON RP.CreatedBy = u.UserId
                              WHERE RP.AgencyId = @AgencyId
                                    AND (CAST(RP.CreationDate AS DATE) = CAST(@CreationDate AS DATE)
                                         OR @CreationDate IS NULL)
                                    AND RP.CreatedBy = @UserId
                          ), 0) RentPayments,
                    ISNULL(
                          (
                              SELECT SUM(ISNULL(DP.Usd, 0))
                              FROM DepositFinancingPayments DP
                                   INNER JOIN Agencies a ON DP.AgencyId = a.AgencyId
                                   INNER JOIN Users u ON DP.CreatedBy = u.UserId
                              WHERE DP.AgencyId = @AgencyId
                                    AND (CAST(DP.CreationDate AS DATE) = CAST(@CreationDate AS DATE)
                                         OR @CreationDate IS NULL)
                                    AND DP.CreatedBy = @UserId
                          ), 0) DepositPayments,
                    ISNULL(
                          (
                              SELECT SUM(ISNULL(c.RefundUsd, 0))
                              FROM Contract c
                                   INNER JOIN Agencies a ON c.AgencyId = a.AgencyId
                                   INNER JOIN Users u ON c.CreatedBy = u.UserId
                              WHERE c.AgencyRefundId = @AgencyId
                                    AND (CAST(c.RefundDate AS DATE) = CAST(@CreationDate AS DATE)
                                         OR @CreationDate IS NULL)
                                    AND c.RefundBy = @UserId
                          ), 0) DepositRefunds,
                    ISNULL(
                          (
                              SELECT SUM(ISNULL(RP.FeeDue, 0))
                              FROM RentPayments RP
                                   INNER JOIN Agencies a ON RP.AgencyId = a.AgencyId
                                   INNER JOIN Users u ON RP.CreatedBy = u.UserId
                              WHERE RP.AgencyId = @AgencyId
                                    AND (CAST(RP.CreationDate AS DATE) = CAST(@CreationDate AS DATE)
                                         OR @CreationDate IS NULL)
                                    AND RP.CreatedBy = @UserId
                          ), 0) FeeDue
         ) QUERY;
     END;
GO