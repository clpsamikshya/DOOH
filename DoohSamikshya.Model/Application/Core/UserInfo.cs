using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DoohSamikshya.Model.Application.Core
{
    public class UserInfo
    {
        public int UserId { get; set; }
        public string? FirstName { get; set; }
        public string? MiddleName { get; set; }
        public string? LastName { get; set; }
        public DateOnly? Dob { get; set; }
        public int? Gender { get; set; }
        public string? ContactNo { get; set; }
        public int CreatedBy { get; set; }
        public bool IsDeleted { get; set; } = false;
    }
}
