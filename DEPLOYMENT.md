# Thông Tin Deploy — Checkpoint 5

## Thông Tin Học Viên

| Mục | Nội dung |
|-----|----------|
| Họ và tên | Nguyễn Văn Thăng |
| Mã học viên | 2A202602835 |
| Repo | https://github.com/nguyenthang23092005/K4-L3B-DAY12-NguyenVanThang-2A202602835-Cloud-Service-And-Deployment |

## Service

| Mục | Nội dung |
|-----|----------|
| Public URL | https://agent-production-0b45.up.railway.app |
| Platform | Railway |
| Ngày deploy | 2026-09-29 |

## Biến Môi Trường Đã Set Trên Cloud

Chỉ ghi tên biến và nguồn giá trị; không ghi giá trị secret.

| Biến | Đã set | Ghi chú |
|------|--------|---------|
| `PORT` | ✅ | Railway tự gán |
| `AGENT_API_KEY` | ✅ | Railway Variables; truyền từ secret cục bộ, không nằm trong repo |
| `REDIS_URL` | ✅ | Private URL của service `agentredis` trên Railway |
| `RATE_LIMIT_PER_MINUTE` | ✅ | 10 |
| `MONTHLY_BUDGET_USD` | ✅ | 10.0 |
| `LOG_LEVEL` | ✅ | INFO |

## Kết Quả Kiểm Tra

```text
GET /health
200 {"status":"ok","service":"day12-agent","version":"1.0.0"}

GET /ready
200 {"status":"ready","redis":true}

POST /ask (không có X-API-Key)
401 {"detail":"invalid or missing API key"}
```

## Lệnh Kiểm Tra

```bash
URL=https://agent-production-0b45.up.railway.app

curl -i "$URL/health"
curl -i "$URL/ready"
curl -i -X POST "$URL/ask" \
  -H "Content-Type: application/json" \
  -d '{"question":"Hello"}'
```

## Ảnh Chụp Màn Hình

- `screenshots/health.png` — kết quả public health endpoint.
- `screenshots/dashboard.png` — cần chụp từ Railway dashboard đã đăng nhập.
