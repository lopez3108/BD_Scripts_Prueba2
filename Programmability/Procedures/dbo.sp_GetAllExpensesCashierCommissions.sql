SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetAllExpensesCashierCommissions] @AgencyId  INT NULL, 
                                                            @CashierId INT, 
                                                            @Month     INT, 
                                                            @Year      INT
AS
     SET NOCOUNT ON;
    BEGIN
        SELECT e.ExpenseId, 
               e.MonthsId, 
               e.Year, 
               e.Usd, 
               e.Usd 'moneyvalue', 
               e.Usd 'Value', 
               'true' 'OnlyNegative', 
               'true' 'AcceptNegative', 
               'true' 'Set', 
               ISNULL(e.PlateSticker, 0) PlateSticker, 
               ISNULL(e.PlateStickerCommission, 0) PlateStickerCommission, 
               ISNULL(e.CitySticker, 0) CitySticker, 
               ISNULL(e.CityStickerCommission, 0) CityStickerCommission, 
               ISNULL(e.Notary, 0) Notary, 
               ISNULL(e.NotaryCommission, 0) NotaryCommission, 
               ISNULL(e.Telephones, 0) Telephones, 
               ISNULL(e.TelephonesCommission, 0) TelephonesCommission, 
               ISNULL(e.TitlesAndPlates, 0) TitlesAndPlates, 
               ISNULL(e.TitlesAndPlatesCommission, 0) TitlesAndPlatesCommission, 
               ISNULL(e.TitlesAndPlatesManual, 0) TitlesAndPlatesManual, 
               ISNULL(e.TitlesAndPlatesManualCommission, 0) TitlesAndPlatesManualCommission, 
               ISNULL(e.Trp730, 0) Trp730, 
               ISNULL(e.Trp730Commissions, 0) Trp730Commissions, 
               ISNULL(e.Financing, 0) Financing, 
               ISNULL(e.FinancingCommission, 0) FinancingCommission, 
               ISNULL(e.ParkingTicket, 0) ParkingTicket, 
               ISNULL(e.ParkingTicketCommission, 0) ParkingTicketCommission, 
               ISNULL(e.ParkingTicketCard, 0) ParkingTicketCard, 
               ISNULL(e.ParkingTicketCardCommission, 0) ParkingTicketCardCommission, 
               ISNULL(e.Lendify, 0) Lendify, 
               ISNULL(e.LendifyCommission, 0) LendifyCommission, 
               ISNULL(e.Tickets, 0) Tickets, 
               ISNULL(e.TicketsCommission, 0) TicketsCommission
        FROM Expenses  E (NOLOCK)
             INNER JOIN Agencies a ON e.AgencyId = a.AgencyId
             INNER JOIN Cashiers u ON e.CashierId = u.CashierId
             INNER JOIN Months M ON e.MonthsId = M.MonthId
        WHERE(m.Number = @Month)
             AND (e.Year = @Year)
             AND e.CashierId = @CashierId AND e.AgencyId = @AgencyId
    END;


GO