# Stage 1: Build Flutter web app
FROM ghcr.io/cirruslabs/flutter:stable AS build-env

WORKDIR /app

COPY pubspec.* ./
RUN flutter pub get

COPY lib/ ./lib/
COPY web/ ./web/
COPY assets/ ./assets/
COPY analysis_options.yaml ./

# production: AppConfig bruger Uri.base.origin/api på ikke-localhost web.
# dart-define beholdes som ekstra signal; PWA-SW slås fra så deploys ikke serverer gammel JS.
ARG CACHEBUST=1
RUN echo "cachebust=$CACHEBUST" \
 && flutter build web --release --pwa-strategy=none --dart-define=APP_ENV=production

# Stage 2: nginx
FROM nginx:alpine
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build-env /app/build/web /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
