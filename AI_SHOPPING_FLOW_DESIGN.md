# 🤖 AI Shopping Flow Design for POS System

## Overview
Replace traditional button-clicking POS flow with conversational AI interface. Users speak/type naturally, and AI understands intents to:
- Select categories
- Choose menu items
- Set quantities
- Process payment
- All without manual button clicks

---

## 📱 UI/UX Design

### 1. **Bottom-Left Floating Button (Desktop/Tablet)**
```
┌─────────────────────────────────────────┐
│                 POS Home                │
│  (Menu grid, Cart display)              │
│                                         │
│                                         │
│                                         │
│  [🎤]  ← Floating AI button            │
│  bottom-left corner                     │
└─────────────────────────────────────────┘
```

**Style:**
- Circular microphone icon (similar to Google Assistant)
- Color: Gradient purple/blue (#7C3AED → #3B82F6)
- Size: 60×60dp with shadow
- Hover effect: Scale up slightly + glow

### 2. **Chat Bubble Interface (Modal/Sheet)**
When AI button is tapped:

```
┌──────────────────────────────┐
│ 🤖 AI Assistant              │ ← Header
├──────────────────────────────┤
│                              │
│ User: "ชาเขียว 2 แก้ว"      │ ← User message
│                              │
│           "เข้าใจแล้ว        │ ← AI response bubble
│            จะสั่ง             │
│            ชาเขียว 2 แก้ว"   │
│                              │
│ User: "ใช่"                  │
│                              │
│           "ชาเขียวเพิ่มลงตะกร้า│
│            แล้ว"             │
│                              │
├──────────────────────────────┤
│ [🎤] Input  [⌨️]  [Send ▶]  │ ← Input area
└──────────────────────────────┘
```

**Components:**
- Chat history (scrollable)
- User messages: Right-aligned, blue bubble
- AI messages: Left-aligned, white/gray bubble
- Microphone icon for voice input
- Text input field for typing
- Send button

### 3. **State Indicators**
- 🎤 Recording: Red pulsing dot
- 🔄 Processing: Spinner
- ✅ Done: Green checkmark

---

## 🧠 AI Conversation Flow

### **Step 1: Greeting & Intent Detection**
```
User: "สั่งอาหาร"
AI: "สวัสดี! 👋 วันนี้สั่งอะไรครับ"

→ Intent: HELP_GREETING
```

### **Step 2: Category Selection (Optional)**
```
User: "เอาเครื่องดื่มหน่อย"
AI: "เครื่องดื่มที่มี:
    1️⃣ ชาเขียว (฿65)
    2️⃣ ชานม (฿70)
    3️⃣ กาแฟ (฿60)"

→ Intent: SELECT_CATEGORY
→ Category: "drinks"
```

### **Step 3: Item Selection**
```
User: "ชาเขียว 2 แก้ว"
AI: "เข้าใจแล้ว จะสั่ง:
    • ชาเขียว ×2 @ ฿65 = ฿130"

→ Intent: ADD_ITEM
→ Item: menu_id=2
→ Quantity: 2
→ Auto-add to cart
```

### **Step 4: Quantity Confirmation**
```
User: "ขอเพิ่มอีกแก้ว"
AI: "ชาเขียว ×3 @ ฿65 = ฿195 ✓"

→ Intent: UPDATE_QUANTITY
→ New Qty: 3
```

### **Step 5: More Items or Payment**
```
User: "ขอขนมปังด้วย"
AI: "เข้าใจ ขนมปัง ×1 @ ฿45 = ฿45
    รวม: ฿240 (ชาเขียว 3 + ขนมปัง 1)"

→ Intent: ADD_ITEM
```

### **Step 6: Payment Intent**
```
User: "ชำระเงินเลย"
AI: "รวมทั้งหมด ฿240
    รับเงินสด ฿250
    ทอนมา ฿10 ✅"

→ Intent: PROCESS_PAYMENT
→ Action: Trigger NumpadDialog
```

---

## 🔄 Intent Mapping to BLoC Events

| User Intent | Gemini Extracts | BLoC Event | Action |
|------------|-----------------|-----------|--------|
| "ชาเขียว 2" | item=ชาเขียว, qty=2 | `AddMenuItemEvent` | Add to cart |
| "เปลี่ยนเป็น 3" | qty=3 | `UpdateCartQtyEvent` | Update quantity |
| "ลบชาเขียว" | item=ชาเขียว | `RemoveItemEvent` | Remove from cart |
| "รวมเท่าไร" | - | `ShowCartEvent` | Display total |
| "ชำระเงิน" | - | `ShowPaymentEvent` | Open numpad |
| "ยกเลิก" | - | `ClearOrderEvent` | Clear cart |

---

## 📊 Gemini Prompt Engineering

### **System Prompt**
```
You are a POS system AI assistant helping customers order food and drinks.

Available items:
- ชาเขียว: ฿65 (aliases: ชา, เขียว)
- ชานม: ฿70 (aliases: ชานม้า)
- ขนมปัง: ฿45 (aliases: ปัง)
- กาแฟ: ฿60 (aliases: กาแฟดำ, เอสเปรสโซ่)

Your tasks:
1. Understand customer ordering intents
2. Extract item names and quantities
3. Confirm orders clearly
4. Provide friendly responses in Thai

Response format (JSON):
{
  "intent": "ADD_ITEM|UPDATE_QUANTITY|REMOVE_ITEM|PROCESS_PAYMENT|HELP",
  "items": [{"name": "ชาเขียว", "qty": 2, "price": 65}],
  "message": "Customer-friendly Thai response",
  "action": "add_to_cart|update_qty|remove|show_payment|none"
}
```

### **Few-Shot Examples in Prompt**
```
Example 1:
User: "สั่งชาเขียว 2 แก้ว"
Response:
{
  "intent": "ADD_ITEM",
  "items": [{"name": "ชาเขียว", "qty": 2, "price": 65}],
  "message": "เข้าใจแล้ว ชาเขียว 2 แก้ว รวม ฿130",
  "action": "add_to_cart"
}

Example 2:
User: "ขอเป็น 3 แก้ว"
Response:
{
  "intent": "UPDATE_QUANTITY",
  "items": [{"name": "ชาเขียว", "qty": 3, "price": 65}],
  "message": "ชาเขียว 3 แก้ว รวม ฿195",
  "action": "update_qty"
}
```

---

## 🛠️ Implementation Architecture

```
┌─────────────────────────────────────────┐
│ 1. AI Input Layer                       │
│    (Voice/Text → home.dart)             │
└────────────────┬────────────────────────┘
                 │
         ┌───────▼────────┐
         │ 2. Gemini API  │
         │ (Intent + Extraction)
         └───────┬────────┘
                 │
         ┌───────▼──────────┐
         │ 3. Intent Parser │
         │ (Map to actions) │
         └───────┬──────────┘
                 │
    ┌────────────┼────────────┐
    │            │            │
  ┌─▼─┐  ┌──────▼──┐  ┌─────▼──┐
  │BLoC│  │Validator│  │ Logger │
  └────┘  └──────────┘  └────────┘
    │
    └──────► HomeBloc
             (Update cart, trigger events)
             │
             └──► UI Updates (cart display)
```

---

## 💾 New Files to Create

### 1. **`lib/pages/ai/gemini_service.dart`**
```dart
class GeminiService {
  // Send user input to Gemini
  Future<AIResponse> processUserInput(String userInput, List<CartItem> currentCart)
  
  // Parse Gemini response to structured format
  AIResponse parseResponse(String jsonResponse)
}
```

### 2. **`lib/pages/ai/ai_models.dart`**
```dart
class AIResponse {
  String intent;        // ADD_ITEM, UPDATE_QTY, PROCESS_PAYMENT, etc.
  List<AIItem> items;   // Extracted items from user input
  String message;       // Response to display to user
  String action;        // Which BLoC event to trigger
}

class AIItem {
  String name;
  int quantity;
  double price;
}
```

### 3. **`lib/pages/ai/ai_chat_sheet.dart`**
```dart
// Modal bottom sheet for chat interface
class AIChatSheet extends StatefulWidget {
  // Handles chat bubble display, message history
  // Voice input via FloatingAIButtonMobile
  // Text input field
  // Real-time cart synchronization
}
```

### 4. **`lib/pages/ai/ai_bloc.dart`** (New BLoC)
```dart
class AIBloc extends Bloc<AIEvent, AIState> {
  // Events: SendUserInput, ReceiveAIResponse
  // States: Loading, Success, Error
}
```

---

## 🔌 Integration Points

### **In `home.dart`:**
```dart
// Add AI button to FAB area
FloatingAIButtonMobile(
  onPressed: () {
    showAIChatSheet(context);  // ← New function
  },
)

// Replace manual flow with AI
// Before: Select category → select item → set qty → pay
// After: Say "ชาเขียว 2" → done
```

### **In `home_bloc.dart`:**
```dart
// AI sends AddMenuItemEvent instead of user clicking
on<AddMenuItemEvent>((event, emit) => _onAddMenuItem(event, emit));

// AI can trigger payment directly
on<ShowPaymentEvent>((event, emit) => emit(PaymentUIVisible()));
```

---

## 🎤 Voice Integration

**Using existing `voice_ai_controller.dart`:**
```dart
// Capture voice → convert to text
StreamSubscription listen() {
  return voiceController.listen(onResult: (result) {
    userInput = result.recognizedWords;  // "ชาเขียว 2"
    sendToGemini(userInput);  // Process with AI
  });
}
```

---

## 📈 UX Flow Comparison

### **Traditional Flow (Current)**
```
User opens app
  ↓
Browse categories (tap)
  ↓
Select item (tap)
  ↓
Choose price (tap)
  ↓
Set quantity (numpad)
  ↓
Confirm (tap)
  ↓
View cart (auto-show)
  ↓
Payment (tap)
  ↓
Enter cash (numpad)
  ↓
Confirm (tap)
  ↓
Order complete ✓

Total taps: ~8-12
```

### **AI Flow (New Alternative)**
```
User opens app
  ↓
Tap AI mic 🎤
  ↓
Say: "ชาเขียว 2, ขนมปัง"
  ↓
AI confirms: "ชาเขียว 2 + ขนมปัง 1, รวม ฿240?"
  ↓
Say: "ใช่, ชำระเงิน"
  ↓
AI shows numpad: "ใส่เงินสด"
  ↓
Say: "250" or tap numpad
  ↓
Order complete ✓

Total interactions: 3-4 (much faster!)
```

---

## 🎨 UI Enhancement Checklist

- [ ] Redesign AI button (bottom-left, microphone icon, gradient)
- [ ] Create chat bubble UI (modern messaging style)
- [ ] Add message history panel
- [ ] Implement voice recording indicator (pulsing dot)
- [ ] Create response animation (fade-in slide-up)
- [ ] Add loading spinner during Gemini processing
- [ ] Style input field (text + mic button)
- [ ] Add cart sync indicator
- [ ] Create error messages UI
- [ ] Implement theme matching (dark/light mode)

---

## 🚀 Development Phases

### **Phase 1: Core AI Integration**
- [ ] Setup Gemini API calls
- [ ] Create AIService class
- [ ] Parse responses to intents
- [ ] Map intents to BLoC events

### **Phase 2: Chat UI**
- [ ] Build AIChatSheet component
- [ ] Implement message bubbles
- [ ] Add text input field
- [ ] Connect to existing voice input

### **Phase 3: UX Polish**
- [ ] Redesign AI button
- [ ] Add animations
- [ ] Implement real-time cart sync
- [ ] Error handling UI

### **Phase 4: Testing & Optimization**
- [ ] Voice recognition testing
- [ ] Intent parsing accuracy
- [ ] Edge case handling
- [ ] Performance optimization

---

## 💡 Advanced Features (Future)

1. **Context Awareness**
   - Remember previous orders
   - Learn user preferences
   - Suggest items

2. **Multi-Language Support**
   - Thai ↔ English switching
   - Regional dialects

3. **Complex Orders**
   - Customizations (no ice, extra sugar)
   - Combo deals
   - Special requests

4. **Analytics**
   - Popular voice commands
   - Conversation patterns
   - User satisfaction metrics

---

## ✅ Success Criteria

- ✓ AI understands Thai food ordering naturally
- ✓ User can place full order with voice only
- ✓ Cart updates automatically from AI intents
- ✓ Payment flows seamlessly after order
- ✓ Chat bubble UI modern and responsive
- ✓ Response time < 2 seconds (Gemini latency)
- ✓ Voice recognition accuracy > 90%

---

**Status:** Design complete, ready for implementation 🚀
