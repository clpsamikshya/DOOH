using DoohSamikshya.Model.Application.Core;
using DoohSamikshya.Model.Application.Inv;


namespace DoohSamikshya.Interface.Application.Core
{
    public interface ITenantService
    {
        Task<List<Tenant>?> GetTenantByFilter(int offset, int pageSize, string? name, bool? isActive);

        Task<List<Tenant>?> GetTenant();

        Task<List<Tenant>?> AddTenant(Tenant tenant);

        Task<List<Tenant>?> UpdateTenant(Tenant tenant);

        Task<Tenant?> DeleteTenant(int id, bool cascade = true);
    }
}


