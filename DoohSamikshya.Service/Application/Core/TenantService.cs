using DoohSamikshya.DataAccess;
using DoohSamikshya.Interface.Application.Core;
using DoohSamikshya.Model.Application.Core;
using Newtonsoft.Json;

namespace DoohSamikshya.Service.Application.Core
{
    public class TenantService(IDataAccessService da) : ITenantService
    {
        public async Task<List<Tenant>?> AddTenant(Tenant tenant)
        {
            string json = JsonConvert.SerializeObject(new[] { tenant });
            string result = await da.ActionProcedure("core.SpTenentIns", json);
            return JsonConvert.DeserializeObject<List<Tenant>>(result); 
        }

        public async Task<Tenant?> DeleteTenant(int id, bool cascade = true)
        {
            string json = JsonConvert.SerializeObject(new { TenantId = id, Cascade = cascade });
            string result = await da.ActionProcedure("core.SpTenantDel", json);
            return JsonConvert.DeserializeObject<Tenant>(result);
        }

        public async Task<List<Tenant>?> GetTenant()
        {
            string json = JsonConvert.SerializeObject(new {});
            string result = await da.RetrievalProcedure("core.SpTenantSel", json);
            return JsonConvert.DeserializeObject<List<Tenant>>(result);

        }

        public async Task<List<Tenant>?> GetTenantByFilter(int offset, int pageSize, string? name, bool? isActive)
        {
            string json = JsonConvert.SerializeObject(new { Offset = offset, PageSize = pageSize, Name = name, IsActive = isActive });
            string result = await da.RetrievalProcedure("core.SpTenantPagedSel", json);
            return JsonConvert.DeserializeObject<List<Tenant>>(result);
        }

        public async Task<List<Tenant>?> UpdateTenant(Tenant tenant)
        {
            string json = JsonConvert.SerializeObject(new[] { tenant });
            string result = await da.ActionProcedure("core.SpTenentUpd", json);
            return JsonConvert.DeserializeObject <List<Tenant>>(result);
        }
    }
}
