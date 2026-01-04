# Environment Setup Guide

This guide explains how to set up API keys and environment variables for the FLUX application.

## Quick Setup

1. **Copy the environment template:**
   ```bash
   cp .env.example .env
   ```

2. **Edit the .env file and add your API keys:**
   ```bash
   # Open .env in your preferred editor
   nano .env
   # or
   code .env
   ```

3. **Replace placeholder values with your actual API keys**

## API Keys Required

### 1. Groq API Key (Required for AI Chat)
- **Purpose:** Primary AI provider for chat functionality
- **Get your key:** https://console.groq.com/keys
- **Free tier:** Available with rate limits
- **Environment variable:** `GROQ_API_KEY`

### 2. OpenRouter API Key (Optional - Fallback)
- **Purpose:** Fallback AI provider when Groq is unavailable
- **Get your key:** https://openrouter.ai/keys
- **Free tier:** Available with credits
- **Environment variable:** `OPENROUTER_API_KEY`

### 3. Bytez API Key (Optional - Secondary Fallback)
- **Purpose:** Secondary fallback AI provider
- **Get your key:** https://bytez.com/
- **Environment variable:** `BYTEZ_API_KEY`

### 4. Whois API Key (Optional - Network Tools)
- **Purpose:** Enhanced network diagnostics in cybersecurity tools
- **Get your key:** https://whoisxmlapi.com/
- **Free tier:** Available with limited requests
- **Environment variable:** `WHOIS_API_KEY`

## Environment File Structure

Your `.env` file should look like this:

```env
# AI Services
GROQ_API_KEY=gsk_your_actual_groq_key_here
OPENROUTER_API_KEY=sk-or-v1-your_actual_openrouter_key_here
BYTEZ_API_KEY=your_actual_bytez_key_here

# Network Tools
WHOIS_API_KEY=your_actual_whois_key_here
```

## Security Best Practices

1. **Never commit .env files to version control**
   - The `.env` file is already in `.gitignore`
   - Only commit `.env.example` with placeholder values

2. **Use different keys for different environments**
   - Development: `.env`
   - Production: Set environment variables directly on your server

3. **Rotate keys regularly**
   - Most providers allow key rotation in their dashboards

## Troubleshooting

### "API key not configured" Error
- Check that your `.env` file exists in the project root
- Verify the key names match exactly (case-sensitive)
- Ensure there are no extra spaces around the `=` sign
- Restart the app after changing environment variables

### AI Features Not Working
- Verify at least the Groq API key is set correctly
- Check your API key quotas on the provider's dashboard
- Test with a simple message first

### Network Tools Not Working
- Whois API key is optional - basic functionality works without it
- Free tier has rate limits - wait a few minutes between requests

## Production Deployment

For production deployment, set environment variables directly on your hosting platform:

### Heroku
```bash
heroku config:set GROQ_API_KEY=your_key_here
```

### Vercel
```bash
vercel env add GROQ_API_KEY
```

### Docker
```bash
docker run -e GROQ_API_KEY=your_key_here your_app
```

## Support

If you encounter issues with environment setup:
1. Check this guide first
2. Verify your API keys are valid on the provider's website
3. Check the app logs for specific error messages
4. Create an issue with the error details if problems persist