#!/usr/bin/env python3
"""
Simple script to test OpenAI API key
"""

import requests
import json
import sys

# Read API key from Config.plist
def read_api_key():
    try:
        import plistlib
        with open('Osanyin (Herbal Remedy)/Config.plist', 'rb') as f:
            plist = plistlib.load(f)
            return plist.get('OpenAIAPIKey')
    except Exception as e:
        print(f"Error reading Config.plist: {e}")
        return None

def test_openai_api(api_key):
    url = "https://api.openai.com/v1/chat/completions"
    
    headers = {
        "Authorization": f"Bearer {api_key}",
        "Content-Type": "application/json"
    }
    
    data = {
        "model": "gpt-3.5-turbo",
        "messages": [
            {"role": "user", "content": "Say 'Hello' if you can read this."}
        ],
        "temperature": 0.1,
        "max_tokens": 10
    }
    
    try:
        print("🧪 Testing OpenAI API...")
        response = requests.post(url, headers=headers, json=data, timeout=30)
        
        print(f"📡 HTTP Status: {response.status_code}")
        
        if response.status_code == 200:
            result = response.json()
            content = result['choices'][0]['message']['content']
            print(f"✅ API Test Successful!")
            print(f"📝 Response: {content}")
            return True
        else:
            print(f"❌ API Test Failed!")
            print(f"📄 Error Response: {response.text}")
            return False
            
    except Exception as e:
        print(f"❌ Network Error: {e}")
        return False

if __name__ == "__main__":
    api_key = read_api_key()
    
    if not api_key:
        print("❌ Could not read API key from Config.plist")
        sys.exit(1)
    
    print(f"🔑 API Key found: {api_key[:20]}...")
    
    success = test_openai_api(api_key)
    
    if success:
        print("\n🎉 API key is working correctly!")
        print("The Drug Interaction Checker should work in the app.")
    else:
        print("\n⚠️ API key test failed!")
        print("Check your internet connection and API key validity.")
    
    sys.exit(0 if success else 1) 