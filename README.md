# Smart Site Task Manager

A comprehensive task management application that automatically classifies and organizes tasks based on intelligent content analysis. Built with Node.js backend and Flutter mobile app.

## 🚀 Features

### Backend (Node.js + Supabase)
- ✅ RESTful API with 5 core endpoints
- ✅ Automatic task classification (Scheduling, Finance, Technical, Safety, General)
- ✅ Priority assessment (High, Medium, Low)
- ✅ Entity extraction (dates, persons, locations, actions)
- ✅ Suggested actions based on category
- ✅ Task history/audit logging
- ✅ PostgreSQL database with proper schema

### Flutter Mobile App
- ✅ Single dashboard screen with summary cards
- ✅ Task list with filtering and search
- ✅ AI classification preview before saving
- ✅ Pull-to-refresh functionality
- ✅ Offline indicator
- ✅ Material Design 3 UI
- ✅ Form validation and error handling

### Testing
- ✅ Unit tests for classification logic
- ✅ API endpoint validation
- ✅ Form validation testing

## 🏗️ Architecture

### Database Schema (Supabase)

#### Tasks Table
```sql
CREATE TABLE tasks (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  description text,
  category text CHECK (category IN ('scheduling', 'finance', 'technical', 'safety', 'general')),
  priority text CHECK (priority IN ('high', 'medium', 'low')),
  status text CHECK (status IN ('pending', 'in_progress', 'completed')),
  assigned_to text,
  due_date timestamp,
  extracted_entities jsonb,
  suggested_actions jsonb,
  created_at timestamp DEFAULT now(),
  updated_at timestamp DEFAULT now()
);
```

#### Task History Table
```sql
CREATE TABLE task_history (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  task_id uuid REFERENCES tasks(id) ON DELETE CASCADE,
  action text CHECK (action IN ('created', 'updated', 'status_changed', 'completed')),
  old_value jsonb,
  new_value jsonb,
  changed_by text,
  changed_at timestamp DEFAULT now()
);
```

## 🔧 Tech Stack

### Backend
- **Runtime**: Node.js
- **Framework**: Express.js
- **Database**: Supabase (PostgreSQL)
- **Validation**: Joi
- **Security**: Helmet, CORS
- **Testing**: Jest, Supertest

### Frontend
- **Framework**: Flutter
- **State Management**: Provider
- **HTTP Client**: Dio
- **Connectivity**: connectivity_plus
- **UI**: Material Design 3

## 📋 API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/tasks` | Create new task with auto-classification |
| GET | `/api/tasks` | List tasks with filters (status, category, priority) |
| GET | `/api/tasks/{id}` | Get task details with history |
| PATCH | `/api/tasks/{id}` | Update task |
| DELETE | `/api/tasks/{id}` | Delete task |

### Request/Response Examples

#### Create Task
```bash
POST /api/tasks
Content-Type: application/json

{
  "title": "Schedule urgent meeting with team about budget",
  "description": "Need to discuss Q4 budget allocation and cost optimization",
  "assigned_to": "John Doe",
  "due_date": "2024-12-30T10:00:00Z"
}
```

**Response:**
```json
{
  "id": "uuid-here",
  "title": "Schedule urgent meeting with team about budget",
  "description": "Need to discuss Q4 budget allocation and cost optimization",
  "category": "scheduling",
  "priority": "high",
  "status": "pending",
  "assigned_to": "John Doe",
  "due_date": "2024-12-30T10:00:00.000Z",
  "extracted_entities": ["Q4", "budget", "cost", "John"],
  "suggested_actions": ["Block calendar", "Send invite", "Prepare agenda", "Set reminder"],
  "created_at": "2024-12-25T10:30:00.000Z",
  "updated_at": "2024-12-25T10:30:00.000Z"
}
```

## 🚀 Setup Instructions

### Prerequisites
- Node.js (v16+)
- Flutter SDK (v3.0+)
- Supabase account
- Git

### Backend Setup

1. **Clone and navigate to backend directory:**
```bash
cd smart-site-task-manager/backend
```

2. **Install dependencies:**
```bash
npm install
```

3. **Set up Supabase:**
   - Create a new Supabase project
   - Run the SQL schema provided above in Supabase SQL editor
   - Get your project URL and anon key from Settings > API

4. **Create environment file:**
```bash
cp .env.example .env
```

Edit `.env` with your Supabase credentials:
```env
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
PORT=3000
```

5. **Run backend:**
```bash
npm run dev  # Development with nodemon
# or
npm start    # Production
```

6. **Run tests:**
```bash
npm test
```

### Flutter App Setup

1. **Navigate to Flutter directory:**
```bash
cd smart-site-task-manager/flutter
```

2. **Install dependencies:**
```bash
flutter pub get
```

