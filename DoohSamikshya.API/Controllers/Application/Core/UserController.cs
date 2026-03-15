using DoohSamikshya.API.Controllers.Shared;
using DoohSamikshya.Interface.Application.Core;
using DoohSamikshya.Model.Application.Core;
using DoohSamikshya.Model.Shared;
using Microsoft.AspNetCore.Mvc;

namespace DoohSamikshya.API.Controllers.Application.Core
{
    public class UserController(IUserService us) : SharedController
    {
   
        [HttpGet]
        public async Task<IActionResult> GetUser()
        {
            try
            {
                var response = await us.GetUser();
                return Ok(ApiResponse.Success(response));

            }
            catch (Exception ex)
            {
                return BadRequest(ApiResponse.Fail(ex.Message));
            }
        }
        

        [HttpGet("{Id}")]
        public async Task<IActionResult> GetUserById([FromRoute] int Id)
        {
            try
            {
                var response = await us.GetUserById(Id);
                return Ok(ApiResponse.Success(response));
            }
            catch (Exception ex)
            {
                return BadRequest(ApiResponse.Fail(ex.Message));
            }

        }
       
        [HttpPost]
        public async Task<IActionResult> AddUser([FromBody] List<User> users)
        {
            try
            {
                var response = await us.AddUser(users);
                return Ok(ApiResponse.Success(response));
            }
            catch (Exception ex)
            {
                return BadRequest(ApiResponse.Fail(ex.Message));
            }
        }
       
        [HttpPut]
        public async Task<IActionResult> UpdateUser([FromBody] List<User> users)
        {
            try
            {
                var response = await us.UpdateUser(users);
                return Ok(ApiResponse.Success(response));
            }
            catch (Exception ex)
            {
                return BadRequest(ApiResponse.Fail(ex.Message));
            }
        }

        
        [HttpDelete("{Id}")]
        public async Task<IActionResult> Deleteuser([FromRoute] int Id)
        {
            try
            {
                var response = await us.DeleteUser(Id);
                return Ok(ApiResponse.Success(response));

            }
            catch (Exception ex)
            {
                return BadRequest(ApiResponse.Fail(ex.Message));
            }
        }
      

    }
}
