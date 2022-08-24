FROM mcr.microsoft.com/dotnet/framework/sdk:4.8-windowsservercore-ltsc2019 AS build
WORKDIR /app

COPY *.sln .
COPY MSDTCApp/*.csproj ./MSDTCApp/
COPY MSDTCApp/*.config ./MSDTCApp/
RUN nuget restore

COPY MSDTCApp/. ./MSDTCApp/
WORKDIR /app/MSDTCApp
RUN msbuild /p:Configuration=Release -r:False

FROM mcr.microsoft.com/dotnet/framework/aspnet:4.8-windowsservercore-ltsc2019 AS runtime

WORKDIR /inetpub/wwwroot
COPY --from=build /app/MSDTCApp/. ./