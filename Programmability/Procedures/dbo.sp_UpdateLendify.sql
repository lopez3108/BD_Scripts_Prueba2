SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_UpdateLendify]

@LendifyId INT,
@Name VARCHAR(60),
@Telephone VARCHAR(10),
@LendifyStatusId INT,
@CreationDate DATETIME,
@CreatedBy INT,
@AgencyId INT,
@AprovedDate DATETIME = NULL,
@AprovedBy INT = NULL,
@ComissionCashier DECIMAL (18, 2) = NULL,
@CommissionAgency DECIMAL (18, 2) = NULL

AS
    BEGIN

	UPDATE [dbo].[Lendify]
	SET LendifyStatusId = @LendifyStatusId
		,AprovedDate = @AprovedDate
		,AprovedBy = @AprovedBy
		,ComissionCashier= @ComissionCashier
		,CommissionAgency= @CommissionAgency
    WHERE LendifyId = @LendifyId

	SELECT @LendifyId

END;
GO