# 🔧 การแก้ไขปัญหา Firebase AI

## ❌ ปัญหาที่เจอ:
```
Requests to this API firebasevertexai.googleapis.com method google.firebase.vertexai.v1beta.GenerativeService.GenerateContent are blocked.
```

## ✅ วิธีแก้:

### 1. เปิด Google Cloud Console
- ไปที่: https://console.cloud.google.com
- เลือก project: `flutter-pos-ai`

### 2. เปิด Vertex AI API
- ไปที่ "APIs & Services" > "Library"
- ค้นหา: "Vertex AI API"
- คลิก "ENABLE"

### 3. เปิด Generative AI API
- ค้นหา: "Generative AI API" 
- คลิก "ENABLE"

### 4. ตั้งค่า Billing (จำเป็น)
- ไปที่ "Billing"
- เพิ่ม payment method
- Vertex AI ต้องการ billing account

### 5. ตรวจสอบ IAM Permissions
- ไปที่ "IAM & Admin"
- ตรวจสอบว่า service account มี role:
  - `Vertex AI User`
  - `AI Platform User`

## 🎯 หลังแก้แล้ว:
- Firebase AI จะทำงานได้
- Gemini 2.5 Flash สามารถตอบคำถามได้
- Voice input → AI response จะเชื่อมต่อสมบูรณ์

## 🗣️ ทดสอบการทำงาน:
1. พูด: "สวัสดีครับ"
2. AI ควรตอบ: "สวัสดีค่ะ รับอะไรดีคะ"
3. พูด: "มีเมนูอะไรบ้าง"
4. AI ควรแนะนำเมนูที่มี