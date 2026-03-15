using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DoohSamikshya.Model.Application.Core
{
    public class User
    {
            public int? Id { get; set; }
            public string? UserName { get; set; }
            public string? Password { get; set; }
            public string? Email { get; set; }
            public int TenantId { get; set; }
            public bool IsActive { get; set; } = true;
            public bool IsDeleted { get; set; } = false;
            public int CreatedBy { get; set; }
            public UserInfo? UserInfo { get; set; }
        

    }
}
