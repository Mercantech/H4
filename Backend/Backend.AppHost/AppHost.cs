var builder = DistributedApplication.CreateBuilder(args);

var api = builder.AddProject<Projects.API>("api");

var flutter = builder.AddFlutterApp("flutter", "../../flutter_app")
                        .WithArgs("-d", "web-server")
                        .WithDartDefine("API_URL_HTTP", api.GetEndpoint("http"))
                        .WithDartDefine("API_URL_HTTPS", api.GetEndpoint("https"))
                        .WithReference(api)
                        .WaitFor(api);

builder.Build().Run();