3. **Update API base URL in `lib/providers/task_provider.dart`:**
```dart
final String baseUrl = 'https://your-render-app-url.onrender.com/api/tasks';
```

4. **Run the app:**
```bash
flutter run
```

## 🔍 AI Classification Logic

### Category Classification
- **Scheduling**: meeting, schedule, call, appointment, deadline
- **Finance**: payment, invoice, bill, budget, cost, expense
- **Technical**: bug, fix, error, install, repair, maintain
- **Safety**: safety, hazard, inspection, compliance, PPE
- **General**: default category

### Priority Assessment
- **High**: urgent, asap, immediately, today, critical, emergency
- **Medium**: soon, this week, important
- **Low**: default priority

### Entity Extraction
- **Dates/Times**: "today", "tomorrow", "next week", "12/25/2024"
- **Persons**: "with John", "assign to Sarah", "by Mike"
- **Locations**: "at office", "in warehouse", "to site A"
- **Actions**: "schedule", "fix", "pay", "inspect", "update"

### Suggested Actions by Category
- **Scheduling**: Block calendar, Send invite, Prepare agenda, Set reminder
- **Finance**: Check budget, Get approval, Generate invoice, Update records
- **Technical**: Diagnose issue, Check resources, Assign technician, Document fix
- **Safety**: Conduct inspection, File report, Notify supervisor, Update checklist

## 📱 Flutter App Screenshots

### Dashboard Screen
- Top: Summary cards showing task counts by status
- Main: Task list with category chips, priority badges, due dates
- Bottom: Floating action button for adding new tasks

### Add Task Screen
- Form fields for title, description, assigned to, due date
- Real-time AI classification preview
- Extracted entities display
- Suggested actions list
- Override options for category/priority

## 🚀 Deployment

### Backend Deployment (Render)

1. **Connect GitHub repository to Render**
2. **Create new Web Service**
3. **Configure build settings:**
   - **Build Command**: `npm install`
   - **Start Command**: `npm start`
4. **Add environment variables:**
   - `SUPABASE_URL`
   - `SUPABASE_ANON_KEY`
   - `PORT`: `10000` (Render default)
5. **Deploy**

### Flutter App Deployment

1. **Update API URL in TaskProvider**
2. **Build for platforms:**
```bash
flutter build apk          # Android APK
flutter build appbundle    # Android App Bundle
flutter build ios          # iOS (requires macOS)
```

## 🧪 Testing

### Backend Tests
```bash
cd backend
npm test
```

**Test Coverage:**
- ✅ Category classification accuracy
- ✅ Priority assessment logic
- ✅ Entity extraction functionality
- ✅ API endpoint validation

### Flutter Tests
```bash
cd flutter
flutter test
```

## 🤝 Architecture Decisions

### Backend
- **Supabase**: Chosen for managed PostgreSQL, real-time capabilities, and built-in authentication
- **Joi Validation**: Comprehensive input validation with detailed error messages
- **Audit Logging**: Complete task history tracking for compliance and debugging

### Flutter
- **Provider**: Simple and effective state management for this scale
- **Dio**: Robust HTTP client with interceptors for error handling
- **Material Design 3**: Modern, accessible UI components

### Database Design
- **UUID Primary Keys**: For global uniqueness and security
- **JSONB Fields**: Flexible storage for extracted entities and suggested actions
- **Foreign Key Constraints**: Data integrity with cascading deletes

## 🔮 Future Improvements

### High Priority
- [ ] Real-time updates using Supabase subscriptions
- [ ] Push notifications for task reminders
- [ ] Task templates for common workflows
- [ ] Bulk task operations

### Medium Priority
- [ ] Advanced search with filters
- [ ] Task dependencies and subtasks
- [ ] File attachments for tasks
- [ ] Team collaboration features

### Nice to Have
- [ ] Dark mode support
- [ ] Export tasks to CSV/PDF
- [ ] Calendar integration
- [ ] Mobile widgets

## 📊 Performance Optimizations

- **Pagination**: API endpoints support limit/offset for large datasets
- **Indexing**: Database indexes on frequently queried columns
- **Caching**: Flutter app caches task data locally
- **Lazy Loading**: UI components load content on demand

## 🔒 Security Considerations

- **Input Validation**: All inputs validated with Joi schemas
- **CORS Configuration**: Restricted to allowed origins
- **Helmet Security**: HTTP security headers
- **Environment Variables**: Sensitive data stored securely
- **UUID Keys**: Non-sequential identifiers prevent enumeration

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👥 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📞 Support

For support, email support@smartsitetaskmanager.com or create an issue in this repository.

---

**Live Demo**: [https://smart-site-task-manager-1.onrender.com](https://smart-site-task-manager-1.onrender.com)

**GitHub Repository**: [https://github.com/sriharikunchala18/smart-site-task-manager](https://github.com/sriharikunchala18/smart-site-task-manager)
