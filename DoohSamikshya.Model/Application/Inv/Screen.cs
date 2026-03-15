namespace DoohSamikshya.Model.Application.Inv
{
    public class Screen
    {
        public int? Id { get; set; }
        public string Name { get; set; } = null!;
        public string Address { get; set; } = null!;
        public int TenantId { get; set; }
        public bool IsActive { get; set; } = true;
        public decimal? CostPerContact { get; set; }
        public bool IsDeleted { get; set; } = false;
    }
}
