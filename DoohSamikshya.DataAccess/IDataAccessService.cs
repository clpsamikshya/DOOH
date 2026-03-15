using System.Data;


namespace DoohSamikshya.DataAccess
{
    public interface IDataAccessService : IDisposable
    {
        Task<IDbConnection> GetConnection();
        Task<string> RetrievalProcedure(string storedProcedure, string json);

        Task<string> ActionProcedure(string storedProcedure, string json);

    }
}
