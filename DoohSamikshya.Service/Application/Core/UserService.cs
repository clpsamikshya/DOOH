using DoohSamikshya.DataAccess;
using DoohSamikshya.Interface.Application.Core;
using DoohSamikshya.Model.Application.Core;
using Newtonsoft.Json;

namespace DoohSamikshya.Service.Application.Core
{
    public class UserService(IDataAccessService da) : IUserService
    {
        public async Task<List<User>?> AddUser(List<User> users)
        {
            string json = JsonConvert.SerializeObject(users);
            string result = await da.ActionProcedure("core.SpUserIns", json);
            return JsonConvert.DeserializeObject<List<User>>(result);
        }

        public async Task<User?> DeleteUser(int id)
        {
            string json = JsonConvert.SerializeObject(id);
            string result = await da.ActionProcedure("core.SpTenantIns", json);
            return JsonConvert.DeserializeObject<User>(result);
        }

        public async Task<List<User>?> GetUser()
        {
            string json = JsonConvert.SerializeObject(new { });
            string result = await da.RetrievalProcedure("core.SpTenantSel", json);
            return JsonConvert.DeserializeObject<List<User>>(result);
        }

        public async Task<User?> GetUserById(int Id)
        {
            string json = JsonConvert.SerializeObject(Id);
            string result = await da.RetrievalProcedure("core.SpTenantSel", json);
            return JsonConvert.DeserializeObject<User>(result);
        }

        public async Task<List<User>?> UpdateUser(List<User> users)
        {
            string json = JsonConvert.SerializeObject(users);
            string result = await da.ActionProcedure("core.SpUserUpd", json);
            return JsonConvert.DeserializeObject<List<User>>(result);
        }
    }
}
