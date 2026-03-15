using DoohSamikshya.Model.Application.Core;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DoohSamikshya.Interface.Application.Core
{
    public interface IUserService
    {
        Task<User?> GetUserById(int Id);

        Task<List<User>?> GetUser();

        Task<List<User>?> AddUser(List<User> users);     

        Task<List<User>?> UpdateUser(List<User> users);   

        Task<User?> DeleteUser(int id);

    }
}
