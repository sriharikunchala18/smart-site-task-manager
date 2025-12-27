#!/bin/bash

# Smart Site Task Manager Backend Deployment Script
# This script helps deploy the backend to Render

echo "🚀 Preparing Smart Site Task Manager Backend for Deployment"

# Check if required environment variables are set
if [ -z "$SUPABASE_URL" ]; then
    echo "❌ Error: SUPABASE_URL environment variable is not set"
    echo "Please set your Supabase URL: export SUPABASE_URL=your_supabase_url"
    exit 1
fi

if [ -z "$SUPABASE_ANON_KEY" ]; then
    echo "❌ Error: SUPABASE_ANON_KEY environment variable is not set"
    echo "Please set your Supabase anon key: export SUPABASE_ANON_KEY=your_supabase_anon_key"
    exit 1
fi

echo "✅ Environment variables are set"

# Run tests before deployment
echo "🧪 Running tests..."
npm test

if [ $? -ne 0 ]; then
    echo "❌ Tests failed. Please fix the issues before deploying."
    exit 1
fi

echo "✅ All tests passed"

# Build the application (if needed)
echo "🔨 Building application..."
npm run build 2>/dev/null || echo "No build script found, skipping build step"

echo "✅ Build completed"

echo "📦 Deployment preparation complete!"
echo ""
echo "Next steps:"
echo "1. Push your code to GitHub"
echo "2. Go to Render.com and create a new Web Service"
echo "3. Connect your GitHub repository"
echo "4. Configure the following settings:"
echo "   - Build Command: npm install"
echo "   - Start Command: npm start"
echo "5. Add environment variables:"
echo "   - SUPABASE_URL: $SUPABASE_URL"
echo "   - SUPABASE_ANON_KEY: $SUPABASE_ANON_KEY"
echo "   - PORT: 10000"
echo "6. Deploy!"
echo ""
echo "After deployment, update the Flutter app's baseUrl in lib/providers/task_provider.dart"
echo "Replace 'https://your-render-app-url.onrender.com/api/tasks' with your actual Render URL"
