<?php
/**
 * Fooda 食物圖片分析 API
 * 根據規格文件實現 - 使用 Gemini API 進行食物識別
 */

// 設定錯誤報告
error_reporting(E_ALL);
ini_set('display_errors', 0);
ini_set('log_errors', 1);

// 修正 Mac 上的檔案上傳限制問題
ini_set('upload_max_filesize', '20M');
ini_set('post_max_size', '25M');
ini_set('memory_limit', '256M');
ini_set('max_execution_time', '120');

// 設定 headers
header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

// 載入配置
$config = include(__DIR__ . '/../env.php');
if (!$config) {
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'error' => 'Configuration load failed',
        'code' => $config['ERROR_CODES']['ANALYZE_INTERNAL']
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

/**
 * 統一錯誤回應函數
 */
function sendError($message, $code, $httpCode = 400) {
    global $config;
    http_response_code($httpCode);
    echo json_encode([
        'success' => false,
        'error' => $message,
        'code' => $code
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

/**
 * 成功回應函數
 */
function sendSuccess($data) {
    echo json_encode([
        'success' => true,
        'data' => $data
    ], JSON_UNESCAPED_UNICODE);
    exit;
}

/**
 * 根據語言生成提示詞
 */
function generatePromptByLanguage($language) {
    $prompts = [
        'zh-TW' => 'Identify all foods in this photo and estimate grams for each item. For each food, provide both Traditional Chinese and English names. Return strictly this JSON schema: {"items":[{"name_zh":"繁體中文名稱","name_en":"english name","grams":123}]} with no extra text. Example: {"items":[{"name_zh":"蘋果","name_en":"apple","grams":150},{"name_zh":"香蕉","name_en":"banana","grams":120}]}',
        
        'zh-CN' => 'Identify all foods in this photo and estimate grams for each item. For each food, provide both Simplified Chinese and English names. Return strictly this JSON schema: {"items":[{"name_zh":"简体中文名称","name_en":"english name","grams":123}]} with no extra text. Example: {"items":[{"name_zh":"苹果","name_en":"apple","grams":150},{"name_zh":"香蕉","name_en":"banana","grams":120}]}',
        
        'en' => 'Identify all foods in this photo and estimate grams for each item. For each food, provide English names. Return strictly this JSON schema: {"items":[{"name_zh":"","name_en":"english name","grams":123}]} with no extra text. Example: {"items":[{"name_zh":"","name_en":"apple","grams":150},{"name_zh":"","name_en":"banana","grams":120}]}',
        
        'ja' => 'Identify all foods in this photo and estimate grams for each item. For each food, provide both Japanese and English names. Return strictly this JSON schema: {"items":[{"name_zh":"日本語名前","name_en":"english name","grams":123}]} with no extra text. Example: {"items":[{"name_zh":"りんご","name_en":"apple","grams":150},{"name_zh":"バナナ","name_en":"banana","grams":120}]}'
    ];
    
    return $prompts[$language] ?? $prompts['zh-TW'];
}

try {
    // 記錄請求信息
    error_log("=== Fooda AI 圖片分析請求開始 ===");
    error_log("請求方法: " . $_SERVER['REQUEST_METHOD']);
    error_log("內容類型: " . ($_SERVER['CONTENT_TYPE'] ?? 'N/A'));
    
    // 1. 驗證請求方法
    if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
        sendError('Only POST method allowed', $config['ERROR_CODES']['ANALYZE_BAD_FILE'], 405);
    }

    // 2. 檢查上傳檔案
    if (!isset($_FILES['photo'])) {
        error_log("錯誤: 沒有找到 photo 欄位");
        error_log("POST 數據: " . json_encode($_POST));
        error_log("FILES 數據: " . json_encode($_FILES));
        sendError('No photo uploaded', $config['ERROR_CODES']['ANALYZE_BAD_FILE'], 400);
    }

    $uploadedFile = $_FILES['photo'];
    
    // 記錄上傳文件信息
    error_log("上傳文件信息:");
    error_log("  - 名稱: " . $uploadedFile['name']);
    error_log("  - 類型: " . $uploadedFile['type']);
    error_log("  - 大小: " . round($uploadedFile['size'] / 1024, 2) . " KB");
    error_log("  - 臨時路徑: " . $uploadedFile['tmp_name']);
    error_log("  - 錯誤碼: " . $uploadedFile['error']);

    // 檢查上傳錯誤
    if ($uploadedFile['error'] !== UPLOAD_ERR_OK) {
        $errorMsg = 'Upload failed with error code: ' . $uploadedFile['error'];
        error_log("上傳錯誤: " . $errorMsg);
        sendError($errorMsg, $config['ERROR_CODES']['ANALYZE_BAD_FILE'], 400);
    }

    // 3. 驗證檔案大小
    if ($uploadedFile['size'] > $config['MAX_UPLOAD_SIZE']) {
        $maxMB = $config['MAX_UPLOAD_SIZE'] / (1024 * 1024);
        $actualMB = round($uploadedFile['size'] / (1024 * 1024), 2);
        error_log("錯誤: 文件過大 {$actualMB}MB，限制 {$maxMB}MB");
        sendError("圖片文件過大 ({$actualMB}MB)，超過了 {$maxMB}MB 的限制。\n\n建議：\n1. 使用相機應用的「降低解析度」選項\n2. 使用圖片壓縮工具\n3. 選擇較小的圖片文件", $config['ERROR_CODES']['ANALYZE_BAD_FILE'], 400);
    }

    // 4. 驗證檔案類型
    $mimeType = $uploadedFile['type'];
    $fileExtension = strtolower(pathinfo($uploadedFile['name'], PATHINFO_EXTENSION));
    
    error_log("檔案驗證:");
    error_log("  - MIME 類型: " . $mimeType);
    error_log("  - 副檔名: " . $fileExtension);

    // 優先檢查副檔名（更可靠），MIME 類型作為參考
    if (!in_array($fileExtension, $config['ALLOWED_EXTENSIONS'])) {
        error_log("錯誤: 不支援的檔案副檔名: " . $fileExtension);
        sendError("不支持的圖片格式 (.{$fileExtension})。\n\n支持的格式：\n✅ JPEG/JPG - 相機照片\n✅ PNG - 截圖或保存的圖片\n✅ WebP - 現代圖片格式\n\n提示：\n- iOS用戶請從「相冊」選擇圖片（會自動轉換格式）\n- 或使用相機應用的「兼容模式」拍攝", $config['ERROR_CODES']['ANALYZE_BAD_FILE'], 400);
    }
    
    // 檢查 MIME 類型（僅警告，不阻止）
    if (!in_array($mimeType, $config['ALLOWED_IMAGE_TYPES'])) {
        error_log("警告: MIME 類型不在標準列表中: " . $mimeType . "（但副檔名正確，繼續處理）");
    }
    
    // 對於 PNG，接受常見的 MIME 類型變體
    if ($fileExtension === 'png') {
        // iOS 可能使用 image/png 或其他變體
        if (!in_array($mimeType, ['image/png', 'image/x-png'])) {
            error_log("注意: PNG 文件的 MIME 類型為 " . $mimeType);
        }
        // 強制使用標準 MIME 類型
        $mimeType = 'image/png';
        error_log("已標準化 PNG 的 MIME 類型為: image/png");
    }

    // 5. 讀取並編碼圖片
    error_log("正在讀取圖片文件...");
    $imageData = file_get_contents($uploadedFile['tmp_name']);
    if ($imageData === false) {
        error_log("錯誤: 無法讀取圖片文件");
        sendError('Failed to read uploaded image', $config['ERROR_CODES']['ANALYZE_INTERNAL'], 500);
    }

    error_log("圖片讀取成功，大小: " . strlen($imageData) . " bytes");
    error_log("正在進行 Base64 編碼...");
    $base64Image = base64_encode($imageData);
    error_log("Base64 編碼完成，長度: " . strlen($base64Image) . " chars");

    // 6. 準備 Gemini API 請求
    $language = $_POST['language'] ?? 'zh-TW';
    error_log("使用語言: " . $language);
    
    $geminiUrl = $config['GEMINI_API_URL'] . '?key=' . $config['GEMINI_API_KEY'];
    
    $requestData = [
        'contents' => [
            [
                'parts' => [
                    [
                        'text' => generatePromptByLanguage($language)
                    ],
                    [
                        'inline_data' => [
                            'mime_type' => $mimeType,
                            'data' => $base64Image
                        ]
                    ]
                ]
            ]
        ],
        'generationConfig' => $config['GEMINI_CONFIG']
    ];
    
    error_log("準備 Gemini API 請求:");
    error_log("  - URL: " . $config['GEMINI_API_URL']);
    error_log("  - MIME類型: " . $mimeType);
    error_log("  - 語言: " . $language);
    error_log("  - 提示詞長度: " . strlen(generatePromptByLanguage($language)) . " chars");

    // 7. 發送請求到 Gemini API
    error_log("正在發送請求到 Gemini API...");
    $ch = curl_init();
    curl_setopt_array($ch, [
        CURLOPT_URL => $geminiUrl,
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_POST => true,
        CURLOPT_POSTFIELDS => json_encode($requestData),
        CURLOPT_HTTPHEADER => [
            'Content-Type: application/json',
            'User-Agent: Fooda/1.0'
        ],
        CURLOPT_TIMEOUT => 30,
        CURLOPT_SSL_VERIFYPEER => false,
        CURLOPT_SSL_VERIFYHOST => false,
        CURLOPT_FOLLOWLOCATION => true
    ]);

    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    $curlError = curl_error($ch);
    curl_close($ch);

    // 8. 檢查 cURL 錯誤
    if ($curlError) {
        error_log("Gemini API cURL error: " . $curlError);
        sendError('AI service request failed', $config['ERROR_CODES']['ANALYZE_INTERNAL'], 500);
    }

    // 9. 檢查 HTTP 狀態碼
    if ($httpCode !== 200) {
        error_log("Gemini API HTTP error: {$httpCode} - {$response}");
        sendError("AI service error: {$httpCode}", $config['ERROR_CODES']['ANALYZE_INTERNAL'], 500);
    }

    // 10. 解析 Gemini API 回應
    $geminiResponse = json_decode($response, true);
    if (!$geminiResponse) {
        error_log("Failed to parse Gemini response: " . $response);
        sendError('AI service response format error', $config['ERROR_CODES']['ANALYZE_MODEL_FORMAT'], 400);
    }

    // 記錄完整的 Gemini 回應結構用於調試
    error_log("Gemini API 完整回應: " . json_encode($geminiResponse, JSON_UNESCAPED_UNICODE));
    
    // 檢查 Gemini API 是否返回錯誤
    if (isset($geminiResponse['error'])) {
        $errorMsg = $geminiResponse['error']['message'] ?? 'Unknown Gemini API error';
        $errorCode = $geminiResponse['error']['code'] ?? 'UNKNOWN';
        error_log("Gemini API 錯誤: {$errorCode} - {$errorMsg}");
        
        // 返回更友好的錯誤訊息
        if (stripos($errorMsg, 'quota') !== false || stripos($errorMsg, 'limit') !== false) {
            sendError("API 配額已用完或達到限制。請稍後再試或檢查 API Key 設定。\n\nGemini 錯誤: {$errorMsg}", $config['ERROR_CODES']['ANALYZE_INTERNAL'], 400);
        } else if (stripos($errorMsg, 'api key') !== false || stripos($errorMsg, 'authentication') !== false) {
            sendError("API Key 驗證失敗。請檢查 env.php 中的 GEMINI_API_KEY 是否正確。\n\nGemini 錯誤: {$errorMsg}", $config['ERROR_CODES']['ANALYZE_INTERNAL'], 400);
        } else {
            sendError("Gemini AI 服務錯誤: {$errorMsg}", $config['ERROR_CODES']['ANALYZE_INTERNAL'], 400);
        }
    }

    $items = null;
    
    // 方法 1: 直接從回應根層級取得（純 JSON 模式）
    if (isset($geminiResponse['items']) && is_array($geminiResponse['items'])) {
        $items = $geminiResponse['items'];
        error_log("使用方法 1：直接從根層級取得 items");
    }
    // 方法 2: 從 candidates 中解析（標準模式）
    elseif (isset($geminiResponse['candidates'][0]['content']['parts'][0]['text'])) {
        $aiText = trim($geminiResponse['candidates'][0]['content']['parts'][0]['text']);
        error_log("Gemini 回應文本: " . $aiText);
        
        // 清理可能的 markdown 格式
        $aiText = preg_replace('/```json\s*|\s*```/', '', $aiText);
        $aiText = trim($aiText);
        
        $aiData = json_decode($aiText, true);
        
        if ($aiData && isset($aiData['items'])) {
            $items = $aiData['items'];
            error_log("使用方法 2：從 candidates 解析成功");
        } else {
            error_log("方法 2 解析失敗，嘗試直接解析為 items 數組");
            // 方法 3: 嘗試直接解析為 items 數組
            $directItems = json_decode($aiText, true);
            if (is_array($directItems)) {
                $items = $directItems;
                error_log("使用方法 3：直接解析為數組成功");
            }
        }
    }
    
    // 如果所有方法都失敗
    if (!$items) {
        error_log("所有解析方法都失敗，Gemini 回應結構: " . json_encode($geminiResponse, JSON_UNESCAPED_UNICODE));
        
        // 嘗試提取更多診斷資訊
        $debugInfo = '';
        if (isset($geminiResponse['candidates'][0]['content']['parts'][0]['text'])) {
            $aiText = $geminiResponse['candidates'][0]['content']['parts'][0]['text'];
            $debugInfo = "\n\nAI 回應內容預覽:\n" . substr($aiText, 0, 500);
        } else if (isset($geminiResponse['candidates'][0]['finishReason'])) {
            $finishReason = $geminiResponse['candidates'][0]['finishReason'];
            $debugInfo = "\n\n完成原因: {$finishReason}";
            
            if ($finishReason === 'SAFETY') {
                sendError("圖片被安全過濾器攔截。\n請確保圖片內容適當且包含食物。", $config['ERROR_CODES']['ANALYZE_MODEL_FORMAT'], 400);
            } else if ($finishReason === 'RECITATION') {
                sendError("圖片內容無法處理（版權問題）。\n請使用原創拍攝的食物照片。", $config['ERROR_CODES']['ANALYZE_MODEL_FORMAT'], 400);
            }
        }
        
        sendError('AI 無法從回應中識別食物資訊。' . $debugInfo . '\n\n可能原因:\n1. 圖片中沒有清晰可見的食物\n2. Gemini API 回應格式異常\n3. 請嘗試其他食物照片', $config['ERROR_CODES']['ANALYZE_MODEL_FORMAT'], 400);
    }

    // 11. 清洗和驗證識別結果
    $cleanedItems = [];
    foreach ($items as $item) {
        // 支援新格式（中英文名稱）和舊格式（單一名稱）
        $nameZh = trim((string)($item['name_zh'] ?? ''));
        $nameEn = trim((string)($item['name_en'] ?? ''));
        $nameLegacy = trim((string)($item['name'] ?? ''));
        
        $grams = (int)round(floatval($item['grams'] ?? 0));
        
        // 確定最終使用的名稱
        $finalNameZh = $nameZh ?: $nameLegacy;
        $finalNameEn = $nameEn ?: $nameLegacy;
        
        if (($finalNameZh !== '' || $finalNameEn !== '') && $grams > 0) {
            $cleanedItems[] = [
                'name_zh' => $finalNameZh,
                'name_en' => $finalNameEn,
                'name' => $finalNameZh ?: $finalNameEn, // 向後兼容
                'grams' => max(1, min(2000, $grams)) // 限制在 1-2000g 範圍
            ];
        }
    }

    // 12. 檢查是否有有效結果
    if (empty($cleanedItems)) {
        sendError('無法識別圖片中的食物。請確保：\n1. 圖片中包含清晰可見的食物\n2. 光線充足，食物特徵清楚\n3. 不是人像、風景等非食物圖片\n\n提示：您可以重新拍攝或選擇其他食物照片', $config['ERROR_CODES']['ANALYZE_MODEL_FORMAT'], 400);
    }

    // 13. 記錄成功日誌
    error_log("Food recognition success: " . count($cleanedItems) . " items");

    // 14. 回應成功結果
    sendSuccess([
        'items' => $cleanedItems
    ]);

} catch (Exception $e) {
    error_log("analyze.php Exception: " . $e->getMessage());
    sendError('Internal server error', $config['ERROR_CODES']['ANALYZE_INTERNAL'], 500);
} catch (Error $e) {
    error_log("analyze.php Error: " . $e->getMessage() . " in " . $e->getFile() . " on line " . $e->getLine());
    sendError('Internal server error', $config['ERROR_CODES']['ANALYZE_INTERNAL'], 500);
}
?>
