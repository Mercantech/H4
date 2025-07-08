# Docker Setup med Nginx Reverse Proxy

Dette setup giver dig mulighed for at hoste alle dine apps bag en enkelt Nginx reverse proxy.

## URL Struktur

- **`/`** → Redirect til `/flutter/`
- **`/flutter/`** → Flutter Web App
- **`/react/`** → React Native Web App  
- **`/api/`** → Backend API
- **`/health`** → Health check endpoint

## Kommandoer

### Development
```bash
# Start alle services
docker-compose up -d

# Se logs
docker-compose logs -f

# Stop alle services
docker-compose down
```

### Production
```bash
# Start production setup
docker-compose -f compose.prod.yaml up -d

# Se logs
docker-compose -f compose.prod.yaml logs -f

# Stop production setup
docker-compose -f compose.prod.yaml down
```

## Cloudflare Tunnel Setup

1. **Installer cloudflared** på din server
2. **Opret tunnel** i Cloudflare dashboard
3. **Konfigurer tunnel** til at pege på din server's port 80
4. **Sæt custom domain** op (f.eks. `yourdomain.com`)

### Tunnel konfiguration eksempel:
```yaml
# ~/.cloudflared/config.yml
tunnel: your-tunnel-id
credentials-file: /path/to/credentials.json

ingress:
  - hostname: yourdomain.com
    service: http://localhost:80
  - service: http_status:404
```

## Sikkerhed

### HTTPS med Cloudflare
- Cloudflare håndterer SSL/TLS automatisk
- Alle requests går gennem Cloudflare's proxy
- Din server behøver ikke SSL certifikater

### Firewall
- Kun port 80 skal være åben på din server
- Alle andre porte er interne i Docker network

## Troubleshooting

### Tjek service status:
```bash
docker-compose ps
```

### Se logs for specifik service:
```bash
docker-compose logs nginx
docker-compose logs backend
docker-compose logs flutterweb
docker-compose logs reactnative-web
```

### Test endpoints lokalt:
```bash
# Health check
curl http://localhost/health

# API test
curl http://localhost/api/weatherforecast

# Flutter app
curl http://localhost/flutter/

# React app
curl http://localhost/react/
```

### Genstart specifik service:
```bash
docker-compose restart nginx
```

## Performance

### Nginx Caching
Nginx konfigurationen inkluderer:
- Static file caching
- Gzip compression
- Connection pooling

### Docker Optimizations
- Alpine Linux images for mindre størrelse
- Multi-stage builds i Dockerfiles
- Shared networks for bedre performance

## Monitoring

### Health Checks
Alle services har health check endpoints:
- Nginx: `/health`
- Backend: `/api/health` (hvis implementeret)

### Logs
- Nginx access logs
- Application logs per service
- Docker container logs 