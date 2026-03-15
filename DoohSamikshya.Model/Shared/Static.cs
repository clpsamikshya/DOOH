

namespace DoohSamikshya.Model.Shared
{
    public static class ApiResponse
    {
        public static ApiResponse<T> Success<T>(T data, string message = "Success")
        {
            return new ApiResponse<T>
            {
                Success = true,
                Message = message,
                Data = data
            };
        }

        public static ApiResponse<object> Fail(string message, object? errors = null)
        {
            return new ApiResponse<object>
            {
                Success = false,
                Message = message,
                Errors = errors
            };
        }
    }
}




