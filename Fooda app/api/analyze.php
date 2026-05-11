<?php
/**
 * Fooda 食物圖片分析 API
 * 根據規格文件實現 - 使用 Gemini API 進行食物識別
 */

// 設定錯誤報告
error_reporting(E_ALL);
ini_set('display_errors', 0);
ini_set('log_errors', 1);

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
    // 1. 驗證請求方法
    if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
        sendError('Only POST method allowed', $config['ERROR_CODES']['ANALYZE_BAD_FILE'], 405);
    }

    // 2. 檢查上傳檔案
    if (!isset($_FILES['photo'])) {
        sendError('No photo uploaded', $config['ERROR_CODES']['ANALYZE_BAD_FILE'], 400);
    }

    $uploadedFile = $_FILES['photo'];

    // 檢查上傳錯誤
    if ($uploadedFile['error'] !== UPLOAD_ERR_OK) {
        $errorMsg = 'Upload failed with error code: ' . $uploadedFile['error'];
        sendError($errorMsg, $config['ERROR_CODES']['ANALYZE_BAD_FILE'], 400);
    }

    // 3. 驗證檔案大小
    if ($uploadedFile['size'] > $config['MAX_UPLOAD_SIZE']) {
        $maxMB = $config['MAX_UPLOAD_SIZE'] / (1024 * 1024);
        sendError("File size exceeds {$maxMB}MB limit", $config['ERROR_CODES']['ANALYZE_BAD_FILE'], 400);
    }

    // 4. 驗證檔案類型（不使用 fileinfo）
    $mimeType = $uploadedFile['type'];
    $fileExtension = strtolower(pathinfo($uploadedFile['name'], PATHINFO_EXTENSION));

    if (!in_array($mimeType, $config['ALLOWED_IMAGE_TYPES']) || 
        !in_array($fileExtension, $config['ALLOWED_EXTENSIONS'])) {
        sendError('Unsupported image format. Use JPG, PNG or WebP', $config['ERROR_CODES']['ANALYZE_BAD_FILE'], 400);
    }

    // 5. 讀取並編碼圖片
    $imageData = file_get_contents($uploadedFile['tmp_name']);
    if ($imageData === false) {
        sendError('Failed to read uploaded image', $config['ERROR_CODES']['ANALYZE_INTERNAL'], 500);
    }

    $base64Image = base64_encode($imageData);

    // 6. 準備 Gemini API 請求
    $geminiUrl = $config['GEMINI_API_URL'] . '?key=' . $config['GEMINI_API_KEY'];
    
    $requestData = [
        'contents' => [
            [
                'parts' => [
                    [
                        'text' => generatePromptByLanguage($_POST['language'] ?? 'zh-TW')
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

    // 7. 發送請求到 Gemini API
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
        sendError('AI recognition format error', $config['ERROR_CODES']['ANALYZE_MODEL_FORMAT'], 400);
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
        sendError('No food items recognized', $config['ERROR_CODES']['ANALYZE_MODEL_FORMAT'], 400);
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
