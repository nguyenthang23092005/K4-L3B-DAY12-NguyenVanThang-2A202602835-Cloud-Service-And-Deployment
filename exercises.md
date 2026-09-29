# Phiếu Phản Ánh — K4 Level 3B, Ngày 12

> **Bài làm cá nhân.** Trả lời bằng lời của chính bạn, dựa trên những gì bạn
> quan sát được khi chạy code — không sao chép đáp án của người khác.
>
> Cách trả lời: thay dòng `> *Câu trả lời của bạn*` bằng câu trả lời.
> `grade.py` đếm số câu đã trả lời (15 điểm cho 10 câu).
>
> Họ và tên: Nguyễn Văn Thắng  Mã học viên: 2A202602835

---

### Câu 1 — Fail fast (CP1)

Trong `Settings`, `agent_api_key` không có giá trị mặc định nên app chết ngay
khi khởi động nếu thiếu biến môi trường. Hãy mô tả một tình huống cụ thể mà
việc "chết sớm" này cứu bạn, so với việc để mặc định `"changeme"`.

> Khi deploy lên Railway, nếu quên đặt `AGENT_API_KEY` thì app phải dừng ngay để dashboard báo lỗi cấu hình. Nếu dùng mặc định `changeme`, service vẫn public nhưng ai đoán được key đó có thể gọi `/ask`, làm phát sinh chi phí và khó phát hiện sai sót.

---

### Câu 2 — Log cho máy đọc (CP1)

Chạy service và gọi `/ask` vài lần. Dán một dòng log JSON bạn thu được, rồi
nêu **hai** việc bạn làm được với dòng log đó mà `print("đã trả lời xong")`
không làm được.

> Một dòng log tôi thấy có dạng `{"event":"service_started","level":"info","timestamp":"...","service":"day12-agent","version":"1.0.0"}`. Tôi có thể lọc tất cả event `service_started` theo thời gian để kiểm tra lần deploy nào đã lên, và có thể thống kê/lọc theo `level` hoặc `user_id` khi điều tra lỗi. Chuỗi `print("đã trả lời xong")` không có cấu trúc field để làm hai việc này đáng tin cậy.

---

### Câu 3 — Kích thước image (CP2)

Build cả hai phiên bản và ghi lại số đo thật:

```bash
docker build -f <Dockerfile-1-stage> -t agent:single .
docker build -t agent:multi .
docker images | grep agent
```

| Bản | Dung lượng |
|-----|-----------|
| 1 stage (bản đầu) | Chưa đo lại (Docker Desktop đang tắt) |
| Multi-stage | 305 MB (đã build `day12-agent:prod`) |

Giải thích: phần dung lượng chênh lệch đó là những gì?

> Bản multi-stage chỉ copy virtual environment và source cần chạy sang runtime, nên không mang pip cache, compiler hay các file tạm của builder. Tôi đã đo image multi-stage là 305 MB; cần bật Docker Desktop rồi build lại Dockerfile một stage cũ để có số so sánh chính xác thay vì ghi số ước lượng.

---

### Câu 4 — Thứ tự lệnh trong Dockerfile (CP2)

Sửa một ký tự trong `app/main.py` rồi build lại. Với Dockerfile của bạn, những
layer nào được dùng lại từ cache, layer nào phải chạy lại? Nếu bạn đặt
`COPY . .` lên trước `RUN pip install` thì kết quả khác thế nào?

> Khi chỉ đổi một ký tự trong `app/main.py`, Docker dùng lại các layer base image, tạo virtualenv và `pip install -r requirements.txt`; layer `COPY . .` và các layer sau nó phải chạy lại. Nếu `COPY . .` đặt trước `RUN pip install`, mọi thay đổi source làm mất cache dependency và phải cài lại toàn bộ package, nên build chậm hơn nhiều.

---

### Câu 5 — Vì sao không chạy bằng root (CP2)

Container mặc định chạy bằng root. Mô tả chuỗi sự kiện dẫn từ "một lỗ hổng
trong code Python của bạn" tới "kẻ tấn công có quyền cao trên máy host", và
lệnh `USER` cắt đứt chuỗi đó ở chỗ nào.

