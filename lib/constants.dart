/// Average deposit per container in euro, used ONLY for the approximate
/// "items recycled" estimate in Lifetime Stats.
///
/// Real deposits are 15c or 25c per container, so this is a rough average.
/// It is a constant (not a per-voucher average) because dividing the lifetime
/// credit by one number is O(1) each time a voucher is added.
const double kAvgDepositEuro = 0.20;
