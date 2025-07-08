var builder = WebApplication.CreateBuilder(args);

builder.AddServiceDefaults();

// Add services to the container.

builder.Services.AddControllers();
// Learn more about configuring OpenAPI at https://aka.ms/aspnet/openapi
builder.Services.AddOpenApi();

// Add CORS for Flutter web app
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowLocalhost", policy =>
    {
        policy.SetIsOriginAllowed(origin => 
        {
            // Allow any localhost port
            return origin.StartsWith("http://localhost:") || 
                   origin.StartsWith("http://127.0.0.1:") ||
                   origin.StartsWith("https://localhost:") || 
                   origin.StartsWith("https://127.0.0.1:");
        })
        .AllowAnyHeader()
        .AllowAnyMethod();
    });
});

var app = builder.Build();

app.MapDefaultEndpoints();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

app.UseHttpsRedirection();

// Use CORS before authorization
app.UseCors("AllowLocalhost");

app.UseAuthorization();

app.MapControllers();

app.Run();