> Một lỗ hổng cho phép thực thi lệnh trong Python sẽ cho kẻ tấn công quyền của process trong container. Nếu process là root, họ có thể sửa file hệ thống trong container, đọc secrets gắn vào container và tận dụng cấu hình Docker/volume sai để leo thang sang host. `USER appuser` hạ quyền process trước khi chạy Uvicorn, nên lệnh bị thực thi chỉ có quyền user thường và bị giảm đáng kể phạm vi phá hoại.

---

### Câu 6 — Cửa sổ trượt (CP3)

Rate limit của bạn dùng sliding window 60 giây. Nếu thay bằng cách đếm theo
phút đồng hồ (reset lúc giây 00), một người dùng có thể gửi tối đa bao nhiêu
request trong 2 giây liên tiếp khi hạn mức là 10/phút? Giải thích cách đạt được
con số đó.

> Với fixed window theo phút đồng hồ và giới hạn 10/phút, người dùng gửi 10 request ở giây 59 của một phút rồi gửi thêm 10 request ở giây 00 của phút kế tiếp: tổng 20 request trong khoảng 2 giây. Sliding window luôn nhìn lại đúng 60 giây trước đó nên 10 request đầu vẫn được tính và đợt thứ hai bị chặn.

---

### Câu 7 — Rate limit và cost guard (CP3)

Hai cơ chế này khác nhau ở điểm nào? Cho một tình huống mà rate limit cho qua
nhưng cost guard phải chặn, và một tình huống ngược lại.

> Rate limit giới hạn tốc độ request trong cửa sổ ngắn để chống burst/abuse; cost guard giới hạn tổng chi phí theo user trong tháng. Một user gửi đều 1 request mỗi phút nên qua rate limit, nhưng nếu đã gần hết ngân sách tháng thì cost guard phải trả 402. Ngược lại, user mới chưa tốn tiền có thể còn đủ budget nhưng gửi hơn 10 request trong 60 giây, nên rate limit trả 429 trước.

---

### Câu 8 — /health khác /ready (CP4)

Nếu gộp hai endpoint làm một và cho nó kiểm tra Redis, chuyện gì xảy ra với cụm
3 container khi Redis mất kết nối 30 giây? Trả lời theo đúng thứ tự sự kiện.

> Nếu `/health` cũng kiểm tra Redis, Redis mất kết nối 30 giây sẽ làm cả ba container trả 503 cho liveness. Orchestrator hiểu nhầm process chết, lần lượt restart container; các container mới vẫn không kết nối được Redis nên tiếp tục restart, tạo vòng lặp và làm service kém ổn định. Tách probe giúp `/health` giữ 200 khi process sống, còn `/ready` trả 503 để load balancer tạm ngừng gửi traffic.

---

### Câu 9 — Stateless (CP4)

Chạy `docker compose up --scale agent=3` rồi gọi `/ask` nhiều lần với cùng một
`X-User-Id`. Quan sát `history_length` trong response. Nếu lịch sử được lưu
trong một dict Python thay vì Redis, bạn sẽ thấy con số đó thay đổi thế nào?

> Với Redis, cả ba replica đọc cùng key history theo `X-User-Id`, nên `history_length` tăng liên tục dù request được phân cho container khác nhau. Nếu dùng dict Python, mỗi container có một dict riêng: request vào replica mới có thể thấy `history_length` là 0 hoặc một giá trị nhỏ, nên lịch sử bị đứt quãng và không nhất quán.

---

### Câu 10 — Deploy thật (CP5)

Ghi lại **một** lỗi bạn gặp khi deploy lên cloud (build fail, health check
timeout, sai REDIS_URL, app không đọc `$PORT`...): thông báo lỗi là gì, bạn
tìm ra nguyên nhân bằng cách nào, và sửa ra sao?

> Khi deploy Railway, `/health` lên được nhưng `/ready` trả 503 do `REDIS_URL` đang trỏ vào service Redis cũ không phản hồi. Tôi kiểm tra log agent thấy lỗi/timeout khi ping Redis và dùng endpoint `/ready` để tách lỗi dependency khỏi liveness. Sau đó tôi tạo service `agentredis` từ `redis:7-alpine` và đổi URL nội bộ thành `redis://${{agentredis.RAILWAY_PRIVATE_DOMAIN}}:6379/0`; `/ready` trả lại 200 với `redis: true`.
