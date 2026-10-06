# H4
Template til H4 med Flutter, React Native og C# backend.

| | |
|---|---|
| **Live** | https://h4.mercantec.tech |
| **Oversigt** | https://h.mercantec.tech |

## Hosting

```bash
cp .env.example .env
docker compose up -d --build
```

Lokalt: `docker compose -f docker-compose.yml -f docker-compose.local.yml up --build`  
`web` (nginx) eksponeres via Traefik; Flutter og API kører internt (`/api` → backend).
