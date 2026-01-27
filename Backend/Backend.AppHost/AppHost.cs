var builder = DistributedApplication.CreateBuilder(args);

var api = builder.AddProject<Projects.API>("api");

var flutter = builder.AddFlutterApp("flutter", "../../flutter_app")
                        .WithArgs("-d", "web-server")
                        .WithDartDefine("API_URL_HTTP", api.GetEndpoint("http"))
                        .WithDartDefine("API_URL_HTTPS", api.GetEndpoint("https"))
                        .WithReference(api)
                        .WaitFor(api);

/*
    To reference the api url in the flutter app you can use the following code in your app:
    const apiUrlHttp = String.fromEnvironment('API_URL_HTTP');
    const apiUrlHttps = String.fromEnvironment('API_URL_HTTPS');
*/

builder.Build().Run();
