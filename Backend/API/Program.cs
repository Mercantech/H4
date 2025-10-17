using Scalar.AspNetCore;

var builder = WebApplication.CreateBuilder(args);

builder.AddServiceDefaults();



// Add services to the container.

builder.Services.AddControllers();

// Add CORS support for Flutter app
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowFlutterApp", policy =>
    {
        policy.WithOrigins(
                "https://h4-demo.mercantec.tech",
                "https://h4-demo-api.mercantec.tech"  
            )
            .AllowAnyMethod()               // Allow GET, POST, PUT, DELETE, etc.
            .AllowAnyHeader()               // Allow any headers
            .AllowCredentials();            // Allow cookies/auth headers
    });
    
    // Development policy - more permissive for local development
    options.AddPolicy("AllowAllLocalhost", policy =>
    {
        policy.SetIsOriginAllowed(origin => 
            {
                // Tillad alle localhost og 127.0.0.1 origins med alle porte
                var uri = new Uri(origin);
                return uri.Host == "localhost" || 
                       uri.Host == "127.0.0.1" ||
                       uri.Host == "0.0.0.0";
            })
            .AllowAnyMethod()
            .AllowAnyHeader()
            .AllowCredentials();
    });
});

// Learn more about configuring OpenAPI at https://aka.ms/aspnet/openapi
builder.Services.AddOpenApi();

// OpenAPI configuration will be handled by middleware

var app = builder.Build();

app.MapDefaultEndpoints();

// Configure the HTTP request pipeline.

app.UseForwardedHeaders();

    app.MapOpenApi();
    
    // Configure OpenAPI servers based on environment
    app.Use(async (context, next) =>
    {
        if (context.Request.Path.StartsWithSegments("/openapi"))
        {
            var originalBodyStream = context.Response.Body;
            using var responseBody = new MemoryStream();
            context.Response.Body = responseBody;

            await next();

            if (context.Response.ContentType?.Contains("application/json") == true)
            {
                responseBody.Seek(0, SeekOrigin.Begin);
                var responseText = await new StreamReader(responseBody).ReadToEndAsync();
                
                try
                {
                    var openApiDoc = System.Text.Json.JsonSerializer.Deserialize<System.Text.Json.JsonDocument>(responseText);
                    if (openApiDoc != null)
                    {
                        var modifiedDoc = openApiDoc.RootElement.Clone();
                        var modifiedJson = System.Text.Json.JsonSerializer.Serialize(modifiedDoc);
                        
                        // Replace HTTP URLs with HTTPS in production
                        if (!app.Environment.IsDevelopment())
                        {
                            modifiedJson = modifiedJson.Replace(
                                "http://h4-demo-api.mercantec.tech", 
                                "https://h4-demo-api.mercantec.tech");
                        }
                        
                        var modifiedBytes = System.Text.Encoding.UTF8.GetBytes(modifiedJson);
                        context.Response.Body = originalBodyStream;
                        context.Response.ContentLength = modifiedBytes.Length;
                        await context.Response.Body.WriteAsync(modifiedBytes);
                        return;
                    }
                }
                catch
                {
                    // If JSON parsing fails, continue with original response
                }
            }
            
            responseBody.Seek(0, SeekOrigin.Begin);
            await responseBody.CopyToAsync(originalBodyStream);
            context.Response.Body = originalBodyStream;
        }
        else
        {
            await next();
        }
    });
    
    // Enable Swagger UI (klassisk dokumentation)
    app.UseSwaggerUI(options =>
    {
        options.SwaggerEndpoint("/openapi/v1.json", "API v1");
        options.RoutePrefix = "swagger"; // Tilgængelig på /swagger
    });
    
    // Enable Scalar UI (moderne alternativ til Swagger UI)
    app.MapScalarApiReference(options =>
    {
        options.WithTitle("API Documentation")
               .WithTheme(ScalarTheme.Purple)
               .WithDefaultHttpClient(ScalarTarget.CSharp, ScalarClient.HttpClient);
    });


// Enable CORS - SKAL være før UseAuthorization
if (app.Environment.IsDevelopment())
{
    app.UseCors("AllowAllLocalhost");  
}
else
{
    app.UseCors("AllowFlutterApp");    
}


app.UseAuthorization();

app.MapControllers();

// Log API dokumentations URL'er ved opstart
app.Lifetime.ApplicationStarted.Register(() =>
{
    var logger = app.Services.GetRequiredService<ILogger<Program>>();
    var addresses = app.Services.GetRequiredService<Microsoft.AspNetCore.Hosting.Server.IServer>()
        .Features.Get<Microsoft.AspNetCore.Hosting.Server.Features.IServerAddressesFeature>()?.Addresses;
    
    if (addresses != null && app.Environment.IsDevelopment())
    {
        foreach (var address in addresses)
        {
            logger.LogInformation("Swagger UI: {Address}/swagger", address);
            logger.LogInformation("Scalar UI:  {Address}/scalar", address);
        }
    }
});

app.Run();
