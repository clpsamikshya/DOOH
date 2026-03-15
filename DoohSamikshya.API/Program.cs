using DoohSamikshya.DataAccess;
using DoohSamikshya.Interface.Application.Core;
using DoohSamikshya.Interface.Application.Inv;
using DoohSamikshya.Service.Application.Core;
using DoohSamikshya.Service.Application.Inv;


var builder = WebApplication.CreateBuilder(args);

// Add services to the container.

builder.Services.AddControllers();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddScoped<IDataAccessService, DataAccessService>() //Usually goes inside the DI container Middleware
                .AddScoped<IScreenService, ScreenService>()
                .AddScoped<IUserService, UserService>() //Usually goes inside the DI container Middleware
                .AddScoped<ITenantService, TenantService>();  //Usually goes inside the DI container Middleware


var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

app.Run();
