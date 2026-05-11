#!/bin/bash

echo "🚀 啟動 Fooda API 服務器"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📍 服務器地址：http://192.168.1.104:8000"
echo "📂 根目錄：$(pwd)"
echo ""
echo "🔥 啟動中..."
echo ""

# 啟動 PHP 內建服務器（使用正確的 IP）
php -S 192.168.1.104:8000 -t .

echo ""
echo "✅ 服務器已停止"
